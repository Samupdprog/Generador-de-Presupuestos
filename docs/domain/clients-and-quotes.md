# Clientes y presupuestos

## Clientes

La base local es la fuente de estado de la aplicación.

Una integración externa puede asociar IDs remotos, pero los nombres nunca sustituyen a los identificadores como relación.

## Presupuestos

Cada presupuesto debe poder recuperarse por `quoteId` sin depender del contexto previo de una IA.

Conceptos previstos:

- `id`;
- `revision`;
- `origin`;
- `accessMode`;
- cliente;
- líneas ordenadas;
- ajustes de precio;
- textos;
- estado;
- auditoría;
- sincronización externa.

Presupuestos importados desde Holded podrán usar:

```text
origin=holded
access_mode=read_only
```

hasta que una especificación futura defina otro comportamiento.
