# Traefik compartido

Este stack es para un servidor que todavía NO tenga reverse proxy.

Se instala una sola vez por VPS y después varios proyectos pueden conectarse a su red.

Si 80/443 ya están ocupados por Traefik, Nginx, Caddy u otro proxy, no ejecutes este Compose hasta revisar el servidor.

## Crear `.env`

```bash
cp .env.example .env
nano .env
```

## Levantar

```bash
docker compose up -d
```

La red creada se llama `app-net` por defecto y las aplicaciones pueden usar:

```text
TRAEFIK_NETWORK=app-net
```
