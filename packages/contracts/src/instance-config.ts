import { z } from "zod/v4";

export const instanceConfigSchema = z.object({
  slug: z.string().regex(/^[a-z0-9-]+$/),
  companyName: z.string().min(1),
  appName: z.string().min(1),
  locale: z.string().min(2),
  timezone: z.string().min(1),
  currency: z.string().length(3),
  tax: z.object({
    label: z.string().min(1),
    defaultRate: z.string(),
    allowedRates: z.array(z.string()),
  }),
  features: z.object({
    materials: z.boolean(),
    labor: z.boolean(),
    travel: z.boolean(),
    supplierDiscounts: z.boolean(),
    priceAdjustments: z.boolean(),
    textTemplates: z.boolean(),
    holded: z.boolean(),
    mcp: z.boolean(),
    aiImport: z.boolean(),
  }),
});

export type InstanceConfig = z.infer<typeof instanceConfigSchema>;