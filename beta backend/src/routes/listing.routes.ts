import { Router } from 'express';
import { z } from 'zod';
import {
  createListingController,
  getListingsController,
  getListingByIdController,
  updateListingController,
  deleteListingController,
} from '../controllers/listing.controller';
import { authMiddleware, requireRole } from '../middleware/authMiddleware';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const createListingSchema = z.object({
  body: z.object({
    title: z.string().min(1, 'Title is required'),
    description: z.string().min(1, 'Description is required'),
    category: z.string().min(1, 'Category is required'),
    pricePerDay: z.number().positive('Price must be positive'),
    location: z.string().min(1, 'Location is required'),
    images: z.array(z.string().url()).optional(),
  }),
});

const updateListingSchema = z.object({
  body: z.object({
    title: z.string().min(1).optional(),
    description: z.string().min(1).optional(),
    category: z.string().min(1).optional(),
    pricePerDay: z.number().positive().optional(),
    location: z.string().min(1).optional(),
    images: z.array(z.string().url()).optional(),
    isActive: z.boolean().optional(),
  }),
});

// Public routes
router.get('/', getListingsController);
router.get('/:id', getListingByIdController);

// Protected routes
router.post(
  '/',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  validateRequest(createListingSchema),
  createListingController
);

router.patch(
  '/:id',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  validateRequest(updateListingSchema),
  updateListingController
);

router.delete(
  '/:id',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  deleteListingController
);

export default router;

