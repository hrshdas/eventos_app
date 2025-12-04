import { Router } from 'express';
import { z } from 'zod';
import {
  createBookingController,
  getMyBookingsController,
  getOwnerBookingsController,
} from '../controllers/booking.controller';
import { authMiddleware, requireRole } from '../middleware/authMiddleware';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const createBookingSchema = z.object({
  body: z.object({
    listingId: z.string().uuid('Invalid listing ID'),
    startDate: z.string().datetime('Invalid start date'),
    endDate: z.string().datetime('Invalid end date'),
  }),
});

router.post(
  '/',
  authMiddleware,
  validateRequest(createBookingSchema),
  createBookingController
);

router.get('/me', authMiddleware, getMyBookingsController);

router.get(
  '/owner',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  getOwnerBookingsController
);

export default router;

