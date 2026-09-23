import { createServer } from "node:http";
import type { IncomingMessage, ServerResponse } from "node:http";
import {
  archiveQuote,
  addLaborEntry,
  addLaborLine,
  addMaterialLine,
  addOtherLine,
  addPriceAdjustment,
  addQuoteText,
  addSupplierDiscount,
  addTravelLine,
  executeQuoteCommand,
  getCatalog,
  type QuoteWorkflowRepository,
  createClient,
  createQuote,
  duplicateQuote,
  getClient,
  getQuote,
  searchClients,
  searchQuotes,
  updateClient,
} from "@quotes/application";
import {
  createClientRequestSchema,
  createQuoteRequestSchema,
  revisionGuardSchema,
  searchClientsRequestSchema,
  searchQuotesRequestSchema,
  updateClientRequestSchema,
  quoteCommandSchema,
  catalogMutationSchema,
  catalogUpdateSchema,
} from "@quotes/contracts";
import {
  createClientRepository,
  createDb,
  createQuoteRepository,
  createQuoteWorkflowRepository,
  createCatalogRepository,
  QuoteNotFoundError,
  ReadOnlyQuoteError,
  RevisionConflictError,
} from "@quotes/db";

const host = process.env.HOST ?? "0.0.0.0";
const port = Number(process.env.PORT ?? "4000");
const installationId = process.env.INSTALLATION_ID;
const databaseUrl = process.env.DATABASE_URL;
const database = databaseUrl ? createDb(databaseUrl) : null;
const clients = database ? createClientRepository(database.db) : null;
const quotes = database ? createQuoteRepository(database.db) : null;
const quoteWorkflow = database ? createQuoteWorkflowRepository(database.db) as unknown as QuoteWorkflowRepository : null;
const catalog = database ? createCatalogRepository(database.db) : null;

function sendJson(res: ServerResponse, status: number, body: unknown) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(JSON.stringify(body));
}

function readBody(req: IncomingMessage): Promise<unknown> {
  return new Promise((resolve, reject) => {
    let data = "";
    req.on("data", (chunk: Buffer) => { data += chunk.toString(); });
    req.on("end", () => {
      try { resolve(data ? JSON.parse(data) : {}); } catch { reject(new Error("invalid_json")); }
    });
    req.on("error", reject);
  });
}

function requireContext(res: ServerResponse) {
  if (!database || !clients || !quotes || !quoteWorkflow || !catalog || !installationId) {
    sendJson(res, 503, { error: "database_not_configured" });
    return false;
  }
  return true;
}

function mapError(res: ServerResponse, error: unknown) {
  if (error instanceof RevisionConflictError) return sendJson(res, 409, { error: "revision_conflict" });
  if (error instanceof QuoteNotFoundError) return sendJson(res, 404, { error: "quote_not_found" });
  if (error instanceof ReadOnlyQuoteError) return sendJson(res, 422, { error: "quote_read_only" });
  if (error instanceof Error && error.message === "invalid_json") return sendJson(res, 400, { error: "invalid_json" });
  if (error && typeof error === "object" && "code" in error && error.code === "23505") return sendJson(res, 409, { error: "conflict" });
  console.error(error);
  return sendJson(res, 500, { error: "internal_error" });
}

const server = createServer(async (req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    return sendJson(res, 200, {
      status: "ok",
      service: "api",
      timestamp: new Date().toISOString()
    });
  }

  if (!requireContext(res)) return;
  const url = new URL(req.url ?? "/", `http://${req.headers.host ?? "localhost"}`);
  const path = url.pathname.split("/").filter(Boolean);

  try {
    if (path[0] === "clients" && path.length === 1 && req.method === "POST") {
      const parsed = createClientRequestSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input", details: parsed.error.issues });
      return sendJson(res, 201, await createClient(clients!)({ installationId: installationId!, ...parsed.data }));
    }
    if (path[0] === "clients" && path.length === 1 && req.method === "GET") {
      const parsed = searchClientsRequestSchema.safeParse(Object.fromEntries(url.searchParams));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input" });
      return sendJson(res, 200, await searchClients(clients!)(installationId!, parsed.data.q));
    }
    if (path[0] === "clients" && path.length === 2 && req.method === "GET") {
      const result = await getClient(clients!)(installationId!, path[1]!);
      return result ? sendJson(res, 200, result) : sendJson(res, 404, { error: "client_not_found" });
    }
    if (path[0] === "clients" && path.length === 2 && req.method === "PATCH") {
      const parsed = updateClientRequestSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input", details: parsed.error.issues });
      return sendJson(res, 200, await updateClient(clients!)({ installationId: installationId!, id: path[1]!, ...parsed.data }));
    }
    if (path[0] === "catalogs" && path.length === 2 && req.method === "GET") {
      const kinds = ["materials", "employees", "supplements", "travels", "text-templates", "suppliers"] as const;
      if (!kinds.includes(path[1] as typeof kinds[number])) return sendJson(res, 404, { error: "catalog_not_found" });
      return sendJson(res, 200, await getCatalog(catalog!, path[1] as typeof kinds[number])(installationId!, url.searchParams.get("employeeId") ?? undefined));
    }
    if (path[0] === "catalogs" && path.length === 2 && req.method === "POST") {
      const parsed = catalogMutationSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input" });
      const data = { ...parsed.data, installationId: installationId! };
      const created = path[1] === "materials" ? await catalog!.createMaterial(data as never) : path[1] === "employees" ? await catalog!.createEmployee(data as never) : path[1] === "supplements" ? await catalog!.createSupplement(data as never) : path[1] === "travels" ? await catalog!.createTravel(data as never) : path[1] === "text-templates" ? await catalog!.createTextTemplate(data as never) : path[1] === "suppliers" ? await catalog!.createSupplier(data as never) : null;
      return created ? sendJson(res, 201, created[0]) : sendJson(res, 404, { error: "catalog_not_found" });
    }
    if (path[0] === "catalogs" && path.length === 3 && req.method === "PATCH") {
      const parsed = catalogUpdateSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input" });
      const kind = path[1];
      const id = path[2]!;
      const updated = kind === "materials" ? await catalog!.updateMaterial(id, installationId!, parsed.data as never) : kind === "employees" ? await catalog!.updateEmployee(id, installationId!, parsed.data as never) : kind === "supplements" ? await catalog!.updateSupplement(id, parsed.data as never) : kind === "travels" ? await catalog!.updateTravel(id, installationId!, parsed.data as never) : kind === "text-templates" ? await catalog!.updateTextTemplate(id, installationId!, parsed.data as never) : kind === "suppliers" ? await catalog!.updateSupplier(id, installationId!, parsed.data as never) : [];
      return updated[0] ? sendJson(res, 200, updated[0]) : sendJson(res, 404, { error: "catalog_not_found" });
    }
    if (path[0] === "catalogs" && path.length === 4 && path[3] === "archive" && req.method === "POST") {
      const kind = path[1];
      const id = path[2]!;
      const updated = kind === "materials" ? await catalog!.updateMaterial(id, installationId!, { active: false }) : kind === "employees" ? await catalog!.updateEmployee(id, installationId!, { active: false }) : kind === "supplements" ? await catalog!.updateSupplement(id, { active: false }) : kind === "travels" ? await catalog!.updateTravel(id, installationId!, { active: false }) : kind === "text-templates" ? await catalog!.updateTextTemplate(id, installationId!, { active: false }) : kind === "suppliers" ? await catalog!.updateSupplier(id, installationId!, { active: false }) : [];
      return updated[0] ? sendJson(res, 200, updated[0]) : sendJson(res, 404, { error: "catalog_not_found" });
    }
    if (path[0] === "quotes" && path.length === 1 && req.method === "POST") {
      const parsed = createQuoteRequestSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input", details: parsed.error.issues });
      return sendJson(res, 201, await createQuote(quotes!)({ installationId: installationId!, ...parsed.data }));
    }
    if (path[0] === "quotes" && path.length === 1 && req.method === "GET") {
      const parsed = searchQuotesRequestSchema.safeParse(Object.fromEntries(url.searchParams));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input" });
      return sendJson(res, 200, await searchQuotes(quotes!)(installationId!, parsed.data.q));
    }
    if (path[0] === "quotes" && path.length === 2 && req.method === "GET") {
      const result = await getQuote(quotes!)(installationId!, path[1]!);
      return result ? sendJson(res, 200, result) : sendJson(res, 404, { error: "quote_not_found" });
    }
    if (path[0] === "quotes" && path.length === 3 && path[2] === "duplicate" && req.method === "POST") {
      return sendJson(res, 201, await duplicateQuote(quotes!)(installationId!, path[1]!));
    }
    if (path[0] === "quotes" && path.length === 3 && path[2] === "commands" && req.method === "POST") {
      const parsed = quoteCommandSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input", details: parsed.error.issues });
      const command = parsed.data;
      const context = { ...command, installationId: installationId!, quoteId: path[1]! };
      if (command.type === "addMaterialLine") return sendJson(res, 200, await addMaterialLine(quoteWorkflow!)(context as unknown as Record<string, unknown>));
      if (command.type === "addLaborLine") return sendJson(res, 200, await addLaborLine(quoteWorkflow!)(context as unknown as Record<string, unknown>));
      if (command.type === "addTravelLine") return sendJson(res, 200, await addTravelLine(quoteWorkflow!)(context as unknown as Record<string, unknown>));
      if (command.type === "addOtherLine") return sendJson(res, 200, await addOtherLine(quoteWorkflow!)(context as unknown as Record<string, unknown>));
      if (command.type === "addSupplierDiscount") return sendJson(res, 200, await addSupplierDiscount(quoteWorkflow!)(context as never));
      if (command.type === "addLaborEntry") {
        const { type: _type, quoteLineId, expectedRevision, employeeNameSnapshot, hours, costRateSnapshot, saleRateSnapshot, supplementPerHourSnapshot } = command;
        return sendJson(res, 200, await addLaborEntry(quoteWorkflow!)({ installationId: installationId!, quoteId: path[1]!, quoteLineId, expectedRevision, entry: { employeeNameSnapshot, hours, costRateSnapshot, saleRateSnapshot, supplementPerHourSnapshot } }));
      }
      if (command.type === "addPriceAdjustment") {
        const { type: _type, expectedRevision, scope, mode, value, targetLineIds } = command;
        return sendJson(res, 200, await addPriceAdjustment(quoteWorkflow!)({ installationId: installationId!, quoteId: path[1]!, expectedRevision, adjustment: { scope, mode, value, targetLineIds } }));
      }
      if (command.type === "addQuoteText") return sendJson(res, 200, await addQuoteText(quoteWorkflow!)(context as never));
      if (command.type === "archiveQuote") return sendJson(res, 200, await archiveQuote(quotes!)({ installationId: installationId!, id: path[1]!, expectedRevision: command.expectedRevision, status: "archived" }));
      return sendJson(res, 200, await executeQuoteCommand(quoteWorkflow!, context as unknown as Record<string, unknown>));
    }
    if (path[0] === "quotes" && path.length === 2 && req.method === "PATCH") {
      const parsed = revisionGuardSchema.safeParse(await readBody(req));
      if (!parsed.success) return sendJson(res, 400, { error: "invalid_input" });
      return sendJson(res, 200, await archiveQuote(quotes!)({ installationId: installationId!, id: path[1]!, ...parsed.data }));
    }
    return sendJson(res, 404, { error: "not_found" });
  } catch (error) {
    return mapError(res, error);
  }
});

server.listen(port, host, () => {
  console.log(`[api] listening on ${host}:${port}`);
});

function stop() {
  server.close(() => process.exit(0));
}

process.on("SIGTERM", stop);
process.on("SIGINT", stop);
