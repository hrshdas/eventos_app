import { Router } from 'express';
import multer from 'multer';
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

// Configure multer for file uploads (in memory storage)
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit per file
    fieldSize: 10 * 1024 * 1024, // 10MB limit per field
  },
});

// Public routes
router.get('/', getListingsController);
router.get('/:id', getListingByIdController);

// Protected routes
router.post(
  '/',
  authMiddleware,
  requireRole('OWNER', 'ADMIN'),
  upload.any(), // Parse all fields and files from multipart/form-data
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

