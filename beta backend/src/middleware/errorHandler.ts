import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { Prisma } from '@prisma/client';
import { logger } from '../utils/logger';

export interface ApiError extends Error {
  statusCode?: number;
  code?: string;
}

// Type guards so TypeScript can narrow correctly
const isZodError = (err: unknown): err is ZodError =>
  err instanceof ZodError;

const isPrismaKnownError = (
  err: unknown,
): err is Prisma.PrismaClientKnownRequestError =>
  err instanceof Prisma.PrismaClientKnownRequestError;

const isApiError = (err: unknown): err is ApiError =>
  typeof err === 'object' && err !== null && 'message' in err;

export const errorHandler = (
  err: unknown,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  next: NextFunction,
) => {
  logger.error('Error:', err);

  // ----------------------------
  // Zod validation errors
  // ----------------------------
  if (isZodError(err)) {
    return res.status(400).json({
      success: false,
      error: 'Validation error',
      details: err.errors.map((e) => ({
        path: e.path.join('.'),
        message: e.message,
      })),
    });
  }

  // ----------------------------
  // Prisma errors
  // ----------------------------
  if (isPrismaKnownError(err)) {
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

  // ----------------------------
  // Custom API errors / default
  // ----------------------------
  // Fallback to generic Error shape
  const apiError: ApiError = isApiError(err)
    ? err
    : new Error('Internal server error');

  const statusCode =
    typeof apiError.statusCode === 'number' ? apiError.statusCode : 500;

  return res.status(statusCode).json({
    success: false,
    error: apiError.message || 'An error occurred',
    // Only expose message in dev
    details:
      process.env.NODE_ENV === 'development'
        ? { name: apiError.name, stack: apiError.stack }
        : undefined,
  });
};
