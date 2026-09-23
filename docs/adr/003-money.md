# ADR-003 — Dinero exacto

Estado: aceptado.

## Decisión

- `decimal.js` en dominio/aplicación.
- strings decimales en contratos cuando cruza una frontera.
- `numeric` en PostgreSQL.
- no usar JavaScript `number` como valor monetario canónico.

## Motivo

Evitar errores binarios y redondeos implícitos en cálculos comerciales.
