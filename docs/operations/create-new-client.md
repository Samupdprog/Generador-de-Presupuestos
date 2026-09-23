# Crear una instalacion cliente

El repositorio base es generico. No se crean ramas permanentes por cliente.
Cada instalacion vive en su propio repositorio y se actualiza desde `upstream`.

## Crear el repositorio

Usa **Use this template** sobre `Samupdprog/Generador-de-Presupuestos`, o:

```bash
git clone https://github.com/Samupdprog/Generador-de-Presupuestos.git cliente-presupuestos
cd cliente-presupuestos
git remote rename origin upstream
git remote add origin git@github.com:ORG/cliente-presupuestos.git
```

No uses una rama permanente para representar al cliente.

## Configurar identidad

```bash
./scripts/setup-instance.sh cliente app.cliente.com mcp.cliente.com admin@cliente.com
```

Edita `.env` para definir `INSTALLATION_NAME`, `APP_NAME`, locale, timezone,
moneda, impuestos y feature flags. El `.env` nunca se versiona.

La identidad fiscal es generica: `TAX_LABEL`, `TAX_DEFAULT_RATE` y
`TAX_ALLOWED_RATES`. Una instalacion canaria puede definir IGIC y sus tasas sin
cambiar el dominio.

## Branding y features

Personaliza `apps/web` y sus assets. Activa funciones mediante `FEATURE_*`; no
anadas comprobaciones por nombre de cliente al codigo comun.

## Base de datos y despliegue

```bash
docker compose up -d postgres
docker compose run --rm migrate
docker compose run --rm migrate npm run db:seed
docker compose up -d
```

Configura DNS para `APP_HOST` y `MCP_HOST`, y sigue
`docs/operations/deployment.md`.

## Verificacion y backup

```bash
curl https://app.cliente.com/api/health
./scripts/backup-postgres.sh
```

Comprueba tambien `pg_isready`, el historial Drizzle y los logs de Compose.

## Actualizar desde la base

```bash
git fetch upstream
git switch main
git merge upstream/main
git push origin main
```

Se usa merge para conservar historial explicito. No se hace force push sobre el
repositorio del cliente.
