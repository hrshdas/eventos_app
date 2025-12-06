import { prisma } from '../config/db';
import { UserDto } from '../types/dto';
import { ApiError } from '../middleware/errorHandler';

/**
 * Get user by ID (excludes passwordHash)
 */
export const getUserById = async (userId: string): Promise<UserDto | null> => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      role: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  return user;
};

/**
 * Get current user profile
 */
export const getCurrentUser = async (userId: string): Promise<UserDto> => {
  const user = await getUserById(userId);

  if (!user) {
    const error: ApiError = new Error('User not found');
    error.statusCode = 404;
    throw error;
  }

  return user;
};

