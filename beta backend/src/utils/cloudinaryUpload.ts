import { UploadApiResponse, UploadApiErrorResponse } from 'cloudinary';
import { cloudinary } from '../config/cloudinary.config';

/**
 * Allowed image file types
 */
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];

/**
 * Maximum file size in bytes (10MB)
 */
const MAX_FILE_SIZE = 10 * 1024 * 1024;

/**
 * Upload a single image to Cloudinary
 * 
 * @param file - Multer file object with buffer
 * @returns Secure URL of the uploaded image
 */
export const uploadImageToCloudinary = async (
    file: Express.Multer.File
): Promise<string> => {
    return new Promise((resolve, reject) => {
        // Validate file type
        if (!ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
            return reject(
                new Error(
                    `Invalid file type: ${file.mimetype}. Allowed types: ${ALLOWED_IMAGE_TYPES.join(', ')}`
                )
            );
        }

        // Validate file size
        if (file.size > MAX_FILE_SIZE) {
            return reject(
                new Error(
                    `File size exceeds limit: ${file.size} bytes. Maximum allowed: ${MAX_FILE_SIZE} bytes (10MB)`
                )
            );
        }

        // Upload to Cloudinary using upload_stream
        const uploadStream = cloudinary.uploader.upload_stream(
            {
                folder: 'eventos/listings', // Organize uploads in folders
                resource_type: 'image',
                allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
                transformation: [
                    {
                        quality: 'auto', // Automatic quality optimization
                        fetch_format: 'auto', // Automatic format selection
                    },
                ],
            },
            (
                error: UploadApiErrorResponse | undefined,
                result: UploadApiResponse | undefined
            ) => {
                if (error) {
                    console.error('Cloudinary upload error:', error);
                    return reject(new Error(`Cloudinary upload failed: ${error.message}`));
                }

                if (!result || !result.secure_url) {
                    return reject(new Error('Cloudinary upload failed: No URL returned'));
                }

                console.log('✓ Image uploaded to Cloudinary:', result.secure_url);
                resolve(result.secure_url);
            }
        );

        // Pipe the file buffer to Cloudinary
        uploadStream.end(file.buffer);
    });
};

/**
 * Upload multiple images to Cloudinary
 * 
 * @param files - Array of Multer file objects
 * @returns Array of secure URLs
 */
export const uploadImagesToCloudinary = async (
    files: Express.Multer.File[]
): Promise<string[]> => {
    if (!files || files.length === 0) {
        return [];
    }

    try {
        // Upload all files in parallel
        const uploadPromises = files.map((file) => uploadImageToCloudinary(file));
        const urls = await Promise.all(uploadPromises);
        return urls;
    } catch (error) {
        console.error('Error uploading images to Cloudinary:', error);
        throw error;
    }
};

/**
 * Delete an image from Cloudinary using its URL
 * 
 * @param imageUrl - Cloudinary URL of the image
 * @returns true if deleted successfully
 */
export const deleteImageFromCloudinary = async (
    imageUrl: string
): Promise<boolean> => {
    try {
        // Extract public_id from Cloudinary URL
        // URL format: https://res.cloudinary.com/{cloud_name}/image/upload/v{version}/{public_id}.{format}
        const urlParts = imageUrl.split('/');
        const uploadIndex = urlParts.indexOf('upload');

        if (uploadIndex === -1) {
            console.warn('Invalid Cloudinary URL format:', imageUrl);
            return false;
        }

        // Get everything after 'upload/v{version}/'
        const publicIdWithExtension = urlParts.slice(uploadIndex + 2).join('/');
        const publicId = publicIdWithExtension.replace(/\.[^/.]+$/, ''); // Remove extension

        // Delete from Cloudinary
        const result = await cloudinary.uploader.destroy(publicId);

        if (result.result === 'ok') {
            console.log('✓ Image deleted from Cloudinary:', publicId);
            return true;
        } else {
            console.warn('Failed to delete image from Cloudinary:', result);
            return false;
        }
    } catch (error) {
        console.error('Error deleting image from Cloudinary:', error);
        return false;
    }
};

/**
 * Delete multiple images from Cloudinary
 * 
 * @param imageUrls - Array of Cloudinary URLs
 * @returns Number of successfully deleted images
 */
export const deleteImagesFromCloudinary = async (
    imageUrls: string[]
): Promise<number> => {
    if (!imageUrls || imageUrls.length === 0) {
        return 0;
    }

    try {
        const deletePromises = imageUrls.map((url) => deleteImageFromCloudinary(url));
        const results = await Promise.all(deletePromises);
        const successCount = results.filter((success) => success).length;
        return successCount;
    } catch (error) {
        console.error('Error deleting images from Cloudinary:', error);
        return 0;
    }
};
