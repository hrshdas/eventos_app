import { z } from 'zod';

/**
 * Booking validation schemas
 */

export const createBookingSchema = z.object({
  body: z.object({
    listingId: z.string().uuid('Invalid listing ID'),
    startDate: z.string().datetime('Invalid start date format').refine(
      (date) => new Date(date) > new Date(),
      'Start date must be in the future'
    ),
    endDate: z.string().datetime('Invalid end date format'),
  }).refine(
    (data) => new Date(data.endDate) > new Date(data.startDate),
    {
      message: 'End date must be after start date',
      path: ['endDate'],
    }
  ),
});

