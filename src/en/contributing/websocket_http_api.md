# Lemmy API

*Note: this may lag behind the actual API endpoints [here](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/http.ts). The API should be considered unstable and may change any time.*

<!-- toc -->

- [Basic usage](#basic-usage)
- [Data types](#data-types)
  * [Lemmy Types](#lemmy-types)
  * [Lower-level types](#lower-level-types)
  * [Sort Types](#sort-types)
- [Default Rate limits](#default-rate-limits)
- [Errors](#errors)
  * [Undoing actions](#undoing-actions)
- [Websocket vs HTTP](#websocket-vs-http)
- [HTTP](#http)
  * [Example](#example)
  * [Testing with Curl](#testing-with-curl)
    + [Get Example](#get-example)
    + [Post Example](#post-example)
- [Websocket](#websocket)
  * [Testing with Websocat](#testing-with-websocat)
  * [Testing with the WebSocket JavaScript API](#testing-with-the-websocket-javascript-api)
- [RSS / Atom feeds](#rss--atom-feeds)
  * [All](#all)
  * [Community](#community)
  * [User](#user)
- [Images](#images)
  * [Get](#get)
  * [Create](#create)
    + [Request](#request)
    + [Response](#response)
  * [Delete](#delete)

<!-- tocstop -->

## Basic usage

Request and response strings are in [JSON format](https://www.json.org).

## Data types

### Lemmy Types

- [Source tables, that have the columns / fields](https://github.com/LemmyNet/lemmy-js-client/blob/v2_api/src/interfaces/source.ts)
- [Aggregates (for things like scores)](https://github.com/LemmyNet/lemmy-js-client/blob/v2_api/src/interfaces/aggregates.ts)
- [Views - The main lemmy return types](https://github.com/LemmyNet/lemmy-js-client/blob/v2_api/src/interfaces/views.ts)
- [Request Forms / Responses are in this folder](https://github.com/LemmyNet/lemmy-js-client/tree/v2_api/src/interfaces/api)

### Lower-level types

- `?` designates an option which may be omitted in requests and not be present in responses. It will be of type ***SomeType***.
- `[SomeType]` is a list which contains objects of type ***SomeType***.
- The fields published, and updated are timestamp strings in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format. Timestamps will be UTC, your client must do the UTC -> local conversion.

### Sort Types

These go wherever there is a `sort` field. The available sort types are:

- `Active` - the hottest posts/communities, depending on votes, and newest comment publish date.
- `Hot` - the hottest posts/communities, depending on votes and publish date.
- `New` - the newest posts/communities
- `TopDay` - the most upvoted posts/communities of the current day.
- `TopWeek` - the most upvoted posts/communities of the current week.
- `TopMonth` - the most upvoted posts/communities of the current month.
- `TopYear` - the most upvoted posts/communities of the current year.
- `TopAll` - the most upvoted posts/communities on the current instance.

## Default Rate limits

These can be edited in your `lemmy.hjson` file, by copying the relevant section from [defaults.hjson](https://github.com/LemmyNet/lemmy/blob/main/config/defaults.hjson).

- 3 per hour for signups and community creation.
- 6 per hour for image posting.
- 6 per 10 minutes for post creation.
- 180 actions per minute for post voting and comment creation.
- 
- Everything else is not rate-limited.

## Errors

```rust
{
  op: String,
  message: String,
}
```

### Undoing actions

Whenever you see a `deleted: bool`, `removed: bool`, `read: bool`, `locked: bool`, etc, you can undo this action by sending `false`:

```ts
// Un-delete a post
let form: DeletePost = {
  edit_id: ...
  deleted: false,
  auth: ...
}
```

## Websocket vs HTTP

- Below are the websocket JSON requests / responses. For HTTP, ignore all fields except those inside `data`.
- For example, an http login will be a `POST` `{username_or_email: X, password: X}`

## HTTP 

For documentation of the HTTP API, look at the [http.ts file in lemmy-js-client](https://github.com/LemmyNet/lemmy-js-client/blob/v2_api/src/http.ts).

Endpoints are at `http(s)://host/api/v2/endpoint`

### Example

```ts
async editComment(form: EditComment): Promise<CommentResponse> {
  return this.wrapper(HttpType.Put, '/comment', form);
}
```

| Type | url | Body Type | Return Type |
| --- | --- | --- | --- |
| `PUT` | `/comment` | `EditComment` | `CommentResponse` |

### Testing with Curl

#### Get Example

`curl "http://localhost:8536/api/v2/community/list?sort=Hot"`

#### Post Example

```
curl -i -H \
"Content-Type: application/json" \
-X POST \
-d '{
  "comment_id": X,
  "score": X,
  "auth": X
}' \
http://localhost:8536/api/v2/comment/like
```

## Websocket

The websocket commands are in [websocket.ts](https://github.com/LemmyNet/lemmy-js-client/blob/v2_api/src/websocket.ts), and exactly match the http commands, 

Connect to <code>ws://***host***/api/v2/ws</code> to get started.

If the ***`host`*** supports secure connections, you can use <code>wss://***host***/api/v1/ws</code>.

To receive websocket messages, you must join a room / context. The four available are:

- UserJoin. Receives replies, private messages, etc.
- PostJoin. Receives new comments on a post.
- CommunityJoin. Receives front page / community posts.
- ModJoin. Receives community moderator updates like reports.

### Testing with Websocat

[Websocat link](https://github.com/vi/websocat)

`websocat ws://127.0.0.1:8536/api/v2/ws -nt`

A simple test command:
`{"op": "ListCategories"}`

### Testing with the WebSocket JavaScript API

[WebSocket JavaScript API](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)

```javascript
var ws = new WebSocket("ws://" + host + "/api/v2/ws");
ws.onopen = function () {
  console.log("Connection succeed!");
  ws.send(JSON.stringify({
    op: "ListCategories"
  }));
};
```

## RSS / Atom feeds

### All

`/feeds/all.xml?sort=Hot`

### Community

`/feeds/c/community-name.xml?sort=Hot`

### User

`/feeds/u/user-name.xml?sort=Hot`

## Images

Lemmy forwards image requests to a locally running Pictrs.

### Get

*Format and thumbnail are optional.*

`GET /pictrs/image/{filename}?format={webp, jpg, ...}&thumbnail={96}`

### Create

#### Request

Uploaded content must be valid multipart/form-data with an image array located within the images[] key.

`POST /pictrs/image` 

#### Response

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

### Delete

`GET /pictrs/image/delete/{delete_token}/{file}`

