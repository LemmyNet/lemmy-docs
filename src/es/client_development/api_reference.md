# Referencia de la API

Lemmy tiene dos APIs entrelazadas:

- [WebSocket](https://join-lemmy.org/api/index.html)
- [HTTP](http_api.md)

Esta página describe conceptos que son comúnes para ambas.

<!-- toc -->

- [Uso básico](#uso-básico)
- [Tipos de datos](#tipos-de-datos)
  - [Tipos de Lemmy](#tipos-de-lemmy)
  - [Tipos de bajo nivel](#tipos-de-bajo-nivel)
- [Límites de tarifa por defecto](#límites-de-tarifa-por-defecto)

<!-- tocstop -->

## Uso básico

Las cadenas de solicitud `request` y respuesta `response` están en [formato JSON](https://www.json.org/json-es.html).

## Tipos de datos

### Tipos de Lemmy

- [tablas que tienen las columnas / campos](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/source.ts)
- [Aggregates (para cosas como las puntuaciones)](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/aggregates.ts)
- [Views (vistas) - The main lemmy return types](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/views.ts)
- [Los formularios de solicitud (Request) / respuesta (Responses)](https://github.com/LemmyNet/lemmy-js-client/tree/main/src/interfaces/api)

### Tipos de bajo nivel

- `?` designa una opción que puede omitirse en las solicitudes y no estar presenet en las respuestas. Será de tipo **_SomeType_** (AlgúnTipo).
- `[SomeType]` es una lista que contiene objetos del tipo **_SomeType_**.
- Las horas (times) y fechas (dates) son cadenas de marcas de tiempo (timestamp) en formato [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601). Timestamps serán UTC, tú cliente debe hacer la conversión de UTC a local.

## Límites de tasa por defecto

Estos límites pueden ser editados en tú archivo `lemmy.hjson`, copiando la sección relevante de [defaults.hjson](https://github.com/LemmyNet/lemmy/blob/main/config/defaults.hjson).

- 3 por hora para inscripciones y creación de comunidades.
- 6 por hora para publicación de imágenes.
- 6 por 10 minutos para la creación de publicaciones.
- 180 acciones por minuto para la votación de publicaciones y la creación de comentarios.

El resto no cuenta con límites de tasa.

**Véase también:** [Limitación de la tasa para front-ends personalizados](custom_frontend.md#limitación-de-la-tasa).
