import { createApp } from './app';
import { config } from './config/env';
import { logger } from './utils/logger';
import { prisma } from './config/db';

const app = createApp();

const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('Database connected successfully');

    // Start server
    const port = config.port || 10000;
    const host = '0.0.0.0';
    app.listen(port, host, () => {
      logger.info(`Server is running on http://${host}:${port}`);
      logger.info(`Environment: ${config.nodeEnv}`);
      logger.info(`Health check: http://${host}:${port}/health`);

      // Print basic route map
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const routes: string[] = [];
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const stack = (app as any)._router?.stack ?? [];
      stack.forEach((layer: any) => {
        if (layer.route && layer.route.path) {
          const methods = Object.keys(layer.route.methods)
            .filter((m) => layer.route.methods[m])
            .map((m) => m.toUpperCase())
            .join(',');
          routes.push(`${methods} ${layer.route.path}`);
        } else if (layer.name === 'router' && layer.handle?.stack) {
          const mountPath = layer.regexp?.fast_slash ? '' : (layer.regexp?.source || '');
          layer.handle.stack.forEach((sublayer: any) => {
            if (sublayer.route && sublayer.route.path) {
              const methods = Object.keys(sublayer.route.methods)
                .filter((m) => sublayer.route.methods[m])
                .map((m) => m.toUpperCase())
                .join(',');
              routes.push(`${methods} ${mountPath} ${sublayer.route.path}`);
            }
          });
        }
      });
      logger.info('Registered routes:\n' + routes.join('\n'));

      // Sample URLs
      logger.info('Sample URLs:');
      logger.info(`- /api/health -> https://eventos-app-y5kf.onrender.com/api/health`);
      logger.info(`- /api/listings -> https://eventos-app-y5kf.onrender.com/api/listings`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT signal received: closing HTTP server');
  await prisma.$disconnect();
  process.exit(0);
});

startServer();
