import jwt, { JwtPayload, SignOptions, Secret } from 'jsonwebtoken';
import { config } from '../config/env';
import { User } from '@prisma/client';

export interface TokenPayload extends JwtPayload {
  userId: string;
  email: string;
  role: string;
}

/**
 * Helpers to make sure secrets & expiry are valid
 */
const getAccessSecret = (): Secret => {
  const secret = config.jwt.accessSecret;
  if (!secret) {
    throw new Error('JWT_ACCESS_SECRET is not set in environment variables');
  }
  return secret as Secret;
};

const getRefreshSecret = (): Secret => {
  const secret = config.jwt.refreshSecret;
  if (!secret) {
    throw new Error('JWT_REFRESH_SECRET is not set in environment variables');
  }
  return secret as Secret;
};

const getAccessSignOptions = (): SignOptions => ({
  // falls back to a sane default if env is missing
  expiresIn: (config.jwt.accessExpiresIn || '15m') as SignOptions['expiresIn'],
});

const getRefreshSignOptions = (): SignOptions => ({
  expiresIn: (config.jwt.refreshExpiresIn || '7d') as SignOptions['expiresIn'],
});

export const generateAccessToken = (user: User): string => {
  const payload: TokenPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  };

  return jwt.sign(payload, getAccessSecret(), getAccessSignOptions());
};

export const generateRefreshToken = (user: User): string => {
  const payload: TokenPayload = {
    userId: user.id,
    email: user.email,
    role: user.role,
  };

  return jwt.sign(payload, getRefreshSecret(), getRefreshSignOptions());
};

export const verifyAccessToken = (token: string): TokenPayload => {
  try {
    const decoded = jwt.verify(token, getAccessSecret()) as TokenPayload;
    return decoded;
  } catch (error) {
    throw new Error('Invalid or expired access token');
  }
};

export const verifyRefreshToken = (token: string): TokenPayload => {
  try {
    const decoded = jwt.verify(token, getRefreshSecret()) as TokenPayload;
    return decoded;
  } catch (error) {
    throw new Error('Invalid or expired refresh token');
  }
};
