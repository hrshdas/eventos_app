import { prisma } from '../config/db';
import { Listing, Prisma } from '@prisma/client';
import { ApiError } from '../middleware/errorHandler';

export interface CreateListingData {
  ownerId: string;
  title: string;
  description: string;
  category: string;
  pricePerDay: number;
  location: string;
  images?: string[];
  userRole?: string; // For auto-approval of OWNER accounts
}

export interface UpdateListingData {
  title?: string;
  description?: string;
  category?: string;
  pricePerDay?: number;
  location?: string;
  images?: string[];
  isActive?: boolean;
}

export interface ListingFilters {
  category?: string;
  location?: string;
  minPrice?: number;
  maxPrice?: number;
  isActive?: boolean;
  ownerId?: string;
  page?: number;
  limit?: number;
}

export const createListing = async (
  data: CreateListingData
): Promise<Listing> => {
  // Immediately list newly created listings
  const isActive = true;
  
  return prisma.listing.create({
    data: {
      ownerId: data.ownerId,
      title: data.title,
      description: data.description,
      category: data.category,
      pricePerDay: data.pricePerDay,
      location: data.location,
      images: data.images || [],
      isActive: isActive, // Always active on creation
    },
  });
};

export const getListings = async (
  filters: ListingFilters = {}
): Promise<{ listings: Listing[]; total: number; page: number; limit: number }> => {
  const {
    category,
    location,
    minPrice,
    maxPrice,
    isActive = true,
    ownerId,
    page = 1,
    limit = 10,
  } = filters;

  const skip = (page - 1) * limit;

  const where: Prisma.ListingWhereInput = {
    isActive,
    ...(category && { category }),
    ...(location && { location: { contains: location, mode: 'insensitive' } }),
    ...(minPrice !== undefined && { pricePerDay: { gte: minPrice } }),
    ...(maxPrice !== undefined && { pricePerDay: { lte: maxPrice } }),
    ...(ownerId && { ownerId }),
  };

  const [listings, total] = await Promise.all([
    prisma.listing.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        owner: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
        reviews: {
          select: {
            rating: true,
          },
        },
      },
    }),
    prisma.listing.count({ where }),
  ]);

  return {
    listings: listings as any,
    total,
    page,
    limit,
  };
};

export const getListingById = async (id: string): Promise<Listing | null> => {
  const listing = await prisma.listing.findUnique({
    where: { id },
    include: {
      owner: {
        select: {
          id: true,
          name: true,
          email: true,
        },
      },
      reviews: {
        include: {
          user: {
            select: {
              id: true,
              name: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        take: 10,
      },
    },
  });

  return listing as any;
};

export const updateListing = async (
  id: string,
  data: UpdateListingData,
  userId: string,
  userRole?: string
): Promise<Listing> => {
  // Check if listing exists and user owns it
  const listing = await prisma.listing.findUnique({
    where: { id },
  });

  if (!listing) {
    const error: ApiError = new Error('Listing not found');
    error.statusCode = 404;
    throw error;
  }

  // Allow if owner or admin
  const isOwner = listing.ownerId === userId;
  const isAdmin = userRole === 'ADMIN';
  if (!isOwner && !isAdmin) {
    const error: ApiError = new Error('Not authorized to modify this listing');
    error.statusCode = 403;
    throw error;
  }

  return prisma.listing.update({
    where: { id },
    data,
  });
};

export const deleteListing = async (
  id: string,
  userId: string,
  userRole: string
): Promise<void> => {
  const listing = await prisma.listing.findUnique({
    where: { id },
  });

  if (!listing) {
    const error: ApiError = new Error('Listing not found');
    error.statusCode = 404;
    throw error;
  }

  if (listing.ownerId !== userId && userRole !== 'ADMIN') {
    const error: ApiError = new Error('Not authorized to modify this listing');
    error.statusCode = 403;
    throw error;
  }

  await prisma.listing.delete({
    where: { id },
  });
};
