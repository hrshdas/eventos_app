import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';

export const validateRequest = (schema: ZodSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      // Debug: Log what we're validating
      if (req.path.includes('/listings') && req.method === 'POST') {
        console.log('Validating request body:', JSON.stringify(req.body, null, 2));
      }
      
      schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        // Debug: Log validation errors
        if (req.path.includes('/listings') && req.method === 'POST') {
          console.log('Validation errors:', error.errors);
        }
        
        res.status(400).json({
          success: false,
          error: 'Validation error',
          details: error.errors.map((e) => ({
            path: e.path.join('.'),
            message: e.message,
          })),
        });
      } else {
        next(error);
      }
    }
  };
};

