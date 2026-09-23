import { z } from "zod/v4";

export const revisionGuardSchema = z.object({
  expectedRevision: z.number().int().nonnegative()
});

export type RevisionGuard = z.infer<typeof revisionGuardSchema>;

export const actorTypeSchema = z.enum(["user", "ai", "system", "worker"]);
export type ActorType = z.infer<typeof actorTypeSchema>;

export const healthSchema = z.object({
  status: z.literal("ok"),
  service: z.string(),
  timestamp: z.string()
});
