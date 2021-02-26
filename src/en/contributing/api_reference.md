# API reference

Lemmy has two, intertwined APIs:
- [WebSocket](https://join.lemmy.ml/api/index.html)
- [HTTP](http_api.md)

This page describes concepts that are common to both.

<!-- toc -->

- [Basic usage](#basic-usage)
- [Data types](#data-types)
  * [Lemmy types](#lemmy-types)
  * [Lower-level types](#lower-level-types)
- [Default rate limits](#default-rate-limits)

<!-- tocstop -->

## Basic usage

Request and response strings are in [JSON format](https://www.json.org).

## Data types

### Lemmy types

- [Source tables, that have the columns / fields](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/source.ts)
- [Aggregates (for things like scores)](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/aggregates.ts)
- [Views - The main lemmy return types](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/views.ts)
- [Request Forms / Responses are in this folder](https://github.com/LemmyNet/lemmy-js-client/tree/main/src/interfaces/api)

### Lower-level types

- `?` designates an option which may be omitted in requests and not be present in responses. It will be of type ***SomeType***.
- `[SomeType]` is a list which contains objects of type ***SomeType***.
- Times and dates are timestamp strings in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format. Timestamps will be UTC, your client must do the UTC to local conversion.

## Default rate limits

These can be edited in your `lemmy.hjson` file, by copying the relevant section from [defaults.hjson](https://github.com/LemmyNet/lemmy/blob/main/config/defaults.hjson).

- 3 per hour for signups and community creation.
- 6 per hour for image posting.
- 6 per 10 minutes for post creation.
- 180 actions per minute for post voting and comment creation.

Everything else is not rate-limited.

**See also:** [rate limiting for custom front-ends](custom_frontend.md#rate-limiting).
