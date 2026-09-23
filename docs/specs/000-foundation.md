# SPEC-000 — Foundation

Estado: implementada

## Objetivo

Crear una base reutilizable del Generador de Presupuestos antes de implementar funcionalidades comerciales.

## Incluye

- monorepo TypeScript;
- apps separadas para web, API, MCP y worker;
- paquetes de dominio, aplicación, DB, Holded, contratos y auth;
- Dockerfiles;
- PostgreSQL persistente;
- redes separadas;
- integración con Traefik compartido;
- healthchecks;
- SDD;
- CI;
- auditoría de servidores;
- scripts de bootstrap, deploy, backup y restore.

## No incluye

- interfaz comercial terminada;
- esquema final de presupuestos;
- integración Holded completa;
- tools MCP de negocio;
- autenticación OAuth terminada.

## Criterios

- [x] estructura entendible por carpetas;
- [x] ningún secreto se versiona;
- [x] PostgreSQL no se publica a Internet;
- [x] web/MCP/API/worker son procesos independientes;
- [x] existe un procedimiento para inspeccionar un VPS antes de desplegar.
