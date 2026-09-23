# Migraciones

Nunca editar una base de producción manualmente como sustituto de una migración.

La migración baseline actual no debe reescribirse después de aplicarse. Los
cambios posteriores deben generar migraciones nuevas.

Generar una migración desde la raíz:

```bash
npm run db:generate
```

Aplicar todas las migraciones pendientes contra `DATABASE_URL`:

```bash
npm run db:mi
```

`npm run db:migrate` es un alias más descriptivo de `db:mi`.
