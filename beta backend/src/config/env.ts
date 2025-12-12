/**
 * Environment configuration loader
 * - Adds support for Google Sign-In client IDs per platform (ANDROID/IOS/WEB)
 * - Falls back to single GOOGLE_CLIENT_ID if specific ones are not provided
 */
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  // Database
  databaseUrl: process.env.DATABASE_URL || '',
  
  // JWT
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || '',
    refreshSecret: process.env.JWT_REFRESH_SECRET || '',
    accessExpiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },
  
  // Server
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  
  // Stripe
  stripe: {
    secretKey: process.env.STRIPE_SECRET_KEY || '',
    webhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  },
  
  // Razorpay
  razorpay: {
    keyId: process.env.RAZORPAY_KEY_ID || '',
    keySecret: process.env.RAZORPAY_KEY_SECRET || '',
  },
  
  // Google OAuth / Sign-In
  google: {
    // Back-compat single client id
    clientId: process.env.GOOGLE_CLIENT_ID || '',
    clientSecret: process.env.GOOGLE_CLIENT_SECRET || '',
    // Platform-specific client IDs (optional)
    clientIdAndroid: process.env.GOOGLE_CLIENT_ID_ANDROID || '',
    clientIdIos: process.env.GOOGLE_CLIENT_ID_IOS || '',
    clientIdWeb: process.env.GOOGLE_CLIENT_ID_WEB || '',
    // Computed audiences to validate against
    get audiences(): string[] {
      const ids = [
        process.env.GOOGLE_CLIENT_ID_ANDROID || '',
        process.env.GOOGLE_CLIENT_ID_IOS || '',
        process.env.GOOGLE_CLIENT_ID_WEB || '',
        process.env.GOOGLE_CLIENT_ID || '',
      ].map((s) => s.trim()).filter(Boolean);
      // Ensure unique
      return Array.from(new Set(ids));
    },
  },
  
  // CORS
  cors: {
    allowedOrigins: (process.env.CORS_ALLOWED_ORIGINS
      ? process.env.CORS_ALLOWED_ORIGINS.split(',').map((s) => s.trim()).filter(Boolean)
      : ['http://localhost:3000', 'http://localhost:5173', 'http://localhost:8080']
    ),
  },
};

// Validate required environment variables
const requiredEnvVars = [
  'DATABASE_URL',
  'JWT_ACCESS_SECRET',
  'JWT_REFRESH_SECRET',
];

if (config.nodeEnv === 'production') {
  requiredEnvVars.forEach((varName) => {
    if (!process.env[varName]) {
      throw new Error(`Missing required environment variable: ${varName}`);
    }
  });
}
