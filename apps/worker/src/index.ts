import { createServer } from "node:http";

const host = process.env.HOST ?? "0.0.0.0";
const port = Number(process.env.PORT ?? "4002");

const health = createServer((req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify({
      status: "ok",
      service: "worker",
      timestamp: new Date().toISOString()
    }));
    return;
  }

  res.writeHead(404).end();
});

health.listen(port, host, () => {
  console.log(`[worker] health endpoint on ${host}:${port}`);
  console.log("[worker] job processing intentionally not enabled yet");
});

function stop() {
  health.close(() => process.exit(0));
}

process.on("SIGTERM", stop);
process.on("SIGINT", stop);
