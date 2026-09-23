# Generador de Presupuestos

Base reutilizable para construir generadores de presupuestos personalizados sin rehacer backend, dominio, base de datos, MCP e infraestructura para cada cliente.

La intención es sencilla:

1. clonar el repositorio;
2. configurar `.env`;
3. personalizar principalmente `apps/web`;
4. mantener estable el núcleo de dominio y aplicación;
5. desplegar el mismo conjunto de servicios.

No es un SaaS multi-tenant. Cada cliente puede tener una instalación aislada y fácil de entender.

## Arquitectura

```text
apps/
├── web       Next.js; capa visual reemplazable
├── api       HTTP; única entrada para operaciones de usuario/IA
├── mcp       MCP remoto; traduce tools a comandos de la API
└── worker    sincronización, webhooks, reintentos y trabajos

packages/
├── domain        reglas puras y motor de presupuestos
├── application   commands/queries y casos de uso
├── db            PostgreSQL + Drizzle + migraciones
├── holded        adaptador Holded
├── contracts     contratos y validación compartida
└── auth          identidad, permisos y scopes
```

Regla central:

```text
Web ─────┐
         ├──> API ──> Application ──> Domain ──> DB
MCP ─────┘

Worker ─────> Application/Domain para trabajos internos autorizados
```

Ni Next.js ni MCP contienen reglas económicas.

## Documentación / SDD

Antes de implementar una funcionalidad relevante se crea o actualiza una especificación en:

```text
docs/specs/
```

Lee primero:

- `docs/README.md`
- `docs/sdd.md`
- `docs/architecture.md`
- `docs/rules.md`

No se pretende documentar cada línea de código. Se documentan decisiones, contratos, invariantes, flujos y criterios de aceptación.

## Desarrollo local

Requisitos:

- Node.js 22+
- npm 11+
- Docker + Docker Compose

```bash
npm install
cp .env.example .env
```

Generar un `.env` seguro para una nueva instalación:

```bash
./scripts/setup-instance.sh \
  cliente-demo \
  presupuestos.example.com \
  mcp.example.com \
  admin@example.com
```

Levantar PostgreSQL:

```bash
docker compose up -d postgres
```

Desarrollo web:

```bash
npm run dev:web
```

## Producción

Si el servidor ya tiene Traefik compartido:

```bash
./scripts/preflight.sh
./scripts/deploy.sh
```

Si el servidor está vacío, primero revisa:

```text
infra/traefik/README.md
```

No levantes un segundo Traefik si ya existe uno usando 80/443.

## Auditoría de un servidor

Antes de instalar en un VPS desconocido:

```bash
sudo ./infra/server-audit/audit.sh
```

Genera un informe sanitizado con Docker, Compose, redes, volúmenes, puertos, mounts y rutas para comprender el servidor antes de modificarlo.

Consulta `infra/server-audit/README.md`.

## Estado actual

Esta rama deja preparada la base técnica. Todavía no implementa la aplicación comercial completa, la sincronización Holded ni el catálogo completo de tools MCP.

El desarrollo funcional debe continuar mediante especificaciones SDD pequeñas y verificables.
