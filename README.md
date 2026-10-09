# NutriPlan

Aplicación móvil (Flutter) para seguir un plan de alimentación por equivalencias:
el nutriólogo captura la dieta y la comparte por QR o enlace; el usuario sin
nutriólogo recibe un plan generado por reglas. El usuario ve su plan del día,
cambia alimentos por equivalentes del mismo subgrupo, registra lo que comió y
sus hábitos, y ve su progreso.

Proyecto para la materia de Desarrollo Móvil, ITESO.

## Autores

- Andrés Gómez Tagle Azcárraga
- Eduardo Antonio Pelayo Carrillo

## Documentación de diseño

| Documento | Contenido |
|---|---|
| [docs/01-requerimientos.md](docs/01-requerimientos.md) | Problema, roles, alcance, requerimientos funcionales y no funcionales, riesgos |
| [docs/02-investigacion-tecnica.md](docs/02-investigacion-tecnica.md) | Decisiones de arquitectura (ADR), paquetes, esfuerzo, riesgos técnicos |
| [docs/03-hld.md](docs/03-hld.md) | Diseño de alto nivel: modelo conceptual, capas, componentes, flujos |
| [docs/04-lld.md](docs/04-lld.md) | Diseño detallado: entidades, esquema SQLite, servicios, pantallas, pruebas, calendario |
| [docs/README.md](docs/README.md) | Índice de la documentación y pendientes antes de codificar |

Los diagramas están en Mermaid y se renderizan directamente en GitHub.

## Estado

Diseño en versión 1.6 (aprobado tras 7 rondas de revisión). El código Flutter
se agrega en una siguiente etapa dentro de `app/`.
