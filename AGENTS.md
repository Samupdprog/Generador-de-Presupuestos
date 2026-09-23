# AGENTS.md

Estas reglas aplican a cualquier agente o IA que modifique este repositorio.

## Antes de cambiar código

1. Lee `docs/README.md`, `docs/architecture.md` y `docs/rules.md`.
2. Si el cambio afecta comportamiento, contratos, persistencia, seguridad o despliegue, crea/actualiza una spec en `docs/specs/`.
3. Si cambia una decisión arquitectónica estable, añade un ADR.

## Límites

- No duplicar reglas económicas en `apps/web` o `apps/mcp`.
- No permitir SQL libre desde MCP.
- No escribir importes económicos saltándose el motor de dominio.
- No usar JavaScript `number` como representación monetaria canónica.
- No introducir multi-tenancy sin una spec/ADR explícita.
- No exponer secretos mediante variables `NEXT_PUBLIC_*`.
- No modificar una base de producción manualmente como sustituto de una migración.

## Cambios pequeños

Preferir implementaciones pequeñas y legibles a abstracciones prematuras.
No crear capas nuevas si una interfaz o función existente resuelve el problema claramente.

## Finalización

Antes de cerrar un cambio:

```bash
pnpm typecheck
pnpm test
pnpm build
```

Si cambia infraestructura, validar también Compose y actualizar `docs/operations/`.
