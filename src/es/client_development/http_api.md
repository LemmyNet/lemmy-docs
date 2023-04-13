# API HTTP de Lemmy

<!-- toc -->

- [Websocket vs API HTTP](#websocket-vs-api-http)
- [Ejemplos](#ejemplos)
  - [TypeScript](#typescript)
  - [Curl](#curl)
    - [GET](#ejemplo-get)
    - [POST](#ejemplo-post)
- [Características exclusivas de la API HTTP](#características-exclusivas-de-la-api-http)
  - [RSS/Atom feeds](#rss-atom-feeds)
  - [Imagenes](#imagenes)
    - [Crear (request)](#crear-request)
    - [Crear (response)](#crear-response)
    * [Delete](#delete)

<!-- tocstop -->

## WebSocket vs API HTTP

La API HTTP de Lemmy es casi parecida a la API del Websocket:

- **API WebSocket** necesita `let send = { op: userOperation[op], data: form}` como se muestra en [la especificación de la API WebSocket](https://join-lemmy.org/api/index.html)
- **API HTTP** necesita el formulario (datos) en el primer nivel; una operación HTTP (GET, PUT o POST) y endpoint (en `http(s)://host/api/v2/endpoint`). Por ejemplo:

> `POST {username_or_email: X, password: X}`

Para más información. Véase el archivo
[http.ts](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/http.ts) .

[El API del WebSocket](https://join-lemmy.org/api/index.html) debería considerarse como la fuente principal para la API HTPP, ya que también proporciona información sobre cómo formular las llamadas a la API HTTP.

## Ejemplos

### TypeScript

```ts
  async editComment(form: EditComment): Promise<CommentResponse> {
  return this.wrapper(HttpType.Put, '/comment', form);
  }
```

| Tipo  | URL        | Tipo de cuerpo | Tipo de Retorno   |
| ----- | ---------- | -------------- | ----------------- |
| `PUT` | `/comment` | `EditComment`  | `CommentResponse` |

### Curl

#### Ejemplo GET

```
curl "http://localhost:8536/api/v2/community/list?sort=Hot"`
```

#### Ejemplo POST

```
curl -i -H \
"Content-Type: application/json" \
-X POST \
-d '{
  "comment_id": 374,
  "score": 1,
  "auth": eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MiwiaXNzIjoidGVzdC5sZW1teS5tbCJ9.P77RX_kpz1a_geY5eCp29sl_5mAm-k27Cwnk8JcIZJk
}' \
http://localhost:8536/api/v2/comment/like
```

## Características exclusivas de la API HTTP

Estas características no pueden ser accesadas desde la API del WebSocket:

- [RSS/Atom feeds](#rss-atom-feeds)
- [Imagenes](#imagenes)

### RSS/Atom feeds

- All (Todo) - `/feeds/all.xml?sort=Hot`
- Community (Comunidad) - `/feeds/c/community-name.xml?sort=Hot`
- User (usuario) - `/feeds/u/user-name.xml?sort=Hot`

### Imagenes

Leemy reenvía las peticiones de imagenes a un Pictrs que se ejecuta localmenet.

`GET /pictrs/image/{filename}?format={webp, jpg, ...}&thumbnail={96}`

_El formato (format) y la miniatura (thumbnail) son opcionales_

#### Crear (request)

El contenido subido debe ser un formulario (multipart/form-data) válido con una matriz de imagenes situada dentro de la clave `images[]`.

Uploaded content must be valid multipart/form-data with an image array located within the images[] key.

`POST /pictrs/image`

#### Crear (response)

```
{
  "files": [
    {
      "delete_token": "{token}",
      "file": "{file}.jpg"
    }
  ],
  "msg": "ok"
}
```

#### Delete

`GET /pictrs/image/delete/{delete_token}/{file}`

# Nota

Esta documentación puede tener un retraso con respecto a la actual
[API endpoints](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/http.ts). La API misma debería ser considerada inestable (está sujeta a cambios en cualquier momento).
