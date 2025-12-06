import { z } from 'zod';

/**
 * Listing validation schemas
 */

export const createListingSchema = z.object({
  body: z.object({
    title: z.string().min(1, 'Title is required').max(200, 'Title is too long'),
    description: z.string().min(1, 'Description is required').max(5000, 'Description is too long'),
    category: z.string().min(1, 'Category is required').max(100, 'Category is too long'),
    pricePerDay: z.number().positive('Price must be positive').int('Price must be an integer'),
    location: z.string().min(1, 'Location is required').max(200, 'Location is too long'),
    images: z.array(z.string().url('Invalid image URL')).max(10, 'Maximum 10 images allowed').optional(),
  }),
});

export const updateListingSchema = z.object({
  body: z.object({
    title: z.string().min(1).max(200).optional(),
    description: z.string().min(1).max(5000).optional(),
    category: z.string().min(1).max(100).optional(),
    pricePerDay: z.number().positive().int().optional(),
    location: z.string().min(1).max(200).optional(),
    images: z.array(z.string().url()).max(10).optional(),
    isActive: z.boolean().optional(),
  }),
});

