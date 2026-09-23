import { z } from "zod/v4";

export const createClientRequestSchema = z.object({
  name: z.string().trim().min(1),
  taxId: z.string().trim().optional(),
  email: z.email().optional(),
  phone: z.string().trim().optional(),
  address: z.string().trim().optional(),
});

export const updateClientRequestSchema = createClientRequestSchema.partial().extend({
  expectedRevision: z.number().int().nonnegative(),
});

export const searchClientsRequestSchema = z.object({
  q: z.string().trim().default(""),
});

export type CreateClientRequest = z.infer<typeof createClientRequestSchema>;
export type UpdateClientRequest = z.infer<typeof updateClientRequestSchema>;