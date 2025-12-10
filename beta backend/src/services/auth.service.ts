import bcrypt from 'bcryptjs';
import { prisma } from '../config/db';
import { generateAccessToken, generateRefreshToken } from '../utils/jwt';
import { UserRole } from '@prisma/client';
import { ApiError } from '../middleware/errorHandler';
import { OAuth2Client, TokenPayload } from 'google-auth-library';
import { config } from '../config/env';

const googleClient = new OAuth2Client(config.google.clientId);

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
  // Verify the Google ID token
  const ticket = await googleClient.verifyIdToken({
    idToken,
    audience: config.google.clientId,
  });
  const payload: TokenPayload | undefined = ticket.getPayload();

  if (!payload) {
    const error: ApiError = new Error('Invalid Google token');
    error.statusCode = 400;
    throw error;
  }

  const email = (payload.email || '').trim().toLowerCase();
  const name = payload.name || 'Google User';

  if (!email) {
    const error: ApiError = new Error('Google account email is required');
    error.statusCode = 400;
    throw error;
  }

  // Try to find existing user by email
  let user = await prisma.user.findUnique({ where: { email } });

  if (!user) {
    // Create a new user with a random password hash (will not be used for login)
    const randomSecret = await bcrypt.hash(`${email}:${Date.now()}`, 10);
    user = await prisma.user.create({
      data: {
        name,
        email,
        passwordHash: randomSecret,
        role: UserRole.CONSUMER,
      },
    });
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
