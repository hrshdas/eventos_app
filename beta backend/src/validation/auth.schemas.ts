import { z } from 'zod';

/**
 * Authentication validation schemas
 */

export const signupSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required').max(100, 'Name is too long'),
    email: z.string().email('Invalid email format').toLowerCase(),
    password: z.string().min(6, 'Password must be at least 6 characters').max(100, 'Password is too long'),
    role: z.enum(['CONSUMER', 'OWNER', 'ADMIN']).optional(),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email format').toLowerCase(),
    password: z.string().min(1, 'Password is required'),
  }),
});

export const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});

