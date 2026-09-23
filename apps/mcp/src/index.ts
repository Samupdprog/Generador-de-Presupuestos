import { createMcpExpressApp } from "@modelcontextprotocol/express";
import { toNodeHandler } from "@modelcontextprotocol/node";
import { createMcpHandler, McpServer } from "@modelcontextprotocol/server";

const host = process.env.HOST ?? "0.0.0.0";
const port = Number(process.env.PORT ?? "4001");
const publicHost = process.env.MCP_HOST ?? "localhost";

const handler = createMcpHandler(() => {
  // En SPECs futuras se registrarán tools.
  // Sus handlers llamarán al cliente interno de la API, nunca a SQL.
  return new McpServer({
    name: "generador-de-presupuestos",
    version: "0.1.0"
  });
});

const app = createMcpExpressApp({
  host,
  allowedHosts: [publicHost, "localhost", "127.0.0.1", "mcp"],
  allowedOrigins: [publicHost, "localhost", "127.0.0.1"]
});

const nodeHandler = toNodeHandler(handler);

app.get("/health", (_req, res) => {
  res.status(200).json({
    status: "ok",
    service: "mcp",
    toolsEnabled: false,
    timestamp: new Date().toISOString()
  });
});

app.all("/mcp", (req, res) => {
  // Bearer/OAuth se añadirá delante de esta ruta antes de habilitar tools reales.
  void nodeHandler(req, res, req.body);
});

const server = app.listen(port, host, () => {
  console.log(`[mcp] listening on ${host}:${port}`);
});

async function stop() {
  server.close(async () => {
    await handler.close();
    process.exit(0);
  });
}

process.on("SIGTERM", () => void stop());
process.on("SIGINT", () => void stop());
