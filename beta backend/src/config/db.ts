import { PrismaClient } from '@prisma/client';
import { config } from './env';

function withNeonParams(urlStr: string): string {
  try {
    const url = new URL(urlStr);
    // Ensure SSL and connect timeout
    if (!url.searchParams.has('sslmode')) {
      url.searchParams.set('sslmode', 'require');
    }
    if (!url.searchParams.has('connect_timeout')) {
      url.searchParams.set('connect_timeout', '10');
    }
    return url.toString();
  } catch {
    // If URL parsing fails, fall back to original
    return urlStr;
  }
}

const effectiveDbUrl = withNeonParams(config.databaseUrl);

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: config.nodeEnv === 'development' ? ['query', 'error', 'warn'] : ['error'],
    datasources: {
      db: {
        url: effectiveDbUrl,
      },
    },
  });

if (config.nodeEnv !== 'production') {
  globalForPrisma.prisma = prisma;
}

export default prisma;
