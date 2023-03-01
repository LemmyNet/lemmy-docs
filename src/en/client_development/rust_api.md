# Rust API

If you want to develop a Rust application which interacts with Lemmy, you can directly pull in the relevant API structs. This relies on the exact code used in Lemmy, but with most heavyweight dependencies disabled (like diesel).

To get started, add the following to your `Cargo.toml`:

```
[dependencies]
lemmy_api_common = { git = "https://github.com/LemmyNet/lemmy.git" }
```

Note, at the time of writing, this code is not available on crates.io yet. You can use "0.16.3" from crates.io, but it pulls in many heavy dependencies including diesel. Best use the git dependency for now, or wait for a newer version to become available.

You can then use the following code to make an API request:

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
        .get("https://lemmy.ml/post/list")
        .send_json(&params).unwrap()
        .into_json().unwrap()
}
```

You can also look at the following real-world projects as examples:

- [lemmyBB](https://github.com/Nutomic/lemmyBB)
- [lemmy-stats-crawler](https://yerbamate.ml/LemmyNet/lemmy-stats-crawler)
