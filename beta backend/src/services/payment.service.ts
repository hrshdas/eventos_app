import Stripe from 'stripe';
import { prisma } from '../config/db';
import { Payment, PaymentStatus, PaymentProvider, BookingStatus } from '@prisma/client';
import { config } from '../config/env';
import { ApiError } from '../middleware/errorHandler';

const stripe = config.stripe.secretKey
  ? new Stripe(config.stripe.secretKey, { apiVersion: '2023-10-16' })
  : null;

export interface InitiatePaymentData {
  bookingId: string;
}

export const initiatePayment = async (
  data: InitiatePaymentData
): Promise<{ paymentId: string; clientSecret?: string; paymentSessionId?: string }> => {
  const { bookingId } = data;

  // Get booking
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: { listing: true },
  });

  if (!booking) {
    const error: ApiError = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  if (booking.status !== BookingStatus.PENDING) {
    const error: ApiError = new Error('Booking is not in pending status');
    error.statusCode = 400;
    throw error;
  }

  // Check if payment already exists
  const existingPayment = await prisma.payment.findUnique({
    where: { bookingId },
  });

  if (existingPayment && existingPayment.status === PaymentStatus.SUCCESS) {
    const error: ApiError = new Error('Payment already completed');
    error.statusCode = 400;
    throw error;
  }

  // For now, we'll use Stripe as the default provider
  // In production, you might want to support multiple providers
  const provider = PaymentProvider.STRIPE;

  let clientSecret: string | undefined;
  let providerPaymentId: string | undefined;

  if (stripe) {
    try {
      // Create Stripe PaymentIntent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: booking.totalAmount * 100, // Convert to cents
        currency: 'usd',
        metadata: {
          bookingId: booking.id,
        },
      });

      clientSecret = paymentIntent.client_secret || undefined;
      providerPaymentId = paymentIntent.id;
    } catch (error) {
      // If Stripe fails, create a mock payment for development
      console.warn('Stripe error, using mock payment:', error);
      providerPaymentId = `mock_payment_${Date.now()}`;
    }
  } else {
    // Mock payment for development
    providerPaymentId = `mock_payment_${Date.now()}`;
  }

  // Create or update payment record
  const payment = await prisma.payment.upsert({
    where: { bookingId },
    create: {
      bookingId,
      provider,
      providerPaymentId: providerPaymentId || undefined,
      status: PaymentStatus.PENDING,
      amount: booking.totalAmount,
    },
    update: {
      providerPaymentId: providerPaymentId || undefined,
      status: PaymentStatus.PENDING,
    },
  });

  return {
    paymentId: payment.id,
    clientSecret,
    paymentSessionId: providerPaymentId,
  };
};

export const handlePaymentWebhook = async (
  provider: PaymentProvider,
  eventData: any
): Promise<void> => {
  if (provider === PaymentProvider.STRIPE && stripe) {
    // Handle Stripe webhook
    const event = eventData;

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object;
      const bookingId = paymentIntent.metadata?.bookingId;

      if (bookingId) {
        await prisma.payment.updateMany({
          where: {
            providerPaymentId: paymentIntent.id,
            bookingId,
          },
          data: {
            status: PaymentStatus.SUCCESS,
          },
        });

        // Update booking status
        await prisma.booking.update({
          where: { id: bookingId },
          data: { status: BookingStatus.PAID },
        });
      }
    } else if (event.type === 'payment_intent.payment_failed') {
      const paymentIntent = event.data.object;
      const bookingId = paymentIntent.metadata?.bookingId;

      if (bookingId) {
        await prisma.payment.updateMany({
          where: {
            providerPaymentId: paymentIntent.id,
            bookingId,
          },
          data: {
            status: PaymentStatus.FAILED,
          },
        });
      }
    }
  } else {
    // Mock webhook handling for development
    console.log('Mock webhook received:', { provider, eventData });
  }
};

