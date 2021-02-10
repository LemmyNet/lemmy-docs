# Troubleshooting

Different problems that can occur on a new instance, and how to solve them.

Many Lemmy features depend on a correct reverse proxy configuration. Make sure yours is equivalent to our [nginx config](https://github.com/LemmyNet/lemmy/blob/main/ansible/templates/nginx.conf).

## General

### Various problems

Use `docker-compose logs -f lemmy` in your installation folder on the server to view the logs. You can also do `docker-compose logs -f lemmy lemmy-ui pictrs` to get logs from different services.

If that doesn't give enough info, try changing the line `RUST_LOG=error` in `docker-compose.yml` to `RUST_LOG=info` or `RUST_LOG=verbose`, then do `docker-compose restart lemmy`.

### Creating admin user doesn't work

Make sure that websocket is working correctly, by checking the browser console for errors. In nginx, the following headers are important for this:

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Rate limit error when many users access the site

Check that the headers `X-Real-IP` and `X-Forwarded-For` are sent to Lemmy by the reverse proxy. Otherwise, it will count all actions towards the rate limit of the reverse proxy's IP. In nginx it should look like this:

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Federation

### Other instances can't fetch local objects (community, post, etc)

Your reverse proxy (eg nginx) needs to forward requests with header `Accept: application/activity+json` to the backend. This is handled by the following lines:
```
set $proxpass "http://0.0.0.0:{{ lemmy_ui_port }}";
if ($http_accept = "application/activity+json") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
proxy_pass $proxpass;
```

You can test that it works correctly by running the following commands, all of them should return valid JSON:
```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # the id of a local post
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # the id of a local comment
```
### Fetching remote objects works, but posting/commenting in remote communities fails

Check that [federation is allowed on both instances](../federation/administration.md#instance-allowlist-and-blocklist).

Also ensure that the time is accurately set on your server. Activities are signed with a timestamp, and will be discarded if it is off by more than 10 seconds.