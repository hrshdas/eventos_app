import { Router } from 'express';
import { z } from 'zod';
import { partyPlannerController } from '../controllers/ai.controller';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const partyPlannerSchema = z.object({
  body: z.object({
    date: z.string().min(1, 'Date is required'),
    guests: z.number().int().positive('Guests must be a positive number'),
    budget: z.number().positive('Budget must be positive'),
    theme: z.string().optional(),
    location: z.string().optional(),
  }),
});

router.post(
  '/party-planner',
  validateRequest(partyPlannerSchema),
  partyPlannerController
);

export default router;

