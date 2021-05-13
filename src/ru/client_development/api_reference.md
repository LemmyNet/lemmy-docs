# Справочник по API 

Lemmy имеет два взаимосвязанных API:
- [WebSocket (анг.язык)](https://join.lemmy.ml/api/index.html)
- [HTTP (анг.язык)](http_api.md)

На этой странице описаны общие для них концепции.

<!-- toc -->

- [Основное использование](#basic-usage)
- [Типы данных](#data-types)
  * [Типы Lemmy](#lemmy-types)
  * [Низкоуровневые типы](#lower-level-types)
- [Скоростные лимиты по умолчанию](#default-rate-limits)

<!-- tocstop -->

## Основное использование

Запрос и ответ строк [В формате JSON (анг.язык)](https://www.json.org).

## Типы данных

### Типы Lemmy

- [Исходные таблицы, в которых есть столбцы/поля (анг.язык)](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/source.ts)
- [Агрегирование (для таких вещей, как оценка) (анг.язык)](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/aggregates.ts)
- [Представления - основные возвращаемые типы Lemmy (анг.язык)](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/views.ts)
- [Формы запросов/ответов находятся в этой папке (анг.язык)](https://github.com/LemmyNet/lemmy-js-client/tree/main/src/interfaces/api)

### Низкоуровневые типы

- `?` обозначает параметр, который может быть опущен в запросах и отсутствовать в ответах. Это будет типа ***SomeType***.
- `[SomeType]` список, содержащий объекты типа ***SomeType***.
- Времена и даты временной метки  в строках [ISO 8601 (анг.язык)](https://en.wikipedia.org/wiki/ISO_8601) формата. Временные метки будут в формате UTC, ваш клиент должен выполнить преобразование UTC в локальный формат.

## Скоростные лимиты по умолчанию

Их можно редактировать в вашем  `lemmy.hjson` файле, скопировав соответствующий раздел из [defaults.hjson (анг.язык)](https://github.com/LemmyNet/lemmy/blob/main/config/defaults.hjson).

- 3 в час за регистрацию и создание сообщества.
- 6 в час за размещение изображений.
- 6 за 10 минут на создание поста. 
- 180 действий в минуту для постголосования и создания комментариев.

Все остальное не ограничено по скорости.

**Смотри также:** [ограничение скорости для пользовательских интерфейсов (анг.язык)](custom_frontend.md#rate-limiting).
