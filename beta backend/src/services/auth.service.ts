/**
 * Auth service
 * - Adds Google Sign-In: verifies idToken against configured audiences
 * - Creates or reuses user by email, and stores googleId/avatarUrl when available
 */
import bcrypt from 'bcryptjs';
import { prisma } from '../config/db';
import { generateAccessToken, generateRefreshToken } from '../utils/jwt';
import { UserRole } from '@prisma/client';
import { ApiError } from '../middleware/errorHandler';
import { OAuth2Client, TokenPayload } from 'google-auth-library';
import { config } from '../config/env';

// Client may be constructed without clientId; we validate audiences during verify
const googleClient = new OAuth2Client(config.google.clientId || undefined);

export interface SignupData {
  name: string;
  email: string;
  password: string;
  role?: UserRole;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
  };
  accessToken: string;
  refreshToken: string;
}

export const signup = async (data: SignupData): Promise<AuthResponse> => {
  const { name, email, password, role = UserRole.CONSUMER } = data;

  // Normalize email to avoid case/whitespace issues
  const normalizedEmail = email.trim().toLowerCase();

  // Check if user already exists
  const existingUser = await prisma.user.findUnique({
    where: { email: normalizedEmail },
  });

  if (existingUser) {
    const error: ApiError = new Error('User with this email already exists');
    error.statusCode = 409;
    throw error;
  }

  // Hash password
  const passwordHash = await bcrypt.hash(password, 10);

  // Create user
  const user = await prisma.user.create({
    data: {
      name,
      email: normalizedEmail,
      passwordHash,
      role,
    },
  });

  // Generate tokens
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
    accessToken,
    refreshToken,
  };
};

export const login = async (data: LoginData): Promise<AuthResponse> => {
  const { email, password } = data;

  // Normalize email to avoid case/whitespace issues
  const normalizedEmail = email.trim().toLowerCase();

  // Find user
  const user = await prisma.user.findUnique({
    where: { email: normalizedEmail },
  });

  if (!user) {
    console.warn(`[auth] Login failed: user not found for email: ${normalizedEmail}`);
    const error: ApiError = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  // Verify password
  const isValidPassword = await bcrypt.compare(password, user.passwordHash);

  if (!isValidPassword) {
    console.warn(`[auth] Login failed: invalid password for email: ${normalizedEmail}`);
    const error: ApiError = new Error('Invalid email or password');
    error.statusCode = 401;
    throw error;
  }

  // Generate tokens
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
    accessToken,
    refreshToken,
  };
};

export const googleLogin = async (idToken: string): Promise<AuthResponse> => {
  // Verify the Google ID token against known audiences (client IDs)
  const ticket = await googleClient.verifyIdToken({
    idToken,
    audience: (config.google.audiences && config.google.audiences.length > 0)
      ? config.google.audiences
      : (config.google.clientId ? [config.google.clientId] : undefined),
  });
  const payload: TokenPayload | undefined = ticket.getPayload();

  if (!payload) {
    const error: ApiError = new Error('Invalid Google token');
    error.statusCode = 400;
    throw error;
  }

  const email = (payload.email || '').trim().toLowerCase();
  const name = payload.name || 'Google User';
  const googleId = payload.sub || undefined;
  const avatarUrl = payload.picture || undefined;

  if (!email) {
    const error: ApiError = new Error('Google account email is required');
    error.statusCode = 400;
    throw error;
  }

  // Try to find existing user by email
  let user = await prisma.user.findUnique({ where: { email } });

  if (!user) {
    // Create a new user with a random password hash (will not be used for password login)
    const randomSecret = await bcrypt.hash(`${email}:${Date.now()}`, 10);
    user = await prisma.user.create({
      data: {
        name,
        email,
        passwordHash: randomSecret,
        role: UserRole.CONSUMER,
        // Optional fields if present in schema
        ...(googleId ? { googleId } : {}),
        ...(avatarUrl ? { avatarUrl } : {}),
      },
    });
  } else {
    // Update missing google fields if not set
    const updates: Record<string, any> = {};
    if (googleId && !(user as any).googleId) updates.googleId = googleId;
    if (avatarUrl && !(user as any).avatarUrl) updates.avatarUrl = avatarUrl;
    if (Object.keys(updates).length) {
      user = await prisma.user.update({ where: { id: user.id }, data: updates });
    }
  }

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
    accessToken,
    refreshToken,
  };
};
