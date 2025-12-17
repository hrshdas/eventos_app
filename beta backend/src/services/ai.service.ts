import Anthropic from '@anthropic-ai/sdk';
import { AIPlannerRequest } from '../validation/ai.schemas';
import { getListings } from './listing.service';

// ============================================
// TYPES
// ============================================

export interface AIPlan {
  theme: string;
  decor: string[];
  food: string[];
  music: string[];
  recommendedCategories: string[];
}

export interface AIPlanResponse {
  plan: AIPlan;
  matchingCounts: {
    [category: string]: number;
    total: number;
  };
  generatedBy: 'ai' | 'fallback';
  timestamp: string;
}

// ============================================
// CONFIGURATION
// ============================================

const AI_CONFIG = {
  enabled: process.env.AI_ENABLED === 'true',
  provider: process.env.AI_PROVIDER || 'anthropic',
  apiKey: process.env.ANTHROPIC_API_KEY || '',
  model: process.env.AI_MODEL || 'claude-3-haiku-20240307',
  timeout: parseInt(process.env.AI_TIMEOUT_MS || '8000'),
  maxTokens: 500,
  demoMode: process.env.DEMO_MODE === 'true',
};

// ============================================
// FALLBACK PLANS (by event type)
// ============================================

const FALLBACK_PLANS: Record<string, AIPlan> = {
  Birthday: {
    theme: 'Classic Birthday Celebration',
    decor: ['Balloon arrangements', 'Birthday banners', 'Table centerpieces'],
    food: ['Snacks and appetizers', 'Birthday cake', 'Beverages'],
    music: ['Music system rental', 'Playlist setup'],
    recommendedCategories: ['decor', 'rentals', 'packages'],
  },
  Wedding: {
    theme: 'Traditional Indian Wedding',
    decor: ['Floral mandap', 'Stage decoration', 'Entrance arch'],
    food: ['Multi-cuisine buffet', 'Live food counters', 'Dessert station'],
    music: ['Live band', 'DJ services', 'Sound system'],
    recommendedCategories: ['decor', 'talent', 'packages'],
  },
  Corporate: {
    theme: 'Professional Corporate Event',
    decor: ['Stage setup', 'Branding materials', 'Seating arrangements'],
    food: ['Corporate catering', 'Tea/coffee station', 'Snacks'],
    music: ['Sound system', 'Microphone setup'],
    recommendedCategories: ['rentals', 'packages', 'talent'],
  },
  Anniversary: {
    theme: 'Romantic Anniversary Celebration',
    decor: ['Floral arrangements', 'Fairy lights', 'Photo display'],
    food: ['Dinner buffet', 'Anniversary cake', 'Beverages'],
    music: ['Soft music setup', 'DJ for dancing'],
    recommendedCategories: ['decor', 'packages', 'talent'],
  },
  'Baby Shower': {
    theme: 'Joyful Baby Shower',
    decor: ['Pastel decorations', 'Baby-themed props', 'Balloon arch'],
    food: ['Light snacks', 'Cake', 'Mocktails'],
    music: ['Background music system'],
    recommendedCategories: ['decor', 'rentals', 'packages'],
  },
  Engagement: {
    theme: 'Elegant Engagement Ceremony',
    decor: ['Floral stage', 'Lighting setup', 'Seating decor'],
    food: ['Buffet dinner', 'Desserts', 'Welcome drinks'],
    music: ['DJ services', 'Sound system'],
    recommendedCategories: ['decor', 'talent', 'packages'],
  },
  Other: {
    theme: 'Memorable Event Celebration',
    decor: ['Custom decorations', 'Lighting', 'Seating arrangements'],
    food: ['Catering services', 'Refreshments'],
    music: ['Music system rental'],
    recommendedCategories: ['decor', 'rentals', 'packages'],
  },
};

// ============================================
// PROMPT BUILDER
// ============================================

const buildAIPrompt = (data: AIPlannerRequest): string => {
  const { eventType, location, guests, budget, description, date } = data;

  return `You are an expert Indian event planner. Generate a concise event plan in JSON format.

EVENT DETAILS:
- Type: ${eventType}
- Location: ${location}, India
- Guests: ${guests} people
- Budget: ₹${budget.toLocaleString('en-IN')}
- Date: ${new Date(date).toLocaleDateString('en-IN', { dateStyle: 'long' })}
- Theme/Vibe: ${description || 'Not specified'}

STRICT RULES:
1. Return ONLY valid JSON, no markdown, no explanations
2. Use Indian cultural context (festivals, traditions, local vendors)
3. DO NOT mention specific prices or costs
4. DO NOT recommend specific vendors or brands
5. Keep suggestions generic and achievable
6. Limit each array to 3-4 items maximum
7. recommendedCategories MUST be from: ["decor", "rentals", "talent", "packages"]

REQUIRED JSON FORMAT:
{
  "theme": "string (one-line theme name)",
  "decor": ["string", "string", "string"],
  "food": ["string", "string", "string"],
  "music": ["string", "string"],
  "recommendedCategories": ["decor", "talent"]
}

Generate the plan now:`;
};

// ============================================
// AI CALL (with timeout & error handling)
// ============================================

const callClaudeAPI = async (prompt: string): Promise<AIPlan> => {
  const anthropic = new Anthropic({
    apiKey: AI_CONFIG.apiKey,
  });

  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error('AI_TIMEOUT')), AI_CONFIG.timeout);
  });

  const apiPromise = anthropic.messages.create({
    model: AI_CONFIG.model,
    max_tokens: AI_CONFIG.maxTokens,
    messages: [
      {
        role: 'user',
        content: prompt,
      },
    ],
  });

  try {
    const response = await Promise.race([apiPromise, timeoutPromise]);

    const content = response.content[0];
    if (content.type !== 'text') {
      throw new Error('Invalid response type from AI');
    }

    // Extract JSON from response (handle markdown code blocks)
    let jsonText = content.text.trim();
    if (jsonText.startsWith('```')) {
      jsonText = jsonText.replace(/```json?\n?/g, '').replace(/```\n?$/g, '');
    }

    const plan: AIPlan = JSON.parse(jsonText);

    // Validate required fields
    if (!plan.theme || !plan.decor || !plan.food || !plan.music || !plan.recommendedCategories) {
      throw new Error('Missing required fields in AI response');
    }

    return plan;
  } catch (error: any) {
    console.error('AI API Error:', error.message);
    throw error;
  }
};

// ============================================
// DATABASE MAPPING
// ============================================

const getMatchingListingCounts = async (
  categories: string[],
  location: string
): Promise<{ [category: string]: number; total: number }> => {
  const counts: { [category: string]: number } = {};
  let total = 0;

  for (const category of categories) {
    try {
      const result = await getListings({
        category,
        location,
        isActive: true,
        page: 1,
        limit: 1, // We only need the count
      });

      counts[category] = result.total;
      total += result.total;
    } catch (error) {
      console.error(`Error counting listings for ${category}:`, error);
      counts[category] = 0;
    }
  }

  return { ...counts, total };
};

// ============================================
// MAIN SERVICE FUNCTION
// ============================================

export const generateEventPlan = async (
  data: AIPlannerRequest
): Promise<AIPlanResponse> => {
  let plan: AIPlan;
  let generatedBy: 'ai' | 'fallback' = 'fallback';

  // Check demo mode first
  if (AI_CONFIG.demoMode) {
    console.log('🎭 Demo mode: Using fallback plan');
    plan = FALLBACK_PLANS[data.eventType] || FALLBACK_PLANS.Other;
  }
  // Try AI generation if enabled
  else if (AI_CONFIG.enabled && AI_CONFIG.apiKey) {
    try {
      const prompt = buildAIPrompt(data);
      plan = await callClaudeAPI(prompt);
      generatedBy = 'ai';
      console.log('✓ AI plan generated successfully');
    } catch (error: any) {
      console.warn('AI generation failed, using fallback:', error.message);
      plan = FALLBACK_PLANS[data.eventType] || FALLBACK_PLANS.Other;
    }
  } else {
    console.log('AI disabled, using fallback plan');
    plan = FALLBACK_PLANS[data.eventType] || FALLBACK_PLANS.Other;
  }

  // Get matching listing counts
  const matchingCounts = await getMatchingListingCounts(
    plan.recommendedCategories,
    data.location
  );

  return {
    plan,
    matchingCounts,
    generatedBy,
    timestamp: new Date().toISOString(),
  };
};
