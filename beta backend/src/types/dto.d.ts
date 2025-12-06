/**
 * Data Transfer Objects (DTOs)
 * Used to transform Prisma models for API responses (exclude sensitive fields)
 */

import { User, Listing, Booking, Payment, Review } from '@prisma/client';

/**
 * User DTO (excludes passwordHash)
 */
export interface UserDto {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Listing DTO with relations
 */
export interface ListingDto extends Omit<Listing, 'ownerId'> {
  owner?: {
    id: string;
    name: string;
    email: string;
  };
  reviews?: Array<{
    rating: number;
  }>;
  averageRating?: number;
  reviewCount?: number;
}

/**
 * Booking DTO with relations
 */
export interface BookingDto extends Booking {
  listing?: ListingDto;
  user?: {
    id: string;
    name: string;
    email: string;
  };
  payment?: PaymentDto | null;
}

/**
 * Payment DTO
 */
export interface PaymentDto extends Payment {
  booking?: BookingDto;
}

/**
 * Review DTO with relations
 */
export interface ReviewDto extends Review {
  user?: {
    id: string;
    name: string;
  };
  listing?: {
    id: string;
    title: string;
  };
}

