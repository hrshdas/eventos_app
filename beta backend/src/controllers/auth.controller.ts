import { Request, Response, NextFunction } from 'express';
import { signup, login } from '../services/auth.service';
import { verifyRefreshToken } from '../utils/jwt';
import { prisma } from '../config/db';
import { generateAccessToken } from '../utils/jwt';
import { ApiError } from '../middleware/errorHandler';

export const signupController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await signup(req.body);
    res.status(201).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const loginController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const result = await login(req.body);
    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const refreshTokenController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      const error: ApiError = new Error('Refresh token is required');
      error.statusCode = 400;
      throw error;
    }

    const payload = verifyRefreshToken(refreshToken);

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
    });

    if (!user) {
      const error: ApiError = new Error('User not found');
      error.statusCode = 401;
      throw error;
    }

    const accessToken = generateAccessToken(user);

    res.status(200).json({
      success: true,
      data: {
        accessToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

