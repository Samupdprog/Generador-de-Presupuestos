# ADR-001 — Monorepo TypeScript

Estado: aceptado.

## Decisión

Usamos un monorepo pnpm con `apps/*` y `packages/*`.

## Motivo

API, worker y MCP comparten contratos y tipos, pero deben desplegarse como procesos independientes.

El monorepo permite compartir código sin duplicar procesos.

No usamos una herramienta adicional de orquestación de builds mientras `pnpm -r` sea suficiente.
