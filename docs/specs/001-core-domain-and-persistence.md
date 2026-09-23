# Spec 001 — Núcleo de dominio y persistencia

Estado: en implementación.

## Objetivo

Definir el primer núcleo funcional para clientes, catálogos y presupuestos, con
calculación determinista, revisiones optimistas, auditoría e integración externa
idempotente.

## Dominio

- Los catálogos locales incluyen materiales, proveedores, desplazamientos,
  empleados, suplementos y textos habituales.
- Seleccionar un elemento del catálogo copia sus valores a la línea; los cambios
  posteriores del catálogo no modifican presupuestos existentes.
- Las líneas soportan material, mano de obra, desplazamiento, ajuste y otros.
- Una línea de mano de obra puede contener varias entradas de empleados. Los
  valores usados son snapshots editables del presupuesto.
- Las reglas de venta son `unit_price`, `fixed_line_total`, `add_euros_per_unit`
  y `add_percentage`. Los descuentos de proveedor se aplican consecutivamente.
- Los ajustes posteriores son una capa auditable independiente de `saleRule`.
  Los ajustes por selección o presupuesto se reparten proporcionalmente entre
  líneas elegibles con venta positiva; las líneas `adjustment` se excluyen por
  defecto y el residuo de céntimos es determinista.
- El total comercial se calcula antes del impuesto. El impuesto se aplica al
  total final. Beneficio, beneficio sobre coste y margen sobre venta son métricas
  distintas.

## Persistencia y consistencia

- PostgreSQL es la fuente persistente y usa UUID, `numeric`, `timestamptz` y
  `jsonb` solo cuando corresponde.
- Cada presupuesto tiene `revision`; toda mutación relevante exige
  `expectedRevision` y produce conflicto si no coincide.
- Una mutación económica confirmada guarda cálculo, snapshot/version y auditoría
  en la misma transacción.
- La auditoría identifica actor `user`, `ai`, `worker` o `system`.
- Clientes y presupuestos conservan IDs externos de Holded como strings,
  estados de sincronización y snapshots/hash. Las operaciones externas son
  idempotentes y se relacionan por ID, nunca por nombre.
- Webhooks, operaciones externas y jobs tienen claves idempotentes, reintentos y
  estado observable.

## Criterios de aceptación

El motor puro pasa sus pruebas de dinero, descuentos consecutivos, mano de obra,
reglas de venta, métricas, ajustes y reparto proporcional. La persistencia
mantiene las invariantes anteriores mediante constraints y transacciones. API,
worker y MCP consumen application/domain sin duplicar reglas económicas.

## Compatibilidad

La implementación se divide en dominio, schema/migraciones, repositorios,
application y adaptadores. Cada bloque se valida con tests y typecheck antes de
continuar. No introduce multi-tenancy ni sustituye PostgreSQL por estado en
memoria.