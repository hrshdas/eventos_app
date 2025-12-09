import { Request } from 'express';
import * as fs from 'fs';
import * as path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../config/env';

const UPLOAD_DIR = path.join(process.cwd(), 'uploads', 'listings');

// Ensure upload directory exists
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

/**
 * Get base URL for image serving from request or config
 */
const getBaseUrl = (req?: Request): string => {
  // Use BASE_URL from environment if set
  if (process.env.BASE_URL) {
    return process.env.BASE_URL.replace(/\/$/, '');
  }
  
  // Use request host if available
  if (req) {
    const protocol = req.protocol || 'http';
    const host = req.get('host') || `localhost:${config.port}`;
    return `${protocol}://${host}`;
  }
  
  // Fallback to localhost with port
  return `http://localhost:${config.port}`;
};

/**
 * Save uploaded files and return their URLs
 */
export const saveListingImages = async (
  files: Express.Multer.File[],
  req?: Request
): Promise<string[]> => {
  if (!files || files.length === 0) {
    return [];
  }

  const imageUrls: string[] = [];
  const baseUrl = getBaseUrl(req);

  for (const file of files) {
    // Generate unique filename
    const fileExtension = path.extname(file.originalname);
    const fileName = `${uuidv4()}${fileExtension}`;
    const filePath = path.join(UPLOAD_DIR, fileName);

    // Save file
    fs.writeFileSync(filePath, file.buffer);

    // Generate absolute URL
    const imageUrl = `${baseUrl}/uploads/listings/${fileName}`;
    imageUrls.push(imageUrl);
  }

  return imageUrls;
};

/**
 * Delete image files by URLs
 */
export const deleteListingImages = async (imageUrls: string[]): Promise<void> => {
  for (const url of imageUrls) {
    try {
      const fileName = path.basename(url);
      const filePath = path.join(UPLOAD_DIR, fileName);
      
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    } catch (error) {
      console.error(`Failed to delete image ${url}:`, error);
    }
  }
};

