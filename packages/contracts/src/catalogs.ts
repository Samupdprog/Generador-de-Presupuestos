import { z } from "zod/v4";

export const catalogMutationSchema = z.object({
  name: z.string().min(1),
}).passthrough();

export const catalogUpdateSchema = z.record(z.string(), z.unknown());