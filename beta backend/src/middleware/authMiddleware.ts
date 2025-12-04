import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';
import { prisma } from '../config/db';
import { ApiError } from './errorHandler';

export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      const error: ApiError = new Error('No token provided');
      error.statusCode = 401;
      throw error;
    }

    const token = authHeader.substring(7);
    const payload = verifyAccessToken(token);

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
    });

    if (!user) {
      const error: ApiError = new Error('User not found');
      error.statusCode = 401;
      throw error;
    }

    req.user = user;
    next();
  } catch (error) {
    if (error instanceof Error && 'statusCode' in error) {
      return next(error);
    }
    const apiError: ApiError = new Error('Invalid or expired token');
    apiError.statusCode = 401;
    next(apiError);
  }
};

export const requireRole = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      const error: ApiError = new Error('Unauthorized');
      error.statusCode = 401;
      return next(error);
    }

    if (!roles.includes(req.user.role)) {
      const error: ApiError = new Error('Forbidden: Insufficient permissions');
      error.statusCode = 403;
      return next(error);
    }

    next();
  };
};

