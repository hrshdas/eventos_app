import { Router } from 'express';
import {
  createListingController,
  getListingsController,
  getListingByIdController,
  updateListingController,
  deleteListingController,
} from '../controllers/listing.controller';
import { authMiddleware, requireRole } from '../middleware/authMiddleware';
import { validateRequest } from '../middleware/validateRequest';
import { createListingSchema, updateListingSchema } from '../validation/listing.schemas';

const router = Router();

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

