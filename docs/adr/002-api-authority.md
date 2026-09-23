# ADR-002 — API como frontera de mutaciones externas

Estado: aceptado.

## Decisión

Web y MCP no escriben directamente en PostgreSQL.

Las mutaciones externas llegan a la API y allí se ejecutan los casos de uso de `packages/application`.

## Consecuencia

MCP puede evolucionar o cambiar de protocolo sin duplicar reglas ni permisos.

Worker sigue siendo un ejecutor backend confiable para jobs internos definidos explícitamente.
