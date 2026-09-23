# SDD — Specification-Driven Development

Usamos SDD para evitar que el proyecto crezca por parches.

## Flujo

Para una funcionalidad relevante:

```text
Necesidad
  ↓
Spec corta
  ↓
Contratos e invariantes
  ↓
Criterios de aceptación
  ↓
Implementación
  ↓
Pruebas
  ↓
Migración/despliegue si aplica
  ↓
Spec marcada como implementada
```

## Una spec debe responder

- ¿Qué problema resuelve?
- ¿Qué comportamiento observable cambia?
- ¿Qué no cambia?
- ¿Qué capa es responsable?
- ¿Qué datos o contratos aparecen?
- ¿Qué invariantes deben mantenerse?
- ¿Cómo sabemos que está terminado?
- ¿Requiere migración, compatibilidad o rollback?

## Lo que evitamos

- implementar primero y justificar después;
- duplicar una regla en web, API y MCP;
- modificar tablas sin migración;
- cambiar contratos sin revisar consumidores;
- esconder decisiones arquitectónicas en comentarios sueltos.

## Tamaño

Una spec normal debería caber cómodamente en unas pocas páginas.

Si una spec empieza a contener varias funcionalidades independientes, se divide.
