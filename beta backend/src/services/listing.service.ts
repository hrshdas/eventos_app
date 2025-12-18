import { prisma } from '../config/db';
import { Listing, Prisma } from '@prisma/client';
import { ApiError } from '../middleware/errorHandler';
import { deleteImagesFromCloudinary } from '../utils/cloudinaryUpload';

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
  search?: string;
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
    search,
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
    ...(search && { title: { contains: search, mode: 'insensitive' } }),
  };

  // If search is provided, we want to sort by relevance (exact matches first, then partial matches)
  // Otherwise, sort by creation date
  const orderBy: Prisma.ListingOrderByWithRelationInput[] = search
    ? [
      // Prisma doesn't support direct relevance sorting, so we'll sort client-side after fetching
      { createdAt: 'desc' }
    ]
    : [{ createdAt: 'desc' }];

  const [listings, total] = await Promise.all([
    prisma.listing.findMany({
      where,
      skip,
      take: limit,
      orderBy,
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

  // Sort by relevance if search query is provided
  let sortedListings = listings as any[];
  if (search) {
    const searchLower = search.toLowerCase();
    sortedListings = [...listings].sort((a, b) => {
      const aTitle = a.title.toLowerCase();
      const bTitle = b.title.toLowerCase();

      // Exact match comes first
      const aExact = aTitle === searchLower;
      const bExact = bTitle === searchLower;
      if (aExact && !bExact) return -1;
      if (!aExact && bExact) return 1;

      // Starts with search query comes next
      const aStarts = aTitle.startsWith(searchLower);
      const bStarts = bTitle.startsWith(searchLower);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;

      // Position of search term (earlier is better)
      const aIndex = aTitle.indexOf(searchLower);
      const bIndex = bTitle.indexOf(searchLower);
      if (aIndex !== bIndex) return aIndex - bIndex;

      // Finally, sort by creation date
      return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
    });
  }

  return {
    listings: sortedListings,
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

  // Delete images from Cloudinary first
  if (listing.images && listing.images.length > 0) {
    try {
      const deletedCount = await deleteImagesFromCloudinary(listing.images);
      console.log(`✓ Deleted ${deletedCount}/${listing.images.length} images from Cloudinary`);
    } catch (error) {
      console.error('Error deleting images from Cloudinary:', error);
      // Continue with listing deletion even if image deletion fails
    }
  }

  await prisma.listing.delete({
    where: { id },
  });
};
