# Lemmy on Separate Subdomains

This guide details hosting the Lemmy backend and frontend on different domains. This is useful, for example, if you want users to have a webfinger (user handle) without a subdomain, but want to host services on the same domain.

As a general overview, this works by handling federation requests on the short domain and forwarding them to the Lemmy backend. API and frontend requests however are handled on the long domain.

## Placeholders

- `short.domain` represents the shortened domain you would like to use for user handles.
- `sub.longerdomain.com` represents the domain where the UI will be served.
- The `proxy` network is the configured Traefik network, and is only referenced in the Traefik configuration. Please see the [Traefik documentation](https://doc.traefik.io/traefik/providers/docker/#network).
- The `backend` network is the network used to communicate between Docker containers. This is only referenced in the Traefik configuration. This can be renamed to your liking. In the configuration, this is referenced as an `external` Docker network, but can also be an `internal` Docker network ([documentation here](https://docs.docker.com/compose/how-tos/networking/#use-a-pre-existing-network)).

## Limitations

- As of the time of writing this (March 25th, 2025), the Lemmy UI seems to be hardcoded to the domain on which it is hosted. For example, even if you set the `LEMMY_UI_LEMMY_EXTERNAL_HOST` environment variable to be `short.domain`, the UI will still try accessing `sub.longerdomain.com` for API requests.

In theory, if this is changed in the future, this documentation will be updated to reflect the change. However, in practice that may not occur. If you are reading this page far into the future, it may be worthwhile to test this functionality again to see if it has been changed.

- If there is another service using the `/api`, `/pictrs`, `/feeds`, `/nodeinfo`, `/.well-known`, `/inbox`, `/version`, and `/sitemap.xml` paths on `short.domain`, it will conflict with the Lemmy server. Similarly, if there is a service on `short.domain` listening for the `Accept: application/activity+json` HTTP header, it will also conflict with the Lemmy server.
- If you still want to access the admin user interface, the paths `/login` and `/admin` will also need to be unused on `short.domain`. This is optional, however, and is not required if the `lemmy-ui` container is omitted.

## Traefik

This is the solution that is currently being tested (by this author). Federation is not a problem whatsoever, and everything is working correctly.

You can download the Docker Compose file by running:

```sh
wget https://raw.githubusercontent.com/LemmyNet/lemmy-docs/main/assets/separate_subdomains/traefik/compose.yml
```

Then continue the [Docker instructions here](https://join-lemmy.org/docs/administration/install_docker.html), excluding the NGINX steps.

## NGINX

This solution is derived from the Traefik configuration above. Please note, some configuration options may be unnecessary due to the fact that this was derived from a Traefik configuration. Feel free to open a [pull request](https://github.com/LemmyNet/lemmy-docs).

You can download the `nginx_internal.conf` file by running:

```sh
wget https://raw.githubusercontent.com/LemmyNet/lemmy-docs/main/assets/separate_subdomains/nginx/nginx_internal.conf
```

Ensure you edit `nginx_internal.conf` and replace `{{ nginx_internal_resolver }}` with `127.0.0.11` (use `10.89.0.1` for RedHat distributions).

Then continue installing with your preferred installation method. For example, [these are the Docker instructions](https://join-lemmy.org/docs/administration/install_docker.html). Ensure you use the `nginx_internal.conf` file provided on this page.
