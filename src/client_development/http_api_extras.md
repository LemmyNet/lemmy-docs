# Lemmy HTTP API Extras

This contains extras not in the [API docs](/api).

<!-- toc -->

- [Curl Examples](#curl-examples)
- [HTTP API exclusive features](#http-api-exclusive-features)
  - [RSS/Atom feeds](#rssatom-feeds)
  - [Images](#images)
    - [Create (request)](#create-request)
    - [Create (response)](#create-response)
    - [Delete](#delete)

<!-- tocstop -->

## Curl Examples

**GET example**

The current api `{version}` is [here](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/interfaces/others.ts#L1).

```
curl "http://localhost:8536/api/{version}/community/list?sort=Hot"`
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
http://localhost:8536/api/{version}/comment/like
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

_Format and thumbnail are optional._

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
