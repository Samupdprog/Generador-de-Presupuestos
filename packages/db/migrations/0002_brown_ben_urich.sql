CREATE TYPE "public"."sale_base_mode" AS ENUM('net_cost', 'supplier_list_price');--> statement-breakpoint
ALTER TYPE "public"."quote_line_type" ADD VALUE 'title';--> statement-breakpoint
ALTER TABLE "employee_supplements" ALTER COLUMN "employee_id" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD COLUMN "supplier_name_snapshot" text;--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD COLUMN "supplier_code" text;--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD COLUMN "igic_rate" numeric(5, 2) DEFAULT '7' NOT NULL;--> statement-breakpoint
ALTER TABLE "catalog_materials" ADD COLUMN "active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "catalog_travels" ADD COLUMN "description" text;--> statement-breakpoint
ALTER TABLE "catalog_travels" ADD COLUMN "igic_rate" numeric(5, 2) DEFAULT '7' NOT NULL;--> statement-breakpoint
ALTER TABLE "catalog_travels" ADD COLUMN "active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "employee_supplements" ADD COLUMN "add_per_hour" numeric(18, 6) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "employee_supplements" ADD COLUMN "active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "employees" ADD COLUMN "default_igic_rate" numeric(5, 2) DEFAULT '7' NOT NULL;--> statement-breakpoint
ALTER TABLE "employees" ADD COLUMN "active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "text_templates" ADD COLUMN "always_include" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "text_templates" ADD COLUMN "active" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_calculation_runs" ADD COLUMN "sale_without_tax" numeric(18, 2) NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_calculation_runs" ADD COLUMN "tax_total" numeric(18, 2) NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_calculation_runs" ADD COLUMN "sale_with_tax" numeric(18, 2) NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_line_calculations" ADD COLUMN "igic" numeric(18, 2) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_line_calculations" ADD COLUMN "final_sale_with_tax" numeric(18, 2) DEFAULT '0' NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_line_labor_entries" ADD COLUMN "supplement_id" uuid;--> statement-breakpoint
ALTER TABLE "quote_line_labor_entries" ADD COLUMN "supplement_name_snapshot" text;--> statement-breakpoint
ALTER TABLE "quote_line_labor_entries" ADD COLUMN "supplement_per_hour_snapshot" numeric(18, 6);--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "unit" text DEFAULT 'unit' NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "igic_rate" numeric(5, 2) DEFAULT '7' NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "sale_base_mode" "sale_base_mode" DEFAULT 'net_cost' NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "supplier_name_snapshot" text;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "supplier_code_snapshot" text;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "supplier_list_price_snapshot" numeric(18, 6);--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "cost_snapshot" numeric(18, 6);--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "price_snapshot" numeric(18, 6);--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "eligible_for_price_allocation" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "internal_reference" text;--> statement-breakpoint
ALTER TABLE "quote_lines" ADD COLUMN "internal_notes" text;--> statement-breakpoint
ALTER TABLE "quote_text_blocks" ADD COLUMN "template_id" uuid;--> statement-breakpoint
ALTER TABLE "quote_text_blocks" ADD COLUMN "title_snapshot" text;--> statement-breakpoint
ALTER TABLE "quote_text_blocks" ADD COLUMN "body_snapshot" text;