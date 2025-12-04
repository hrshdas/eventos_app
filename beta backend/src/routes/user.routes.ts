import { Router } from 'express';
import { authMiddleware } from '../middleware/authMiddleware';
import { prisma } from '../config/db';

const router = Router();

// Get current user profile
router.get('/me', authMiddleware, async (req, res, next) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
});

export default router;

