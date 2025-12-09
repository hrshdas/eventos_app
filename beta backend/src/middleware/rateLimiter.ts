import rateLimit from 'express-rate-limit';
import { config } from '../config/env';

// Because express-rate-limit's `message` can only be: string | object | undefined,
// but TS sometimes complains when using a structured object.
// So we explicitly type it as `any` to satisfy the definition.
const rateLimitMessage = (msg: string, code: string) => ({
  success: false,
  error: msg,
  code,
}) as any;

/**
 * General API rate limiter
 * 1000 requests per 15 minutes in dev
 * 100 in production
 */
export const apiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: config.nodeEnv === 'production' ? 100 : 1000,
  message: rateLimitMessage(
    'Too many requests from this IP, please try again later.',
    'RATE_LIMIT_EXCEEDED'
  ),
  standardHeaders: true,
  legacyHeaders: false,
  skip: () => config.nodeEnv === 'test',
});

/**
 * Strict rate limiter for authentication endpoints
 * 5 requests in prod, 200 in dev
 */
export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: config.nodeEnv === 'production' ? 5 : 200,
  message: rateLimitMessage(
    'Too many authentication attempts, please try again later.',
    'AUTH_RATE_LIMIT_EXCEEDED'
  ),
  standardHeaders: true,
  legacyHeaders: false,
  skip: () => config.nodeEnv === 'test',
});

/**
 * Payment rate limiter
 * 10 requests in prod, 100 in dev
 */
export const paymentRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: config.nodeEnv === 'production' ? 10 : 100,
  message: rateLimitMessage(
    'Too many payment requests, please try again later.',
    'PAYMENT_RATE_LIMIT_EXCEEDED'
  ),
  standardHeaders: true,
  legacyHeaders: false,
  skip: () => config.nodeEnv === 'test',
});
