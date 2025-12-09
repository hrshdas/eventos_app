import { z } from 'zod';

/**
 * Listing validation schemas
 */

export const createListingSchema = z.object({
  body: z.object({
    title: z.string().min(1, 'Title is required').max(200, 'Title is too long'),
    description: z.string().min(1, 'Description is required').max(5000, 'Description is too long'),
    category: z.string().min(1, 'Category is required').max(100, 'Category is too long'),
    // Accept both 'price' (from frontend) and 'pricePerDay' (legacy)
    // FormData sends strings, so we need to handle both number and string
    price: z.union([
      z.number().positive('Price must be positive').int('Price must be an integer'),
      z.string().transform((val) => {
        const num = parseInt(val, 10);
        if (isNaN(num) || num <= 0) throw new Error('Price must be a positive integer');
        return num;
      }),
    ]).optional(),
    pricePerDay: z.union([
      z.number().positive('Price must be positive').int('Price must be an integer'),
      z.string().transform((val) => {
        const num = parseInt(val, 10);
        if (isNaN(num) || num <= 0) throw new Error('Price must be a positive integer');
        return num;
      }),
    ]).optional(),
    // Accept both 'location' (legacy) and 'city' + 'pincode' (from frontend)
    location: z.string().min(1).max(200).optional(),
    city: z.string().min(1, 'City is required').max(100, 'City is too long').optional(),
    pincode: z.string().min(1, 'Pincode is required').max(10, 'Pincode is too long').optional(),
    // Optional fields from frontend
    date: z.string().optional(),
    time: z.string().optional(),
    capacity: z.union([
      z.number().int().positive().optional(),
      z.string().transform((val) => {
        const num = parseInt(val, 10);
        return isNaN(num) ? undefined : num;
      }).optional(),
    ]).optional(),
    images: z.array(z.string().url('Invalid image URL')).max(10, 'Maximum 10 images allowed').optional(),
  }).refine(
    (data) => {
      // Either 'price' or 'pricePerDay' must be provided
      return data.price !== undefined || data.pricePerDay !== undefined;
    },
    {
      message: 'Price is required',
      path: ['price'],
    }
  ).refine(
    (data) => {
      // Either 'location' or both 'city' and 'pincode' must be provided
      return data.location !== undefined || (data.city !== undefined && data.pincode !== undefined);
    },
    {
      message: 'Location is required',
      path: ['location'],
    }
  ),
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

