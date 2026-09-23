# GitHub

## Primera publicación

El repositorio remoto es:

```text
https://github.com/Samupdprog/Generador-de-Presupuestos
```

Desde la carpeta del proyecto:

```bash
git init
git branch -M main
git add .
git commit -m "chore: create reusable quote generator foundation"
git remote add origin https://github.com/Samupdprog/Generador-de-Presupuestos.git
git push -u origin main
```

## Trabajo diario

Usar ramas pequeñas:

```bash
git switch -c feature/nombre-corto
```

La PR debe enlazar la spec cuando el cambio no sea trivial.

## Nuevo cliente

Para una instalación derivada:

```bash
git clone https://github.com/Samupdprog/Generador-de-Presupuestos.git cliente-presupuestos
cd cliente-presupuestos
./scripts/setup-instance.sh cliente presupuestos.cliente.com mcp.cliente.com admin@cliente.com
```

Después se personaliza principalmente `apps/web`.
