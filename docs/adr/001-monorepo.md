# ADR-001 — Monorepo TypeScript

Estado: aceptado.

## Decisión

Usamos un monorepo npm con workspaces en `apps/*` y `packages/*`.

## Motivo

API, worker y MCP comparten contratos y tipos, pero deben desplegarse como procesos independientes.

El monorepo permite compartir código sin duplicar procesos.

No usamos una herramienta adicional de orquestación de builds mientras los scripts de workspaces de npm sean suficientes.
