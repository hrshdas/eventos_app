import express, { Express } from 'express';
import path from 'path';
import { errorHandler } from './middleware/errorHandler';
import { logger } from './utils/logger';
import cors from 'cors';
import { config } from './config/env';

// Routes
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import listingRoutes from './routes/listing.routes';
import bookingRoutes from './routes/booking.routes';
import paymentRoutes from './routes/payment.routes';
import aiRoutes from './routes/ai.routes';
import notificationRoutes from './routes/notification.routes';

export const createApp = (): Express => {
  const app = express();

  // Middleware for webhook (must be before express.json())
  app.use('/api/payments/webhook', express.raw({ type: 'application/json' }));

  // CORS - allow all origins temporarily + credentials (mobile/web/Postman)
  app.use(
    cors({
      origin: true,
      credentials: true,
    })
  );
  // Handle preflight requests
  app.options('*', cors());

  // Body parsers
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Note: Images are now served from Cloudinary CDN, no local static file serving needed


  // Health check
  app.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
  });
  app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
  });

  // API root - helpful message
  app.get('/api', (req, res) => {
    res.status(200).json({
      status: 'ok',
      message: 'Eventos API is running',
      routes: [
        'GET /api/health',
        'GET /api/listings',
        'GET /api/listings/:id',
        'POST /api/auth/signup',
        'POST /api/auth/login',
        'POST /api/listings'
      ],
    });
  });

  // API Routes
  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/listings', listingRoutes);
  app.use('/api/bookings', bookingRoutes);
  app.use('/api/payments', paymentRoutes);
  app.use('/api/notifications', notificationRoutes);
  app.use('/api/ai', aiRoutes);

  // Error handler (must be last)
  app.use(errorHandler);

  return app;
};
