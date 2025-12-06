import { z } from 'zod';

/**
 * Payment validation schemas
 */

export const createPaymentSchema = z.object({
  body: z.object({
    bookingId: z.string().uuid('Invalid booking ID'),
    amount: z.number().positive('Amount must be positive').optional(),
    currency: z.string().length(3, 'Currency must be 3 characters').default('USD').optional(),
  }),
});

export const webhookSchema = z.object({
  body: z.object({
    type: z.string().optional(),
    data: z.any().optional(),
    provider: z.enum(['STRIPE', 'RAZORPAY']).optional(),
  }),
});

