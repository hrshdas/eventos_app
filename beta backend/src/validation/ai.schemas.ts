import { z } from 'zod';

/**
 * AI Planner validation schemas
 */

export const aiPlannerSuggestSchema = z.object({
  body: z.object({
    eventType: z.string().min(1, 'Event type is required').max(100),
    budget: z.number().positive('Budget must be positive'),
    guests: z.number().int().positive('Guests must be a positive integer'),
    location: z.string().min(1, 'Location is required').max(200).optional(),
    date: z.string().min(1, 'Date is required'),
    vibe: z.string().max(100).optional(),
    theme: z.string().max(100).optional(),
  }),
});

