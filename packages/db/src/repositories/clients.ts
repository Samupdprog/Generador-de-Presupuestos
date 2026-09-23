import { and, eq, ilike, or } from "drizzle-orm";
import type { Database } from "../client.js";
import { RevisionConflictError } from "../errors.js";
import { clients } from "../schema/common.js";

export interface CreateClientInput {
  installationId: string;
  name: string;
  taxId?: string | undefined;
  email?: string | undefined;
  phone?: string | undefined;
  address?: string | undefined;
}

export interface UpdateClientInput extends Partial<Omit<CreateClientInput, "installationId">> {
  id: string;
  installationId: string;
  expectedRevision: number;
}

export function createClientRepository(db: Database) {
  return {
    async create(input: CreateClientInput) {
      const [client] = await db.insert(clients).values(input).returning();
      if (!client) throw new Error("client_insert_failed");
      return client;
    },

    async getById(installationId: string, id: string) {
      const [client] = await db.select().from(clients).where(and(eq(clients.installationId, installationId), eq(clients.id, id))).limit(1);
      return client ?? null;
    },

    async search(installationId: string, query: string) {
      return db.select().from(clients).where(and(
        eq(clients.installationId, installationId),
        or(ilike(clients.name, `%${query}%`), ilike(clients.email, `%${query}%`)),
      )).orderBy(clients.name);
    },

    async update(input: UpdateClientInput) {
      const { id, installationId, expectedRevision, ...changes } = input;
      const [client] = await db.update(clients)
        .set({ ...changes, revision: expectedRevision + 1, updatedAt: new Date() })
        .where(and(eq(clients.id, id), eq(clients.installationId, installationId), eq(clients.revision, expectedRevision)))
        .returning();
      if (!client) throw new RevisionConflictError("client", id);
      return client;
    },
  };
}