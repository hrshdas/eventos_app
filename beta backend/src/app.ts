import express, { Express } from 'express';
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

export const createApp = (): Express => {
  const app = express();

  // Middleware for webhook (must be before express.json())
  app.use('/api/payments/webhook', express.raw({ type: 'application/json' }));

  // Middleware
  app.use(
    cors({
      origin: config.cors.allowedOrigins,
      credentials: true,
    })
  );
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Health check
  app.get('/health', (req, res) => {
    res.status(200).json({
      success: true,
      message: 'Server is running',
      timestamp: new Date().toISOString(),
    });
  });

  // API Routes
  app.use('/api/auth', authRoutes);
  app.use('/api/users', userRoutes);
  app.use('/api/listings', listingRoutes);
  app.use('/api/bookings', bookingRoutes);
  app.use('/api/payments', paymentRoutes);
  app.use('/api/ai', aiRoutes);

  // Error handler (must be last)
  app.use(errorHandler);

  return app;
};
