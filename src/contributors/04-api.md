## API

Lemmy has an HTTP API for clients and frontends. See the [API documentation](/api) for more information. Instead of using the API directly you can use one of the existing [libraries](https://github.com/LemmyNet/lemmy#libraries). You can either interact with a local development instance via `http://localhost:8536`, or connect to a production instance. The following instances are available for testing purposes:

- https://enterprise.lemmy.ml/
- https://ds9.lemmy.ml/
- https://voyager.lemmy.ml/

### Curl Examples

**GET example**

The current api `{version}` is [here](https://github.com/LemmyNet/lemmy-js-client/blob/main/src/types/others.ts#L1).

```
curl "https://lemmy.ml/api/{version}/community/list?sort=Hot"`
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
https://lemmy.ml/api/{version}/comment/like
```

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

### Rust API

If you want to develop a Rust application which interacts with Lemmy, you can directly pull in the relevant API structs. This uses the exact API structs used in Lemmy, but with most heavyweight dependencies disabled. API paths or HTTP client are not included, so you need to handle those aspects manually. To get started, run `cargo add lemmy_api_common` in your repository. You can then use the following code to make an API request:

```rust
use lemmy_api_common::post::{GetPosts, GetPostsResponse};
use lemmy_db_schema::{ListingType, SortType};
use ureq::Agent;

pub fn list_posts() -> GetPostsResponse {
    let params = GetPosts {
        type_: Some(ListingType::Local),
        sort: Some(SortType::New),
        ..Default::default()
    };
    Agent::new()
        .get("https://lemmy.ml/api/v3/post/list")
        .send_json(&params).unwrap()
        .into_json().unwrap()
}
```

You can also look at the following real-world projects as examples:

- [lemmyBB](https://github.com/LemmyNet/lemmyBB)
- [lemmy-stats-crawler](https://github.com/LemmyNet/lemmy-stats-crawler)

### Creating a Custom Frontend

The Lemmy backend and frontend are completely separate projects. This creates a lot of potential for alternative frontends which can change much of the design and user experience of Lemmy. For example, it is possible to create a frontend in the style of a traditional forum like [phpBB](https://www.phpbb.com/), a question-and-answer site like [Stack Overflow](https://stackoverflow.com/), a blogging platform or an image gallery. This way you don't have to write any SQL queries, federation logic, API code and so on, but can use the proven implementation from Lemmy. It is also possible to run multiple frontends for a single Lemmy instance.

#### Development

The easiest way to get started is by forking one of the [existing frontends](https://join-lemmy.org/apps). But you can also create a new frontend from scratch. In any case the principle is the same: bind to a port to serve user requests, and connect to the API of a Lemmy instance as described above to fetch data.

#### Translations

You can add the [lemmy-translations](https://github.com/LemmyNet/lemmy-translations) repository to your project as a [git submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules). That way you can take advantage of same translations used in the official frontend, and you will also receive new translations contributed via Weblate.

#### Rate limiting

Lemmy does rate limiting for many actions based on the client IP. But if you make any API calls on the server side (e.g. in the case of server-side rendering, or javascript pre-rendering), Lemmy will take the IP of the Docker container. Meaning that all requests come from the same IP, and get rate limited much earlier. To avoid this problem, you need to pass the actual client IP via `Forwarded` or `X-Forwarded-For` HTTP header.
