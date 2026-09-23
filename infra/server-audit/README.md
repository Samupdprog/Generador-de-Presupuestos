# Auditoría de servidor

Antes de desplegar en un VPS que ya contiene aplicaciones:

```bash
sudo ./audit.sh
```

El script es de solo lectura y recopila:

- SO, CPU, memoria y disco;
- Docker/Compose;
- contenedores;
- proyecto Compose de cada contenedor;
- networks;
- mounts;
- volúmenes;
- puertos;
- Traefik;
- rutas de proyectos;
- systemd y cron relevantes.

No imprime los valores de `.env` y redacta nombres habituales de secretos.

Aun así, revisa el informe antes de compartirlo porque un proyecto puede usar un nombre de secreto no convencional.

El objetivo no es automatizar cambios: es obtener contexto suficiente antes de tocar un servidor existente.
