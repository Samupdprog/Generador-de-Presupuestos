# Documentación

La documentación es parte del producto, pero debe seguir siendo pequeña y útil.

## Qué leer

1. `sdd.md` — cómo desarrollamos.
2. `architecture.md` — límites y dependencias.
3. `rules.md` — reglas que no se deben romper.
4. `domain/` — decisiones del negocio.
5. `adr/` — decisiones arquitectónicas importantes.
6. `specs/` — cambios funcionales concretos.
7. `operations/` — despliegue y mantenimiento.

## Principio

Si el código cambia una regla de negocio, un contrato, persistencia, seguridad o despliegue, debe existir una especificación o ADR que explique el porqué.

No documentamos detalles obvios que el código ya expresa mejor.
