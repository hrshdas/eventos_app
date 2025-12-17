# Cloudinary Integration - Quick Reference

## Environment Variables Required

Add these to your `.env` file and Render dashboard:

```env
CLOUDINARY_CLOUD_NAME="your_cloud_name"
CLOUDINARY_API_KEY="your_api_key"
CLOUDINARY_API_SECRET="your_api_secret"
```

**Get credentials from**: https://cloudinary.com → Dashboard

---

## File Structure Changes

### New Files Created
- `src/config/cloudinary.config.ts` - Cloudinary SDK configuration
- `src/utils/cloudinaryUpload.ts` - Upload/delete utilities with validation
- `CLOUDINARY_TESTING_GUIDE.md` - Comprehensive testing guide

### Modified Files
- `src/config/env.ts` - Added Cloudinary environment variables
- `src/controllers/listing.controller.ts` - Uses Cloudinary uploads
- `src/services/listing.service.ts` - Deletes images from Cloudinary
- `src/app.ts` - Removed local static file serving
- `src/index.ts` - Initializes Cloudinary on startup
- `.env.example` - Added Cloudinary configuration
- `package.json` - Resolved merge conflict

### Deprecated Files
- `src/utils/fileUpload.ts` - No longer used (local storage)

---

## API Endpoints (No Changes)

All existing endpoints work the same way:
- `POST /api/listings` - Upload with images
- `GET /api/listings` - Get all listings
- `GET /api/listings/:id` - Get single listing
- `DELETE /api/listings/:id` - Delete listing + images

**Frontend compatibility**: ✅ No changes needed in Flutter app

---

## Image Upload Flow

### Before (Local Storage)
1. Multer receives uploaded file → Memory buffer
2. File saved to `uploads/listings/` directory
3. URL: `http://localhost:3000/uploads/listings/abc123.jpg`
4. **Problem**: Files lost on redeploy ❌

### After (Cloudinary)
1. Multer receives uploaded file → Memory buffer
2. File uploaded to Cloudinary via API
3. URL: `https://res.cloudinary.com/.../eventos/listings/abc123.jpg`
4. **Solution**: Files persist forever ✅

---

## Validation Rules

- **Allowed formats**: jpeg, jpg, png, webp
- **Max file size**: 10MB per image
- **Multiple uploads**: Supported (unlimited)
- **Folder structure**: `eventos/listings/`

---

## Image Deletion

When a listing is deleted via `DELETE /api/listings/:id`:
1. ✅ Images are deleted from Cloudinary
2. ✅ Listing is deleted from database
3. ✅ Saves Cloudinary storage space

---

## Testing Checklist

### Local Testing
- [ ] Add Cloudinary credentials to `.env`
- [ ] Start backend: `npm run dev`
- [ ] Upload listing with images via Postman/curl
- [ ] Verify Cloudinary dashboard shows images
- [ ] Test image URLs load in browser

### Production Testing (Render)
- [ ] Add Cloudinary env vars to Render dashboard
- [ ] Deploy backend
- [ ] Upload listing with images
- [ ] Trigger redeploy
- [ ] **Critical**: Verify images still load after redeploy ✅

---

## Cloudinary Free Tier

- ✅ 25 GB Storage
- ✅ 25 GB Bandwidth/month
- ✅ Unlimited transformations
- ✅ Sufficient for development & initial production

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Cloudinary configuration is incomplete" | Add all 3 env vars to `.env` |
| "Invalid API Key" | Double-check credentials from dashboard |
| Build fails | Run `npm install` then `npm run build` |
| Images not uploading | Check file size (<10MB) and format (jpeg/png/webp) |
| Server not starting | Verify env vars are set correctly |

---

## Quick Start Commands

```bash
# 1. Add credentials to .env
echo 'CLOUDINARY_CLOUD_NAME="your_cloud_name"' >> .env
echo 'CLOUDINARY_API_KEY="your_api_key"' >> .env
echo 'CLOUDINARY_API_SECRET="your_api_secret"' >> .env

# 2. Build and run
npm run build
npm run dev

# 3. Test upload (replace paths)
curl -X POST http://localhost:3000/api/listings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "title=Test Venue" \
  -F "description=Test" \
  -F "category=venue" \
  -F "city=Mumbai" \
  -F "pincode=400001" \
  -F "date=2025-12-25T00:00:00Z" \
  -F "price=5000" \
  -F "images=@/path/to/image.jpg"
```

---

## Support Links

- **Cloudinary Docs**: https://cloudinary.com/documentation
- **Dashboard**: https://cloudinary.com/console
- **Testing Guide**: See `CLOUDINARY_TESTING_GUIDE.md`
