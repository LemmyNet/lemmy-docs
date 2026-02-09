# Lemmy Plugins

Plugin support will be added in the upcoming 1.0 release. You can already start developing plugins now.

Follow these steps:

- Follow the normal [setup instructions](/docs/administration/administration.html), using `:nightly` tags to get the latest development version.
- Specify plugins in `lemmy.hjson` ([docs](https://github.com/LemmyNet/lemmy/blob/main/config/defaults.hjson#L130)):

```json
plugins: [{
  file: "https://github.com/LemmyNet/lemmy-plugins/releases/download/0.1.3/rust_lingua.wasm",
  hash: "e1f58029f2ecca5127a4584609494120683b691fc63a543979ea071f32cf690f",
  allowed_hosts: ["0.0.0.0"]
}]
```

- You can skip the hash check by setting the env var `DANGER_PLUGIN_SKIP_HASH_CHECK`.

Plugins are implemented using [Extism](https://extism.org/) and Webassembly. They can be written in any language that compiles to Wasm. Checkout the [documentation](https://extism.org/docs/quickstart/plugin-quickstart) for general development instructions.

The [lemmy-plugins](https://github.com/LemmyNet/lemmy-plugins/) repo contains various example plugins written in different languages.

### API `before` hooks

These are called before a given API endpoint is invoked, with the raw JSON data submitted by the user, and need to return data in the same format. Useful for moderation bots which can alter or reject posts.

Examples:

- `local_post_before_create` with data [CreatePost](https://github.com/LemmyNet/lemmy/blob/main/crates/db_views/post/src/api.rs#L16)
- `local_comment_before_update` with data [EditComment](https://github.com/LemmyNet/lemmy/blob/main/crates/db_views/comment/src/api.rs#L145)
- `federated_post_before_receive` with [PostInsertForm](https://github.com/LemmyNet/lemmy/blob/main/crates/db_schema/src/source/post.rs#L97)
- Search the code for `plugin_hook_before` to find all available hooks

### API `after` hooks

Called after an endpoint was successfully invoked and gets passed the API return data. Useful for notifications.

Examples:

- `local_post_after_create` with data [CreatePost](https://github.com/LemmyNet/lemmy/blob/main/crates/db_views/post/src/api.rs#L16)
- `local_comment_after_update` with data [EditComment](https://github.com/LemmyNet/lemmy/blob/main/crates/db_views/comment/src/api.rs#L145)
- `federated_post_after_receive` with [Post](https://github.com/LemmyNet/lemmy/blob/main/crates/db_schema/src/source/post.rs#L25)
- Search the code for `plugin_hook_before` to find all available hooks

### Captcha Plugin

- `get_captcha`
- `validate_captcha`
