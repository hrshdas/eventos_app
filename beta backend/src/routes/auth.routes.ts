import { Router } from 'express';
import { z } from 'zod';
import {
  signupController,
  loginController,
  refreshTokenController,
  googleLoginController,
} from '../controllers/auth.controller';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const signupSchema = z.object({
  body: z.object({
    name: z.string().min(1, 'Name is required'),
    email: z.string().email('Invalid email format'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
    role: z.enum(['CONSUMER', 'OWNER', 'ADMIN']).optional(),
  }),
});

const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(1, 'Password is required'),
  }),
});

const refreshSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
});

const googleSchema = z.object({
  body: z.object({
    idToken: z.string().min(10, 'idToken is required'),
  }),
});

router.post('/signup', validateRequest(signupSchema), signupController);
router.post('/login', validateRequest(loginSchema), loginController);
router.post('/refresh', validateRequest(refreshSchema), refreshTokenController);
router.post('/google', validateRequest(googleSchema), googleLoginController);

export default router;
