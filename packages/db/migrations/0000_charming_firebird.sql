CREATE TYPE "public"."actor_type" AS ENUM('user', 'ai', 'system', 'worker');--> statement-breakpoint
CREATE TYPE "public"."quote_access_mode" AS ENUM('editable', 'read_only');--> statement-breakpoint
CREATE TYPE "public"."quote_origin" AS ENUM('generator', 'holded');--> statement-breakpoint
CREATE TYPE "public"."quote_status" AS ENUM('draft', 'ready_for_review', 'finalized', 'archived');--> statement-breakpoint
CREATE TYPE "public"."sync_status" AS ENUM('pending', 'synced', 'error', 'conflict');--> statement-breakpoint
CREATE TYPE "public"."adjustment_mode" AS ENUM('amount', 'percentage', 'target_total');--> statement-breakpoint
CREATE TYPE "public"."adjustment_scope" AS ENUM('line', 'selection', 'quote');--> statement-breakpoint
CREATE TYPE "public"."quote_line_type" AS ENUM('material', 'labor', 'travel', 'adjustment', 'other');--> statement-breakpoint
CREATE TYPE "public"."sale_rule_type" AS ENUM('unit_price', 'fixed_line_total', 'add_euros_per_unit', 'add_percentage');--> statement-breakpoint
CREATE TYPE "public"."holded_operation_type" AS ENUM('create_client', 'update_client', 'create_quote', 'update_quote');--> statement-breakpoint
CREATE TYPE "public"."job_status" AS ENUM('pending', 'processing', 'completed', 'failed');--> statement-breakpoint
CREATE TABLE "catalog_materials" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"supplier_id" uuid,
	"name" text NOT NULL,
	"description" text,
	"unit" text DEFAULT 'unit' NOT NULL,
	"supplier_unit_price" numeric(18, 6),
	"sale_unit_price" numeric(18, 6),
	"metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "catalog_travels" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"name" text NOT NULL,
	"unit" text DEFAULT 'km' NOT NULL,
	"cost_unit_price" numeric(18, 6) DEFAULT '0' NOT NULL,
	"sale_unit_price" numeric(18, 6) DEFAULT '0' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "clients" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"name" text NOT NULL,
	"tax_id" text,
	"email" text,
	"phone" text,
	"address" text,
	"holded_contact_id" text,
	"sync_status" "sync_status" DEFAULT 'pending' NOT NULL,
	"last_synced_at" timestamp with time zone,
	"last_synced_revision" integer,
	"holded_payload_hash" text,
	"holded_snapshot" jsonb,
	"sync_error" text,
	"revision" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "employee_supplements" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"employee_id" uuid NOT NULL,
	"name" text NOT NULL,
	"amount" numeric(18, 6) DEFAULT '0' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "employees" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"name" text NOT NULL,
	"cost_rate" numeric(18, 6) DEFAULT '0' NOT NULL,
	"sale_rate" numeric(18, 6) DEFAULT '0' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "installations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"display_name" text NOT NULL,
	"config" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "installations_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "suppliers" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"name" text NOT NULL,
	"tax_id" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "text_templates" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"title" text NOT NULL,
	"body" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"email" text NOT NULL,
	"display_name" text NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_calculation_runs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_id" uuid NOT NULL,
	"quote_revision" integer NOT NULL,
	"subtotal" numeric(18, 2) NOT NULL,
	"igic" numeric(18, 2) NOT NULL,
	"total" numeric(18, 2) NOT NULL,
	"cost" numeric(18, 2) NOT NULL,
	"profit" numeric(18, 2) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_line_calculations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"calculation_run_id" uuid NOT NULL,
	"quote_line_id" uuid NOT NULL,
	"cost" numeric(18, 2) NOT NULL,
	"base_sale" numeric(18, 2) NOT NULL,
	"sale" numeric(18, 2) NOT NULL,
	"adjustment" numeric(18, 2) NOT NULL,
	"profit" numeric(18, 2) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_line_discounts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_line_id" uuid NOT NULL,
	"position" integer NOT NULL,
	"percentage" numeric(9, 6) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_line_labor_entries" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_line_id" uuid NOT NULL,
	"employee_id" uuid,
	"employee_name_snapshot" text NOT NULL,
	"hours" numeric(18, 6) NOT NULL,
	"cost_rate_snapshot" numeric(18, 6) NOT NULL,
	"sale_rate_snapshot" numeric(18, 6) NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_lines" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_id" uuid NOT NULL,
	"position" integer NOT NULL,
	"type" "quote_line_type" NOT NULL,
	"description" text NOT NULL,
	"quantity" numeric(18, 6) DEFAULT '1' NOT NULL,
	"sale_rule" "sale_rule_type" NOT NULL,
	"sale_rule_value" numeric(18, 6) DEFAULT '0' NOT NULL,
	"base_unit_price" numeric(18, 6),
	"direct_unit_cost" numeric(18, 6),
	"supplier_unit_price" numeric(18, 6),
	"catalog_material_id" uuid,
	"supplier_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "quote_lines_quantity_non_negative" CHECK ("quote_lines"."quantity" >= 0)
);
--> statement-breakpoint
CREATE TABLE "quote_price_adjustment_targets" (
	"adjustment_id" uuid NOT NULL,
	"quote_line_id" uuid NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_price_adjustments" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_id" uuid NOT NULL,
	"scope" "adjustment_scope" NOT NULL,
	"mode" "adjustment_mode" NOT NULL,
	"value" numeric(18, 6) NOT NULL,
	"allocation_method" text DEFAULT 'proportional' NOT NULL,
	"base_quote_revision" integer NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_text_blocks" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_id" uuid NOT NULL,
	"position" integer NOT NULL,
	"title" text,
	"body" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quote_versions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"quote_id" uuid NOT NULL,
	"revision" integer NOT NULL,
	"snapshot" jsonb NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "quotes" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"client_id" uuid,
	"reference" text NOT NULL,
	"title" text NOT NULL,
	"origin" "quote_origin" DEFAULT 'generator' NOT NULL,
	"access_mode" "quote_access_mode" DEFAULT 'editable' NOT NULL,
	"status" "quote_status" DEFAULT 'draft' NOT NULL,
	"revision" integer DEFAULT 0 NOT NULL,
	"holded_estimate_id" text,
	"duplicated_from_quote_id" uuid,
	"duplicate_root_quote_id" uuid,
	"duplicate_sequence" integer,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "reference_counters" (
	"installation_id" uuid PRIMARY KEY NOT NULL,
	"quote_next_value" integer DEFAULT 1 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "audit_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"actor_type" "actor_type" NOT NULL,
	"actor_user_id" uuid,
	"action" text NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" uuid,
	"before" jsonb,
	"after" jsonb,
	"metadata" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "holded_entity_snapshots" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"entity_type" text NOT NULL,
	"external_id" text NOT NULL,
	"payload_hash" text NOT NULL,
	"payload" jsonb NOT NULL,
	"captured_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "holded_operations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"operation_type" "holded_operation_type" NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" uuid NOT NULL,
	"idempotency_key" text NOT NULL,
	"payload" jsonb NOT NULL,
	"status" "job_status" DEFAULT 'pending' NOT NULL,
	"error" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"completed_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "holded_sync_cursors" (
	"installation_id" uuid NOT NULL,
	"resource" text NOT NULL,
	"cursor" text,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "holded_sync_cursors_installation_id_resource_pk" PRIMARY KEY("installation_id","resource")
);
--> statement-breakpoint
CREATE TABLE "holded_webhook_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"external_event_id" text NOT NULL,
	"event_type" text NOT NULL,
	"payload" jsonb NOT NULL,
	"processed_at" timestamp with time zone,
	"error" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "idempotency_keys" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"key" text NOT NULL,
	"request_hash" text NOT NULL,
	"response_status" integer,
	"response_body" jsonb,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expires_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "jobs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"installation_id" uuid NOT NULL,
	"type" text NOT NULL,
	"idempotency_key" text NOT NULL,
	"payload" jsonb NOT NULL,
	"status" "job_status" DEFAULT 'pending' NOT NULL,
	"attempts" integer DEFAULT 0 NOT NULL,
	"available_at" timestamp with time zone DEFAULT now() NOT NULL,
	"locked_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"error" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "jobs_attempts_non_negative" CHECK ("jobs"."attempts" >= 0)
);
--> statement-breakpoint
CREATE TABLE "price_adjustment_allocations" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"application_id" uuid NOT NULL,
	"quote_id" uuid NOT NULL,
	"quote_revision" integer NOT NULL,
	"amount" numeric(18, 6) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "price_adjustment_applications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"adjustment_id" uuid NOT NULL,
	"quote_line_id" uuid NOT NULL,
	"amount" numeric(18, 6) NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD CONSTRAINT "catalog_materials_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD CONSTRAINT "catalog_materials_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "catalog_travels" ADD CONSTRAINT "catalog_travels_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "clients" ADD CONSTRAINT "clients_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "employee_supplements" ADD CONSTRAINT "employee_supplements_employee_id_employees_id_fk" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "employees" ADD CONSTRAINT "employees_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "suppliers" ADD CONSTRAINT "suppliers_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "text_templates" ADD CONSTRAINT "text_templates_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_calculation_runs" ADD CONSTRAINT "quote_calculation_runs_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_line_calculations" ADD CONSTRAINT "quote_line_calculations_calculation_run_id_quote_calculation_runs_id_fk" FOREIGN KEY ("calculation_run_id") REFERENCES "public"."quote_calculation_runs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_line_calculations" ADD CONSTRAINT "quote_line_calculations_quote_line_id_quote_lines_id_fk" FOREIGN KEY ("quote_line_id") REFERENCES "public"."quote_lines"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_line_discounts" ADD CONSTRAINT "quote_line_discounts_quote_line_id_quote_lines_id_fk" FOREIGN KEY ("quote_line_id") REFERENCES "public"."quote_lines"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_line_labor_entries" ADD CONSTRAINT "quote_line_labor_entries_quote_line_id_quote_lines_id_fk" FOREIGN KEY ("quote_line_id") REFERENCES "public"."quote_lines"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_line_labor_entries" ADD CONSTRAINT "quote_line_labor_entries_employee_id_employees_id_fk" FOREIGN KEY ("employee_id") REFERENCES "public"."employees"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD CONSTRAINT "quote_lines_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD CONSTRAINT "quote_lines_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_price_adjustment_targets" ADD CONSTRAINT "quote_price_adjustment_targets_adjustment_id_quote_price_adjustments_id_fk" FOREIGN KEY ("adjustment_id") REFERENCES "public"."quote_price_adjustments"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_price_adjustment_targets" ADD CONSTRAINT "quote_price_adjustment_targets_quote_line_id_quote_lines_id_fk" FOREIGN KEY ("quote_line_id") REFERENCES "public"."quote_lines"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_price_adjustments" ADD CONSTRAINT "quote_price_adjustments_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_price_adjustments" ADD CONSTRAINT "quote_price_adjustments_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_text_blocks" ADD CONSTRAINT "quote_text_blocks_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_versions" ADD CONSTRAINT "quote_versions_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quote_versions" ADD CONSTRAINT "quote_versions_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quotes" ADD CONSTRAINT "quotes_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quotes" ADD CONSTRAINT "quotes_client_id_clients_id_fk" FOREIGN KEY ("client_id") REFERENCES "public"."clients"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quotes" ADD CONSTRAINT "quotes_created_by_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "reference_counters" ADD CONSTRAINT "reference_counters_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_events" ADD CONSTRAINT "audit_events_actor_user_id_users_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "holded_entity_snapshots" ADD CONSTRAINT "holded_entity_snapshots_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "holded_operations" ADD CONSTRAINT "holded_operations_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "holded_sync_cursors" ADD CONSTRAINT "holded_sync_cursors_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "holded_webhook_events" ADD CONSTRAINT "holded_webhook_events_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "idempotency_keys" ADD CONSTRAINT "idempotency_keys_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "jobs" ADD CONSTRAINT "jobs_installation_id_installations_id_fk" FOREIGN KEY ("installation_id") REFERENCES "public"."installations"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "price_adjustment_allocations" ADD CONSTRAINT "price_adjustment_allocations_application_id_price_adjustment_applications_id_fk" FOREIGN KEY ("application_id") REFERENCES "public"."price_adjustment_applications"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "price_adjustment_allocations" ADD CONSTRAINT "price_adjustment_allocations_quote_id_quotes_id_fk" FOREIGN KEY ("quote_id") REFERENCES "public"."quotes"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "price_adjustment_applications" ADD CONSTRAINT "price_adjustment_applications_adjustment_id_quote_price_adjustments_id_fk" FOREIGN KEY ("adjustment_id") REFERENCES "public"."quote_price_adjustments"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "price_adjustment_applications" ADD CONSTRAINT "price_adjustment_applications_quote_line_id_quote_lines_id_fk" FOREIGN KEY ("quote_line_id") REFERENCES "public"."quote_lines"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "clients_installation_name_idx" ON "clients" USING btree ("installation_id","name");--> statement-breakpoint
CREATE UNIQUE INDEX "clients_installation_holded_id_unique" ON "clients" USING btree ("installation_id","holded_contact_id");--> statement-breakpoint
CREATE UNIQUE INDEX "suppliers_installation_name_unique" ON "suppliers" USING btree ("installation_id","name");--> statement-breakpoint
CREATE UNIQUE INDEX "users_installation_email_unique" ON "users" USING btree ("installation_id","email");--> statement-breakpoint
CREATE UNIQUE INDEX "quote_line_discounts_order_unique" ON "quote_line_discounts" USING btree ("quote_line_id","position");--> statement-breakpoint
CREATE UNIQUE INDEX "quote_lines_quote_position_unique" ON "quote_lines" USING btree ("quote_id","position");--> statement-breakpoint
CREATE UNIQUE INDEX "quote_price_adjustment_targets_unique" ON "quote_price_adjustment_targets" USING btree ("adjustment_id","quote_line_id");--> statement-breakpoint
CREATE UNIQUE INDEX "quote_versions_quote_revision_unique" ON "quote_versions" USING btree ("quote_id","revision");--> statement-breakpoint
CREATE UNIQUE INDEX "quotes_installation_reference_unique" ON "quotes" USING btree ("installation_id","reference");--> statement-breakpoint
CREATE INDEX "quotes_installation_status_idx" ON "quotes" USING btree ("installation_id","status","updated_at");--> statement-breakpoint
CREATE UNIQUE INDEX "quotes_installation_holded_id_unique" ON "quotes" USING btree ("installation_id","holded_estimate_id");--> statement-breakpoint
CREATE INDEX "audit_events_entity_idx" ON "audit_events" USING btree ("entity_type","entity_id","created_at");--> statement-breakpoint
CREATE UNIQUE INDEX "holded_entity_snapshots_installation_entity_unique" ON "holded_entity_snapshots" USING btree ("installation_id","entity_type","external_id");--> statement-breakpoint
CREATE UNIQUE INDEX "holded_operations_installation_key_unique" ON "holded_operations" USING btree ("installation_id","idempotency_key");--> statement-breakpoint
CREATE UNIQUE INDEX "holded_webhook_events_installation_external_unique" ON "holded_webhook_events" USING btree ("installation_id","external_event_id");--> statement-breakpoint
CREATE UNIQUE INDEX "idempotency_keys_installation_key_unique" ON "idempotency_keys" USING btree ("installation_id","key");--> statement-breakpoint
CREATE INDEX "jobs_pending_idx" ON "jobs" USING btree ("status","available_at");--> statement-breakpoint
CREATE UNIQUE INDEX "jobs_installation_key_unique" ON "jobs" USING btree ("installation_id","idempotency_key");