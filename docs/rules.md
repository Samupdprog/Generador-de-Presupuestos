# Reglas no negociables

Estas reglas protegen la reutilización del producto.

1. El motor de presupuestos es la única autoridad económica.
2. Next.js no replica cálculos de negocio.
3. MCP no replica cálculos ni accede libremente a SQL.
4. Las mutaciones pasan por commands tipados.
5. Mutaciones concurrentes usan `expectedRevision`.
6. Acciones de IA quedan auditadas.
7. Dinero no usa `number`; dominio usa `decimal.js`.
8. PostgreSQL usa `numeric` para dinero.
9. `.env` real nunca entra en Git.
10. Holded y claves de IA nunca llegan al navegador.
11. Un cambio de esquema siempre tiene migración.
12. Un ajuste posterior de precio no reescribe silenciosamente la regla original.
13. El estado persistente vive en PostgreSQL, no en la memoria de una IA.
14. Los endpoints públicos se reducen al mínimo necesario.
15. El código específico de un cliente no debe contaminar `packages/domain`.
