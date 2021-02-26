# Lemmy HTTP API


<!-- toc -->

- [Websocket vs HTTP API](#websocket-vs-http-api)
- [Examples](#examples)
  * [TypeScript](#typescript)
  * [Curl](#curl)
    + [GET](#get-example)
    + [POST](#post-example)
- [HTTP API exclusive features](#http-api-exclusive-features)
  * [RSS/Atom feeds](#rss-atom-feeds)
  * [Images](#images)
    + [Create (request)](#create-request)
    + [Create (response)](#create-response)
    * [Delete](#delete)

<!-- tocstop -->

## WebSocket vs HTTP API
Lemmy's HTTP API is almost identical to its WebSocket API:
- **WebSocket API** needs `let send = { op: userOperation[op], data: form}` as shown in [the WebSocketAPI specification](https://join.lemmy.ml/api/index.html))
- **HTTP API** needs the form (data) at the top level, an HTTP operation (GET, PUT or POST) and endpoint (at `http(s)://host/api/v2/endpoint`). For example:

> `POST {username_or_email: X, password: X}`

For more information, see the [http.ts](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/http.ts) file.

[The WebSocket API](Add_link) should be regarded as the primary source for the HTTP API since it also provides information about how to form HTTP API calls.

## Examples

### TypeScript

```ts
  async editComment(form: EditComment): Promise<CommentResponse> {
  return this.wrapper(HttpType.Put, '/comment', form);
  }
```

| Type | URL | Body type | Return type |
| --- | --- | --- | --- |
| `PUT` | `/comment` | `EditComment` | `CommentResponse` |

### Curl

**GET example**

```
curl "http://localhost:8536/api/v2/community/list?sort=Hot"`
```

**POST example**

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

## HTTP API exclusive features

These features cannot be accessed from the WebSocket API:

- [RSS/Atom feeds](#rss-atom-feeds)
- [Images](#images)

### RSS/Atom feeds

- All - `/feeds/all.xml?sort=Hot`
- Community - `/feeds/c/community-name.xml?sort=Hot`
- User - `/feeds/u/user-name.xml?sort=Hot`

### Images

Lemmy forwards image requests to a locally running Pictrs.

`GET /pictrs/image/{filename}?format={webp, jpg, ...}&thumbnail={96}`

*Format and thumbnail are optional.*

#### Create (request)

Uploaded content must be valid multipart/form-data with an image array located within the images[] key.

`POST /pictrs/image` 

#### Create (response)

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


# Note

This documentation may lag behind the actual [API endpoints](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/http.ts) and the API itself should be considered unstable (since it may change at any time).
