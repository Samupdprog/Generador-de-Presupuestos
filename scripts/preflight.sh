#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

command -v docker >/dev/null 2>&1 || { echo "ERROR: falta Docker"; exit 1; }
docker compose version >/dev/null

[ -f .env ] || { echo "ERROR: falta .env. Usa scripts/setup-instance.sh"; exit 1; }

if grep -q 'CHANGE_ME' .env; then
  echo "ERROR: .env contiene CHANGE_ME."
  exit 1
fi

set -a
# shellcheck disable=SC1091
source .env
set +a

for name in INSTANCE_SLUG APP_HOST MCP_HOST POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD DATABASE_URL INTERNAL_SERVICE_TOKEN; do
  [ -n "${!name:-}" ] || { echo "ERROR: $name está vacío"; exit 1; }
done

docker compose config --quiet

echo "Compose base: OK"

if docker network inspect "${TRAEFIK_NETWORK:-app-net}" >/dev/null 2>&1; then
  echo "Red Traefik ${TRAEFIK_NETWORK:-app-net}: OK"
else
  echo "AVISO: no existe la red ${TRAEFIK_NETWORK:-app-net}."
  echo "En producción debes usar un Traefik existente o instalar infra/traefik."
fi

if ss -lnt 2>/dev/null | grep -Eq ':(80|443)[[:space:]]'; then
  echo "Información: 80/443 ya están en uso; revisa qué proxy los gestiona antes de instalar otro."
fi

if [ "${MCP_AUTH_MODE:-disabled}" = "disabled" ]; then
  echo "AVISO: MCP_AUTH_MODE=disabled. Mantén tools mutables deshabilitadas hasta integrar auth."
fi

echo "Preflight completado."
