import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { logger } from '../utils/logger';

export interface ApiError extends Error {
  statusCode?: number;
  code?: string;
}

export const errorHandler = (
  err: ApiError | ZodError | Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  logger.error('Error:', err);

  // Zod validation errors
  if (err instanceof ZodError) {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      details: err.errors.map((e) => ({
        path: e.path.join('.'),
        message: e.message,
      })),
    });
  }

  // Prisma errors
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') {
      return res.status(409).json({
        success: false,
        error: 'Duplicate entry',
        message: 'A record with this value already exists',
      });
    }
    if (err.code === 'P2025') {
      return res.status(404).json({
        success: false,
        error: 'Not found',
        message: 'The requested record was not found',
      });
    }
  }

  // Custom API errors
  if ('statusCode' in err && err.statusCode) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message || 'An error occurred',
    });
  }

  // Default server error
  res.status(500).json({
    success: false,
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
};

