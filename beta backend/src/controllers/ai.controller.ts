import { Request, Response, NextFunction } from 'express';
import { generateEventPlan } from '../services/ai.service';
import { AIPlannerRequest } from '../validation/ai.schemas';

export const generatePlanController = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const planData: AIPlannerRequest = req.body;

    const result = await generateEventPlan(planData);

    res.status(200).json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

