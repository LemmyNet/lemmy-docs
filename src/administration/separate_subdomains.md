# Lemmy on Separate Subdomains

This guide details hosting the Lemmy backend and frontend on different domains. This is useful, for example, if you want users to have a webfinger (user handle) without a subdomain, but want to host services on the same domain.

As a general overview, this works by handling federation requests on the short domain and forwarding them to the Lemmy backend. API and frontend requests however are handled on the long domain.

## Placeholders

- `short.domain` represents the shortened domain you would like to use for user handles.
- `sub.longerdomain.com` represents the domain where the UI will be served.
- The `proxy` network is the configured Traefik network, and is only referenced in the Traefik configuration. Please see the [Traefik documentation](https://doc.traefik.io/traefik/providers/docker/#network).
- The `backend` network is the network used to communicate between Docker containers. This is only referenced in the Traefik configuration. This can be renamed to your liking. In the configuration, this is referenced as an `external` Docker network, but can also be an `internal` Docker network ([documentation here](https://docs.docker.com/compose/how-tos/networking/#use-a-pre-existing-network)).

## Limitations

- If there is another service using the `/api`, `/pictrs`, `/feeds`, `/nodeinfo`, `/.well-known`, `/inbox`, `/version`, and `/sitemap.xml` paths on `short.domain`, it will conflict with the Lemmy server. Similarly, if there is a service on `short.domain` listening for the `Accept: application/activity+json` HTTP header, it will also conflict with the Lemmy server.

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
