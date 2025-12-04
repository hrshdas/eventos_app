import { Router } from 'express';
import { z } from 'zod';
import {
  initiatePaymentController,
  paymentWebhookController,
} from '../controllers/payment.controller';
import { authMiddleware } from '../middleware/authMiddleware';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const initiatePaymentSchema = z.object({
  body: z.object({
    bookingId: z.string().uuid('Invalid booking ID'),
  }),
});

router.post(
  '/initiate',
  authMiddleware,
  validateRequest(initiatePaymentSchema),
  initiatePaymentController
);

// Webhook endpoint (no auth required, but should be secured with webhook secret)
router.post('/webhook', paymentWebhookController);

export default router;

