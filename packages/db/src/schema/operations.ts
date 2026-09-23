import { sql } from "drizzle-orm";
import { check, index, integer, jsonb, numeric, pgEnum, pgTable, primaryKey, text, timestamp, uniqueIndex, uuid } from "drizzle-orm/pg-core";
import { actorType, installations, users } from "./common.js";
import { quoteLines, quotePriceAdjustments, quotes } from "./quotes.js";

export const jobStatus = pgEnum("job_status", ["pending", "processing", "completed", "failed"]);
export const holdedOperationType = pgEnum("holded_operation_type", ["create_client", "update_client", "create_quote", "update_quote"]);

export const auditEvents = pgTable("audit_events", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  actorType: actorType("actor_type").notNull(),
  actorUserId: uuid("actor_user_id").references(() => users.id),
  action: text("action").notNull(),
  entityType: text("entity_type").notNull(),
  entityId: uuid("entity_id"),
  before: jsonb("before").$type<Record<string, unknown>>(),
  after: jsonb("after").$type<Record<string, unknown>>(),
  metadata: jsonb("metadata").$type<Record<string, unknown>>().notNull().default({}),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  entityIndex: index("audit_events_entity_idx").on(table.entityType, table.entityId, table.createdAt),
}));

export const idempotencyKeys = pgTable("idempotency_keys", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  key: text("key").notNull(),
  requestHash: text("request_hash").notNull(),
  responseStatus: integer("response_status"),
  responseBody: jsonb("response_body").$type<Record<string, unknown>>(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  expiresAt: timestamp("expires_at", { withTimezone: true }),
}, (table) => ({
  keyUnique: uniqueIndex("idempotency_keys_installation_key_unique").on(table.installationId, table.key),
}));

export const holdedWebhookEvents = pgTable("holded_webhook_events", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  externalEventId: text("external_event_id").notNull(),
  eventType: text("event_type").notNull(),
  payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
  processedAt: timestamp("processed_at", { withTimezone: true }),
  error: text("error"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  eventUnique: uniqueIndex("holded_webhook_events_installation_external_unique").on(table.installationId, table.externalEventId),
}));

export const holdedOperations = pgTable("holded_operations", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  operationType: holdedOperationType("operation_type").notNull(),
  entityType: text("entity_type").notNull(),
  entityId: uuid("entity_id").notNull(),
  idempotencyKey: text("idempotency_key").notNull(),
  payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
  status: jobStatus("status").notNull().default("pending"),
  error: text("error"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
  completedAt: timestamp("completed_at", { withTimezone: true }),
}, (table) => ({
  operationUnique: uniqueIndex("holded_operations_installation_key_unique").on(table.installationId, table.idempotencyKey),
}));

export const holdedEntitySnapshots = pgTable("holded_entity_snapshots", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  entityType: text("entity_type").notNull(),
  externalId: text("external_id").notNull(),
  payloadHash: text("payload_hash").notNull(),
  payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
  capturedAt: timestamp("captured_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  entityUnique: uniqueIndex("holded_entity_snapshots_installation_entity_unique").on(table.installationId, table.entityType, table.externalId),
}));

export const holdedSyncCursors = pgTable("holded_sync_cursors", {
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  resource: text("resource").notNull(),
  cursor: text("cursor"),
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  cursorPrimaryKey: primaryKey({ columns: [table.installationId, table.resource] }),
}));

export const priceAdjustmentApplications = pgTable("price_adjustment_applications", {
  id: uuid("id").defaultRandom().primaryKey(),
  adjustmentId: uuid("adjustment_id").notNull().references(() => quotePriceAdjustments.id),
  quoteLineId: uuid("quote_line_id").notNull().references(() => quoteLines.id),
  amount: numeric("amount", { precision: 18, scale: 6 }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const priceAdjustmentAllocations = pgTable("price_adjustment_allocations", {
  id: uuid("id").defaultRandom().primaryKey(),
  applicationId: uuid("application_id").notNull().references(() => priceAdjustmentApplications.id),
  quoteId: uuid("quote_id").notNull().references(() => quotes.id),
  quoteRevision: integer("quote_revision").notNull(),
  amount: numeric("amount", { precision: 18, scale: 6 }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
});

export const jobs = pgTable("jobs", {
  id: uuid("id").defaultRandom().primaryKey(),
  installationId: uuid("installation_id").notNull().references(() => installations.id),
  type: text("type").notNull(),
  idempotencyKey: text("idempotency_key").notNull(),
  payload: jsonb("payload").$type<Record<string, unknown>>().notNull(),
  status: jobStatus("status").notNull().default("pending"),
  attempts: integer("attempts").notNull().default(0),
  availableAt: timestamp("available_at", { withTimezone: true }).defaultNow().notNull(),
  lockedAt: timestamp("locked_at", { withTimezone: true }),
  completedAt: timestamp("completed_at", { withTimezone: true }),
  error: text("error"),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  pendingIndex: index("jobs_pending_idx").on(table.status, table.availableAt),
  idempotencyUnique: uniqueIndex("jobs_installation_key_unique").on(table.installationId, table.idempotencyKey),
  attemptsNonNegative: check("jobs_attempts_non_negative", sql`${table.attempts} >= 0`),
}));