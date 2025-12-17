# Cloudinary Integration - Testing Guide

This guide provides comprehensive testing examples for the Cloudinary image upload integration.

## Prerequisites

Before testing, ensure you have:

1. **Cloudinary Account**: Sign up at https://cloudinary.com (free tier is sufficient)
2. **Environment Variables**: Add to your `.env` file:
   ```env
   CLOUDINARY_CLOUD_NAME="your_cloud_name"
   CLOUDINARY_API_KEY="your_api_key"
   CLOUDINARY_API_SECRET="your_api_secret"
   ```
3. **Authentication Token**: You need a valid JWT token from logging in as an OWNER or ADMIN user

## Getting Your Cloudinary Credentials

1. Go to https://cloudinary.com
2. Sign up for a free account
3. Navigate to your Dashboard
4. Copy the following values:
   - **Cloud Name**: Found at the top of the dashboard
   - **API Key**: Found in the "Account Details" section
   - **API Secret**: Click "Reveal" in the "Account Details" section

## API Testing with curl

### 1. Create a Listing with Images

```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "title=Beautiful Wedding Venue" \
  -F "description=A stunning outdoor venue perfect for weddings and events" \
  -F "category=venue" \
  -F "city=Mumbai" \
  -F "pincode=400001" \
  -F "date=2025-12-25T00:00:00Z" \
  -F "price=15000" \
  -F "images=@/path/to/image1.jpg" \
  -F "images=@/path/to/image2.jpg" \
  -F "images=@/path/to/image3.png"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid-here",
    "title": "Beautiful Wedding Venue",
    "description": "A stunning outdoor venue...",
    "category": "venue",
    "pricePerDay": 15000,
    "location": "Mumbai, 400001",
    "images": [
      "https://res.cloudinary.com/YOUR_CLOUD/image/upload/v.../eventos/listings/abc123.jpg",
      "https://res.cloudinary.com/YOUR_CLOUD/image/upload/v.../eventos/listings/def456.jpg",
      "https://res.cloudinary.com/YOUR_CLOUD/image/upload/v.../eventos/listings/ghi789.png"
    ],
    "isActive": true,
    "createdAt": "2025-12-17T...",
    "updatedAt": "2025-12-17T..."
  }
}
```

### 2. Get All Listings

```bash
curl -X GET "http://localhost:3000/api/listings?category=venue" \
  -H "Content-Type: application/json"
```

### 3. Get Listing by ID

```bash
curl -X GET http://localhost:3000/api/listings/YOUR_LISTING_ID \
  -H "Content-Type: application/json"
```

### 4. Delete a Listing (Also Deletes Images from Cloudinary)

```bash
curl -X DELETE http://localhost:3000/api/listings/YOUR_LISTING_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

This will:
1. Delete all images from Cloudinary
2. Delete the listing from the database

---

## API Testing with Postman

### Create Listing with Images

1. **Method**: POST
2. **URL**: `http://localhost:3000/api/listings`
3. **Headers**:
   - `Authorization`: `Bearer YOUR_JWT_TOKEN`
4. **Body** (form-data):
   | Key | Type | Value |
   |-----|------|-------|
   | title | Text | Beautiful Wedding Venue |
   | description | Text | A stunning venue... |
   | category | Text | venue |
   | city | Text | Mumbai |
   | pincode | Text | 400001 |
   | date | Text | 2025-12-25T00:00:00Z |
   | price | Text | 15000 |
   | images | File | [Select image file 1] |
   | images | File | [Select image file 2] |
   | images | File | [Select image file 3] |

5. Click **Send**

**Note**: In Postman, you can add multiple files with the same key name (`images`) to upload multiple images.

---

## Validation Tests

### Test 1: Invalid File Type

Try uploading a non-image file (e.g., `.txt` or `.pdf`):

```bash
curl -X POST http://localhost:3000/api/listings \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "title=Test Listing" \
  -F "description=Test" \
  -F "category=venue" \
  -F "city=Mumbai" \
  -F "pincode=400001" \
  -F "date=2025-12-25T00:00:00Z" \
  -F "price=5000" \
  -F "images=@/path/to/document.pdf"
```

**Expected Response:**
```json
{
  "success": false,
  "error": "Image upload failed: Invalid file type: application/pdf. Allowed types: image/jpeg, image/jpg, image/png, image/webp",
  "code": "UPLOAD_ERROR"
}
```

### Test 2: File Too Large

Try uploading a file > 10MB:

**Expected Response:**
```json
{
  "success": false,
  "error": "Image upload failed: File size exceeds limit: 12345678 bytes. Maximum allowed: 10485760 bytes (10MB)",
  "code": "UPLOAD_ERROR"
}
```

### Test 3: Valid Image Formats

Test with different valid formats:
- `.jpg` / `.jpeg` ✅
- `.png` ✅
- `.webp` ✅

---

## Cloudinary Dashboard Verification

1. **Log in** to your Cloudinary account
2. **Navigate** to Media Library
3. **Check** the `eventos/listings/` folder
4. **Verify** your uploaded images appear there
5. **Click** on an image to see:
   - Public ID
   - Secure URL
   - File size
   - Dimensions
   - Upload date

---

## Flutter App Testing

### Test Image Upload from Flutter

The Flutter app already uses multipart requests via `ListingsRepository.createListing()`. No changes are needed on the Flutter side!

**Test Steps:**

1. Open the Flutter app
2. Navigate to "Create Listing" screen
3. Fill in all required fields
4. Select 1-3 images from gallery/camera
5. Submit the listing
6. **Verify**:
   - Images upload successfully
   - Loading indicator shows during upload
   - Success message appears
   - Listing appears with Cloudinary URLs in listing details

### Test Image Display

1. Navigate to any listing screen (Home, Packages, Decor, etc.)
2. **Verify**:
   - Images load from Cloudinary URLs
   - Loading placeholders show while images load
   - Error handling works if image URL is broken
   - Images are cached properly

---

## Production Deployment Testing (Render)

### 1. Add Environment Variables to Render

1. Go to your Render dashboard
2. Select your backend service
3. Navigate to **Environment** tab
4. Add the following variables:
   ```
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```
5. Click **Save Changes**

### 2. Deploy and Test

1. **Deploy** your backend to Render
2. **Create a listing** with images via the deployed API
3. **Verify** images appear in Cloudinary dashboard
4. **Trigger a redeploy** on Render
5. **Verify** images are still accessible (critical test!)

Expected: All images should remain accessible because they're stored on Cloudinary, not locally.

---

## Troubleshooting

### Error: "Cloudinary configuration is incomplete"

**Cause**: Missing environment variables

**Solution**: Ensure all three Cloudinary variables are set in your `.env` file:
```env
CLOUDINARY_CLOUD_NAME="..."
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."
```

### Error: "Invalid API Key"

**Cause**: Incorrect Cloudinary credentials

**Solution**: 
1. Double-check your credentials in Cloudinary dashboard
2. Ensure no extra spaces in `.env` file
3. Restart your backend server after updating `.env`

### Images Not Uploading

**Check**:
1. Server logs for Cloudinary errors
2. File size (must be < 10MB)
3. File type (must be jpeg, jpg, png, or webp)
4. Network connectivity to Cloudinary

### Images Not Deleting

**Note**: Image deletion is non-blocking. If deletion fails, the listing will still be deleted from the database. Check server logs for details.

---

## Performance Notes

- **Upload Speed**: Depends on image size and network speed
- **Parallel Uploads**: Multiple images are uploaded in parallel for faster processing
- **CDN Delivery**: Cloudinary automatically serves images via CDN for fast global delivery
- **Auto Optimization**: Cloudinary automatically optimizes image quality and format

---

## Free Tier Limits

Cloudinary free tier includes:
- **25 GB** Storage
- **25 GB** Bandwidth per month
- **Unlimited** transformations
- **500** images/videos

This is sufficient for initial development and testing. Upgrade to paid plans as your app scales.

---

## Next Steps

1. ✅ Test locally with curl/Postman
2. ✅ Verify Cloudinary dashboard shows uploads
3. ✅ Test Flutter app image upload
4. ✅ Deploy to Render with environment variables
5. ✅ Test production deployment
6. ✅ Verify images persist after redeploy

Congratulations! Your app now has permanent, scalable image storage with Cloudinary! 🎉
