import { v2 as cloudinary } from 'cloudinary';
import { config } from './env';

/**
 * Cloudinary Configuration
 * 
 * Initializes Cloudinary SDK with credentials from environment variables.
 * This must be called before any Cloudinary operations.
 */
export const configureCloudinary = (): void => {
    // Validate required environment variables
    if (!config.cloudinary.cloudName || !config.cloudinary.apiKey || !config.cloudinary.apiSecret) {
        throw new Error(
            'Cloudinary configuration is incomplete. Please set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET in your environment variables.'
        );
    }

    cloudinary.config({
        cloud_name: config.cloudinary.cloudName,
        api_key: config.cloudinary.apiKey,
        api_secret: config.cloudinary.apiSecret,
        secure: true, // Always use HTTPS URLs
    });

    console.log('✓ Cloudinary configured successfully');
};

// Export configured cloudinary instance
export { cloudinary };
