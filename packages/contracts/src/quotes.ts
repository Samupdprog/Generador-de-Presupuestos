import { z } from "zod/v4";

export const createQuoteRequestSchema = z.object({
  title: z.string().trim().min(1),
  clientId: z.uuid().optional(),
  origin: z.enum(["generator", "holded"]).default("generator"),
  accessMode: z.enum(["editable", "read_only"]).default("editable"),
});

export const searchQuotesRequestSchema = z.object({
  q: z.string().trim().default(""),
});

export type CreateQuoteRequest = z.infer<typeof createQuoteRequestSchema>;