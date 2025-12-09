// API configuration
// Base URLs for development and production environments

// For physical device testing, use your laptop's IP address
// For Android emulator, use: http://10.0.2.2:3000/api
// For iOS simulator, use: http://localhost:3000/api
// Backend mounts routes under /api/* (no /v1 prefix)
const String baseUrlDev = 'http://192.168.1.43:3000/api';
const String baseUrlProd = 'https://api.eventos_db.xyz/api/v1';

// Environment flag - set to true for production builds
// In the future, this can be replaced with Flutter flavors or build configurations
const bool kIsProd = false;

// Get the current base URL based on environment
String get baseUrl => kIsProd ? baseUrlProd : baseUrlDev;

