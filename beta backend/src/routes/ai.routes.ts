import { Router } from 'express';
import { generatePlanController } from '../controllers/ai.controller';
import { validateRequest } from '../middleware/validateRequest';
import { aiPlannerRequestSchema } from '../validation/ai.schemas';
import rateLimit from 'express-rate-limit';

const router = Router();

// AI-specific rate limiter: 10 requests per 15 minutes
const aiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  message: {
    success: false,
    error: 'Too many AI requests. Please try again in 15 minutes.',
    code: 'AI_RATE_LIMIT_EXCEEDED'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

router.post(
  '/plan',
  aiRateLimiter,
  validateRequest(aiPlannerRequestSchema),
  generatePlanController
);

export default router;

