import { Request, Response, NextFunction } from 'express';
import {
  createBooking,
  getUserBookings,
  getOwnerBookings,
  updateBookingStatus,
} from '../services/booking.service';

export const createBookingController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const booking = await createBooking({
      ...req.body,
      userId: req.user.id,
      startDate: new Date(req.body.startDate),
      endDate: new Date(req.body.endDate),
    });

    res.status(201).json({
      success: true,
      data: booking,
    });
  } catch (error) {
    next(error);
  }
};

export const getMyBookingsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const bookings = await getUserBookings(req.user.id);

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

export const getOwnerBookingsController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const bookings = await getOwnerBookings(req.user.id);

    res.status(200).json({
      success: true,
      data: bookings,
    });
  } catch (error) {
    next(error);
  }
};

export const updateBookingStatusController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    if (!req.user) {
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    const bookingId = req.params.id;
    const { status } = req.body as { status: 'CONFIRMED' | 'CANCELLED' };

    const updated = await updateBookingStatus(
      bookingId,
      status,
      req.user.id,
      req.user.role
    );

    res.status(200).json({ success: true, data: updated });
  } catch (error) {
    next(error);
  }
};
