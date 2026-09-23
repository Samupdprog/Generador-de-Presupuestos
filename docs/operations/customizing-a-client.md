# Personalizar para un cliente

El objetivo es que la mayor parte del trabajo visual ocurra en `apps/web`.

## Normalmente cambiarás

- diseño;
- logotipo;
- colores;
- textos;
- navegación;
- páginas;
- componentes visuales;
- dominio;
- variables de entorno.

## Normalmente NO cambiarás

- motor de presupuestos;
- commands;
- queries;
- esquema base de seguridad;
- MCP;
- worker;
- modelo de auditoría;
- infraestructura de PostgreSQL.

Si un cliente requiere una regla de negocio distinta, se crea una spec antes de modificar `packages/domain`.
