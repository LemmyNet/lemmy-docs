# Federation Administration

Note: ActivityPub federation is still under development. We recommend that you only enable it on test instances for now.

To enable federation, change the setting `federation.enabled` to `true` in `lemmy.hjson`, and restart Lemmy.

Federation does not start automatically, but needs to be triggered manually through the search. To do this you have to enter a reference to a remote object, such as:

- `!main@lemmy.ml` (Community)
- `@nutomic@lemmy.ml` (User)
- `https://lemmy.ml/c/programming` (Community)
- `https://lemmy.ml/u/nutomic` (User)
- `https://lemmy.ml/post/123` (Post)
- `https://lemmy.ml/comment/321` (Comment)

For an overview of how federation in Lemmy works on a technical level, check out our [Federation Overview](contributing_federation_overview.md).

## Federation Modes

Through the combination of federation config options, there are a couple different federation modes, differing in their restrictiveness. For now we don't recommend to use open federation, because moderation tools are lacking and there might be security problems in the federation code. Open federation should be fine for test instances and smaller instances, but bigger instances should prefer to use a more closed federation.

It is important to note that these settings only affect sending and receiving of data between instances. If allow federation with a certain instance, and then remove it from the allowlist, this will not affect previously federated data. These communities, users, posts and comments will still be shown. They will just not be updated anymore. And even if an instance is blocked, it can still fetch and display public data from your instance.

### Using allowlist, strict_allowlist = true

The most strict mode. Lemmy will only federate with instances from the allowlist, and block everything else. This includes all posts, comments, votes and private messages, you will only see them if the author is on an allowed instance. This means that remote communities or threads can be incomplete, as your instance will block any posts or comments whose author is not on an allowed instance.

The blocklist is ignored in this mode.

### Using allowlist, strict_allowlist = false

This mode is a bit more open than the one above. For local communities, the behaviour is identical, only users from allowed instances can post, comment or vote. The difference is with remote communities. The allowlist doesn't apply to them, so you will see all posts, comments and votes in remote communities (unless the author's instance is blocked). Private messages can be sent by any remote user that isn't blocked.

If a blocklist is set, all communication with the blocked instances will be prevented, no matter in which context.

### Using only blocklist

If no allowlist is specified, Lemmy will federate with any instance. This is the most open mode, and potentially the most risky, as someone could create a malicious instance, and immediately send spam or other problematic content to your instance. You can use the blocklist to prevent federation with such instances one by one.

`strict_allowlist` is ignored in this case.
