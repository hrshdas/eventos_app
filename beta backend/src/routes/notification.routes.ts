import { Router } from 'express';
import { z } from 'zod';
import { authMiddleware } from '../middleware/authMiddleware';
import { prisma } from '../config/db';
import { validateRequest } from '../middleware/validateRequest';

const router = Router();

const listQuery = z.object({
  query: z.object({
    cursor: z.string().uuid().optional(),
    limit: z.coerce.number().min(1).max(100).optional(),
  }),
});

const readParam = z.object({
  params: z.object({ id: z.string().uuid() }),
});

router.get('/', authMiddleware, validateRequest(listQuery), async (req, res, next) => {
  try {
    if (!req.user) return res.status(401).json({ success: false, error: 'Unauthorized' });
    const { cursor, limit = 20 } = req.query as { cursor?: string; limit?: number };

    const notifications = await prisma.notification.findMany({
      where: { userId: req.user.id },
      orderBy: { createdAt: 'desc' },
      take: limit,
      ...(cursor ? { skip: 1, cursor: { id: cursor } } : {}),
    });

    res.json({ success: true, data: notifications });
  } catch (e) {
    next(e);
  }
});

router.patch('/:id/read', authMiddleware, validateRequest(readParam), async (req, res, next) => {
  try {
    if (!req.user) return res.status(401).json({ success: false, error: 'Unauthorized' });
    const { id } = req.params as { id: string };

    const updated = await prisma.notification.update({
      where: { id },
      data: { readAt: new Date() },
    });

    res.json({ success: true, data: updated });
  } catch (e) {
    next(e);
  }
});

router.patch('/read-all', authMiddleware, async (req, res, next) => {
  try {
    if (!req.user) return res.status(401).json({ success: false, error: 'Unauthorized' });

    await prisma.notification.updateMany({
      where: { userId: req.user.id, readAt: null },
      data: { readAt: new Date() },
    });

    res.json({ success: true });
  } catch (e) {
    next(e);
  }
});

export default router;
