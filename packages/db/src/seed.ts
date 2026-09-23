import { createDb } from "./client.js";
import { installations } from "./schema/common.js";
import { eq } from "drizzle-orm";

const databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) throw new Error("DATABASE_URL is required");

const slug = process.env.INSTALLATION_SLUG ?? "demo";
const displayName = process.env.INSTALLATION_NAME ?? "Demo Company";
const { db, pool } = createDb(databaseUrl);
const [installation] = await db.insert(installations)
  .values({ slug, displayName })
  .onConflictDoUpdate({ target: installations.slug, set: { displayName, updatedAt: new Date() } })
  .returning({ id: installations.id, slug: installations.slug });
console.log(JSON.stringify(installation));
await pool.end();