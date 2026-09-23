#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Uso:"
  echo "  $0 INSTANCE_SLUG APP_HOST MCP_HOST ACME_EMAIL"
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/.env"

if [ -e "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE ya existe. No se sobrescribe."
  exit 1
fi

SLUG="$1"
APP_HOST="$2"
MCP_HOST="$3"
ACME_EMAIL="$4"

case "$SLUG" in
  *[!a-z0-9-]*|"")
    echo "ERROR: INSTANCE_SLUG solo puede usar a-z, 0-9 y guiones."
    exit 1
    ;;
esac

command -v openssl >/dev/null 2>&1 || {
  echo "ERROR: openssl es necesario para generar secretos."
  exit 1
}

POSTGRES_PASSWORD="$(openssl rand -hex 32)"
INTERNAL_SERVICE_TOKEN="$(openssl rand -hex 32)"

cat > "$ENV_FILE" <<EOF
INSTANCE_SLUG=$SLUG
APP_NAME=Generador de Presupuestos
TZ=Atlantic/Canary

APP_HOST=$APP_HOST
MCP_HOST=$MCP_HOST
TRAEFIK_NETWORK=app-net
ACME_EMAIL=$ACME_EMAIL

WEB_PORT=3000
API_PORT=4000
MCP_PORT=4001
WORKER_HEALTH_PORT=4002
POSTGRES_PORT=5432

POSTGRES_DB=quotes
POSTGRES_USER=quotes
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
DATABASE_URL=postgresql://quotes:$POSTGRES_PASSWORD@postgres:5432/quotes

INTERNAL_API_URL=http://api:4000
INTERNAL_SERVICE_TOKEN=$INTERNAL_SERVICE_TOKEN

HOLDED_API_KEY=

MCP_AUTH_MODE=disabled
MCP_REQUIRED_SCOPES=clients:read,clients:write,quotes:read,quotes:write,holded:read,holded:write
AUTH_ISSUER_URL=
AUTH_AUDIENCE=
AUTH_JWKS_URL=
EOF

chmod 600 "$ENV_FILE"
echo "Creado $ENV_FILE con permisos 600."
echo "Los secretos no se muestran en pantalla."
