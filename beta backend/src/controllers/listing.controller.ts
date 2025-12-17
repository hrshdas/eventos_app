import { Request, Response, NextFunction } from 'express';
import {
  createListing,
  getListings,
  getListingById,
  updateListing,
  deleteListing,
} from '../services/listing.service';
import { uploadImagesToCloudinary } from '../utils/cloudinaryUpload';


export const createListingController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        code: 'UNAUTHORIZED',
      });
    }

    // Transform frontend format to backend format
    const body = req.body;

    // Handle price: frontend sends 'price', backend expects 'pricePerDay'
    const pricePerDay = body.pricePerDay ?? body.price;
    if (pricePerDay === undefined) {
      return res.status(400).json({
        success: false,
        error: 'Price is required',
        code: 'VALIDATION_ERROR',
      });
    }

    // Handle location: frontend sends 'city' and 'pincode', backend expects 'location'
    let location = body.location;
    if (!location && body.city && body.pincode) {
      location = `${body.city}, ${body.pincode}`;
    }
    if (!location) {
      return res.status(400).json({
        success: false,
        error: 'Location is required (provide either location or both city and pincode)',
        code: 'VALIDATION_ERROR',
      });
    }

    // Convert price to number if it's a string (from FormData)
    const priceValue = typeof pricePerDay === 'string'
      ? parseInt(pricePerDay, 10)
      : pricePerDay;

    // Handle image uploads to Cloudinary
    const uploadedFiles = req.files as Express.Multer.File[] | undefined;
    let imageUrls: string[] = [];

    if (uploadedFiles && uploadedFiles.length > 0) {
      // Filter only image files (fieldname should be 'images')
      const imageFiles = uploadedFiles.filter(
        file => file.fieldname === 'images' && file.mimetype.startsWith('image/')
      );

      if (imageFiles.length > 0) {
        try {
          // Upload images to Cloudinary
          imageUrls = await uploadImagesToCloudinary(imageFiles);
          console.log(`✓ Uploaded ${imageUrls.length} images to Cloudinary`);
        } catch (error) {
          console.error('Cloudinary upload error:', error);
          return res.status(400).json({
            success: false,
            error: `Image upload failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
            code: 'UPLOAD_ERROR',
          });
        }
      }
    }

    // If images were provided in body (existing URLs), merge with uploaded ones
    if (body.images && Array.isArray(body.images)) {
      imageUrls = [...imageUrls, ...body.images];
    }

    const listing = await createListing({
      title: body.title,
      description: body.description,
      category: body.category,
      pricePerDay: priceValue,
      location: location,
      images: imageUrls,
      ownerId: req.user.id,
      userRole: req.user.role, // Pass role for auto-approval
    });

    res.status(201).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

export const getListingsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const filters = {
      category: req.query.category as string | undefined,
      location: req.query.location as string | undefined,
      minPrice: req.query.minPrice ? parseInt(req.query.minPrice as string) : undefined,
      maxPrice: req.query.maxPrice ? parseInt(req.query.maxPrice as string) : undefined,
      isActive: req.query.isActive !== 'false',
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
    };

    const result = await getListings(filters);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getListingByIdController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const listing = await getListingById(req.params.id);

    if (!listing) {
      return res.status(404).json({
        success: false,
        error: 'Listing not found',
        code: 'NOT_FOUND',
      });
    }

    res.status(200).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

export const updateListingController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        code: 'UNAUTHORIZED',
      });
    }

    const listing = await updateListing(req.params.id, req.body, req.user.id, req.user.role);

    res.status(200).json({
      success: true,
      data: listing,
    });
  } catch (error) {
    next(error);
  }
};

export const deleteListingController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        code: 'UNAUTHORIZED',
      });
    }

    await deleteListing(req.params.id, req.user.id, req.user.role);

    res.status(200).json({
      success: true,
      message: 'Listing deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};

// New: My Listings - only listings owned by the authenticated user
export const getMyListingsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Unauthorized',
        code: 'UNAUTHORIZED',
      });
    }

    const filters = {
      category: req.query.category as string | undefined,
      location: req.query.location as string | undefined,
      minPrice: req.query.minPrice ? parseInt(req.query.minPrice as string) : undefined,
      maxPrice: req.query.maxPrice ? parseInt(req.query.maxPrice as string) : undefined,
      isActive: req.query.isActive !== 'false',
      page: req.query.page ? parseInt(req.query.page as string) : 1,
      limit: req.query.limit ? parseInt(req.query.limit as string) : 10,
      ownerId: req.user.id,
    } as const;

    const result = await getListings(filters);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
