export interface PartyPlannerRequest {
  date: string;
  guests: number;
  budget: number;
  theme?: string;
  location?: string;
}

export interface PartyPlannerResponse {
  summary: string;
  decorIdeas: string[];
  foodIdeas: string[];
  recommendedCategories: string[];
  estimatedCost: number;
  timeline: {
    time: string;
    activity: string;
  }[];
}

export const generatePartyPlan = async (
  data: PartyPlannerRequest
): Promise<PartyPlannerResponse> => {
  const { date, guests, budget, theme = 'casual', location = 'indoor' } = data;

  // Dummy implementation - returns templated response
  // In production, this would call an LLM API (OpenAI, Anthropic, etc.)

  const decorIdeas = [
    `${theme} themed decorations`,
    'Balloons and streamers',
    'Table centerpieces',
    'Lighting setup',
    'Photo backdrop',
  ];

  const foodIdeas = [
    `${guests} person catering package`,
    'Appetizers and finger foods',
    'Main course buffet',
    'Dessert table',
    'Beverages and drinks',
  ];

  const recommendedCategories = ['decor', 'catering', 'music', 'photography'];

  const estimatedCost = Math.min(budget * 0.8, budget);

  const timeline = [
    { time: '10:00 AM', activity: 'Setup and decoration' },
    { time: '12:00 PM', activity: 'Food preparation' },
    { time: '2:00 PM', activity: 'Guest arrival and welcome' },
    { time: '2:30 PM', activity: 'Main activities begin' },
    { time: '5:00 PM', activity: 'Food service' },
    { time: '7:00 PM', activity: 'Entertainment and music' },
    { time: '9:00 PM', activity: 'Wind down and cleanup' },
  ];

  const summary = `A ${theme} party for ${guests} guests on ${date} at ${location}. 
    The plan includes ${decorIdeas.length} decoration ideas, ${foodIdeas.length} food options, 
    and a complete timeline. Estimated cost: $${estimatedCost.toFixed(2)} within your budget of $${budget}.`;

  return {
    summary,
    decorIdeas,
    foodIdeas,
    recommendedCategories,
    estimatedCost,
    timeline,
  };
};

