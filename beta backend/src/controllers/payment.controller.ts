import { Request, Response, NextFunction } from 'express';
import { initiatePayment, handlePaymentWebhook } from '../services/payment.service';
import { PaymentProvider } from '@prisma/client';
import { config } from '../config/env';
import Stripe from 'stripe';

const stripe = config.stripe.secretKey
  ? new Stripe(config.stripe.secretKey, { apiVersion: '2023-10-16' })
  : null;

export const initiatePaymentController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const result = await initiatePayment(req.body);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const paymentWebhookController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const provider = (req.body as any).provider || PaymentProvider.STRIPE;

    if (provider === PaymentProvider.STRIPE && stripe && config.stripe.webhookSecret) {
      const sig = req.headers['stripe-signature'] as string;

      if (!sig) {
        return res.status(400).send('Missing stripe-signature header');
      }

      try {
        // req.body is raw buffer for webhook route
        const event = stripe.webhooks.constructEvent(
          req.body as Buffer,
          sig,
          config.stripe.webhookSecret
        );

        await handlePaymentWebhook(PaymentProvider.STRIPE, event);
      } catch (err: any) {
        console.error('Webhook signature verification failed:', err.message);
        return res.status(400).send(`Webhook Error: ${err.message}`);
      }
    } else {
      // Mock webhook for development
      // Parse JSON if it's a buffer
      const body = Buffer.isBuffer(req.body) 
        ? JSON.parse(req.body.toString()) 
        : req.body;
      await handlePaymentWebhook(provider, body);
    }

    res.status(200).json({ received: true });
  } catch (error) {
    next(error);
  }
};

