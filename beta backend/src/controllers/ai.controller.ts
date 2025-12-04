import { Request, Response, NextFunction } from 'express';
import { generatePartyPlan } from '../services/ai.service';

export const partyPlannerController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const plan = await generatePartyPlan(req.body);

    res.status(200).json({
      success: true,
      data: plan,
    });
  } catch (error) {
    next(error);
  }
};

