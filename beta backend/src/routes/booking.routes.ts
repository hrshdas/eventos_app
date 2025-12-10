import { Router } from 'express';
import { z } from 'zod';
import {
  createBookingController,
  getMyBookingsController,
  getOwnerBookingsController,
  updateBookingStatusController,
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

const updateStatusSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid booking ID'),
  }),
  body: z.object({
    status: z.enum(['CONFIRMED', 'CANCELLED'], {
      required_error: 'status is required',
      invalid_type_error: 'status must be CONFIRMED or CANCELLED',
    }),
  }),
});

router.post(
  '/',
  authMiddleware,
  validateRequest(createBookingSchema),
  createBookingController
);

router.get('/me', authMiddleware, getMyBookingsController);
// Alias for client compatibility
router.get('/my', authMiddleware, getMyBookingsController);

router.get(
  '/owner',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  getOwnerBookingsController
);

router.patch(
  '/:id/status',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  validateRequest(updateStatusSchema),
  updateBookingStatusController
);

export default router;
