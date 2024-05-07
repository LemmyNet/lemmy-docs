# Lemmy Plugins

To get started writing plugins, follow the instructions in [Local Development](https://join-lemmy.org/docs/contributors/02-local-development.html) to setup a local test instance from git. Checkout the `plugin-system` branch. See the [Extism documentation](https://github.com/extism/extism?tab=readme-ov-file#compile-webassembly-to-run-in-extism-hosts) for information how to write a plugin, and have a look at the [sample plugin in Golang](https://github.com/LemmyNet/lemmy/tree/ef76b48505661cea92d15cf46c40c9dc3496b746/plugins). To test your plugin, place the compiled `.wasm` file in the `plugins` folder and start Lemmy.

Plugins are invoked on specific hooks. API hooks are defined based on the HTTP method and path, with the form `api_before_{method}_{path}`. You can find the name of specific plugin hooks by running Lemmy, invoking the desired API call and grepping the logs for `Calling plugin hook`. Then declare hook in your plugin code.

### API `before` hooks

These are called before a given API endpoint is invoked, with the raw JSON data submitted by the user, and need to return data in the same format. At this point the data can be invalid, so the actions may still be rejected. These hooks are mainly useful to modify data before it is stored in the database. For example writing a slur filter, automatically marking posts as nsfw or permanently rewriting URLs.

Examples:

- `api_before_post` with [CreatePost](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/post.rs#L20)
- `api_post_user_register` with [Register](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/person.rs#L39)
- `api_post_community_delete` with [DeleteCommunity](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/community.rs#L174)

### API `after` hooks

Called after an endpoint was successfully invoked and gets passed the API return data. It also needs to return the same back, which allows temporarily modifying responses or adding extra data to responses. These hooks can also be used to trigger notifications or other external actions.

Examples:

- `api_after_get_post_list` with [GetPostsResponse](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/post.rs#L93)
- `api_after_post_comment_like` with [CommentResponse](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/comment.rs#L89)
- `api_after_post_community_ban_user` with [BanFromCommunityResponse](https://github.com/LemmyNet/lemmy/blob/main/crates/api_common/src/community.rs#L112)

### Federation hooks

The data structures for federation are completely different from those used in the API, which is why they have separate plugin hooks. Like with the API, there are `before` hooks which can be used to permanently change data before it is written to the database. There are also after hooks which can be used for notifications etc.

At the moment only the following hook is available, more will be added later:

- `federation_before_receive_post` with [PostInsertForm](https://github.com/LemmyNet/lemmy/blob/main/crates/db_schema/src/source/post.rs#L67)
- `federation_after_receive_post` with [Post](https://github.com/LemmyNet/lemmy/blob/main/crates/db_schema/src/source/post.rs#L18)
