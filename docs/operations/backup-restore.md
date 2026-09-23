# Backup y restauración

## Backup manual

```bash
./scripts/backup-postgres.sh
```

Los backups se guardan fuera de Git en `backups/`.

## Restauración

```bash
RESTORE_CONFIRM=YES ./scripts/restore-postgres.sh backups/archivo.dump
```

## Persistencia

El volumen tiene nombre estable derivado de `INSTANCE_SLUG`.

Reiniciar Docker o recrear los contenedores no elimina el volumen.

No usar:

```bash
docker compose down -v
```

salvo que se quiera borrar deliberadamente la base de datos.
