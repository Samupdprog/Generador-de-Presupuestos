# ADR-004 — Instalación aislada por cliente

Estado: aceptado.

## Decisión

La plantilla se clona/despliega por cliente.

No introducimos multi-tenancy en el núcleo mientras no exista un requisito real.

## Motivo

Hace despliegue, soporte, backups y personalización más fáciles de entender.

Una futura versión SaaS requeriría una spec y ADR propios.
