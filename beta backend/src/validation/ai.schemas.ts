import { z } from 'zod';

/**
 * AI Planner validation schemas
 */

const EVENT_TYPES = [
  'Birthday',
  'Wedding',
  'Corporate',
  'Anniversary',
  'Baby Shower',
  'Engagement',
  'Other'
] as const;

const GUEST_RANGES = [
  '10-50',
  '50-100',
  '100-200',
  '200-500',
  '500+'
] as const;

export const aiPlannerRequestSchema = z.object({
  body: z.object({
    eventType: z.enum(EVENT_TYPES, {
      errorMap: () => ({ message: 'Invalid event type' })
    }),
    location: z.string()
      .min(2, 'Location must be at least 2 characters')
      .max(100, 'Location too long'),
    guests: z.enum(GUEST_RANGES, {
      errorMap: () => ({ message: 'Invalid guest range' })
    }),
    budget: z.number()
      .positive('Budget must be positive')
      .max(10000000, 'Budget exceeds maximum'),
    description: z.string()
      .max(500, 'Description too long')
      .optional()
      .default(''),
    date: z.string()
      .datetime({ message: 'Invalid date format, use ISO 8601' })
  })
});

export type AIPlannerRequest = z.infer<typeof aiPlannerRequestSchema>['body'];

