import { prisma } from '../config/db';
import { Booking, BookingStatus } from '@prisma/client';
import { ApiError } from '../middleware/errorHandler';
import { getListingById } from './listing.service';

export interface CreateBookingData {
  listingId: string;
  userId: string;
  startDate: Date;
  endDate: Date;
}

export const createBooking = async (
  data: CreateBookingData
): Promise<Booking> => {
  const { listingId, userId, startDate, endDate } = data;

  // Validate dates
  if (startDate >= endDate) {
    const error: ApiError = new Error('End date must be after start date');
    error.statusCode = 400;
    throw error;
  }

  if (startDate < new Date()) {
    const error: ApiError = new Error('Start date cannot be in the past');
    error.statusCode = 400;
    throw error;
  }

  // Get listing
  const listing = await getListingById(listingId);
  if (!listing) {
    const error: ApiError = new Error('Listing not found');
    error.statusCode = 404;
    throw error;
  }

  if (!listing.isActive) {
    const error: ApiError = new Error('Listing is not available');
    error.statusCode = 400;
    throw error;
  }

  // Check for overlapping bookings
  const overlappingBookings = await prisma.booking.findMany({
    where: {
      listingId,
      status: {
        in: [BookingStatus.PENDING, BookingStatus.PAID, BookingStatus.CONFIRMED],
      },
      OR: [
        {
          startDate: { lte: endDate },
          endDate: { gte: startDate },
        },
      ],
    },
  });

  if (overlappingBookings.length > 0) {
    const error: ApiError = new Error('Listing is not available for the selected dates');
    error.statusCode = 409;
    throw error;
  }

  // Calculate total amount
  const days = Math.ceil(
    (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
  );
  const totalAmount = days * listing.pricePerDay;

  // Create booking
  return prisma.booking.create({
    data: {
      listingId,
      userId,
      startDate,
      endDate,
      totalAmount,
      status: BookingStatus.PENDING,
    },
  });
};

export const getUserBookings = async (userId: string) => {
  return prisma.booking.findMany({
    where: { userId },
    include: {
      listing: {
        include: {
          owner: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      },
      payment: true,
    },
    orderBy: { createdAt: 'desc' },
  });
};

export const getOwnerBookings = async (ownerId: string) => {
  return prisma.booking.findMany({
    where: {
      listing: {
        ownerId,
      },
    },
    include: {
      listing: true,
      user: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
      payment: true,
    },
    orderBy: { createdAt: 'desc' },
  });
};

export const updateBookingStatus = async (
  bookingId: string,
  status: 'CONFIRMED' | 'CANCELLED',
  actorId: string,
  actorRole: string
) => {
  // Find booking with listing owner
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      listing: true,
    },
  });

  if (!booking) {
    const error: ApiError = new Error('Booking not found');
    error.statusCode = 404;
    throw error;
  }

  const isOwner = booking.listing.ownerId === actorId;
  const isAdmin = actorRole === 'ADMIN';
  if (!isOwner && !isAdmin) {
    const error: ApiError = new Error('Not authorized to modify this booking');
    error.statusCode = 403;
    throw error;
  }

  // Update status
  const updated = await prisma.booking.update({
    where: { id: bookingId },
    data: { status: status as BookingStatus },
    include: {
      listing: true,
      user: {
        select: { id: true, name: true, email: true },
      },
      payment: true,
    },
  });

  return updated;
};
