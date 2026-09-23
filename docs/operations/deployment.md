# Despliegue

## Servidor desconocido

Primero:

```bash
sudo ./infra/server-audit/audit.sh
```

Revisar:

- puertos 80/443;
- Traefik existente;
- red Docker compartida;
- proyectos Compose existentes;
- volúmenes;
- mounts;
- espacio en disco;
- políticas de restart.

## Servidor con Traefik existente

Crear DNS de `APP_HOST` y `MCP_HOST`.

Después:

```bash
./scripts/setup-instance.sh ...
./scripts/preflight.sh
./scripts/deploy.sh
```

## Servidor sin Traefik

Usar `infra/traefik` una sola vez para el servidor.

No instalar un Traefik por cada cliente.

## Actualización

```bash
git pull --ff-only
./scripts/deploy.sh
```

## Logs

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f --tail=200
```
