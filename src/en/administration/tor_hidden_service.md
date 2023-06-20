# Tor Hidden Services

This guide assumes Lemmy has been installed using the official [Docker Compose](install_docker.md) method.

Note that federation is not currently supported over the Tor network. An existing Lemmy instance is required. This procedure will proxy Lemmy though Tor, but federation tasks are still handled by HTTPS on the open internet.

[Tor](https://torproject.org) ("The Onion Router") is software designed to circumvent censorship and prevent bad actors from monitoring your activity on the internet by encrypting and distributing network traffic through a decentralized pool of relay servers run by volunteers all over the world.

A Tor hidden service is only accessible through the Tor network using the `.onion` top-level domain with the official [Tor Browser](https://www.torproject.org/download/), or any client capable of communicating over a SOCKS5 proxy. Hosting a service on the Tor network is a good way to promote digital privacy and internet freedom.

# Installing Tor

The official [documentation](https://support.torproject.org/apt/tor-deb-repo/) suggests Ubuntu and Debian users install Tor from the `deb.torproject.org` repository because it always provides the latest stable release of the software.

**Administrative Access is Required**

Commands below are expected to be executed as the `root` user. To become root use `sudo -i` or `su -`.

With `sudo`:

```
sudo -i
Password: [authenticate with current user password]
```

With `su`:

```
su -
Password: [authenticate with root's password]
```

Note: To return to your account run: `exit`.

**Verify your architecture is supported**

The package repository only supports `amd64`, `arm64`, and `i386` architectures.

```
dpkg --print-architecture
```

If your architecture is not supported you may want to consider installing Tor [from source](https://community.torproject.org/onion-services/setup/install/#installing-tor-from-source).

**Install prerequisite packages**

```
apt install -y apt-transport-https ca-certificates gpg lsb-release wget
```

**Enable the deb.torproject.org repository**

Configure `apt` to pull packages from `deb.torproject.org`.

```
bash -c 'dist=$(lsb_release -s -c); /bin/echo -e \
"deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] \
https://deb.torproject.org/torproject.org $dist main\n\
deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] \
https://deb.torproject.org/torproject.org $dist main" \
> /etc/apt/sources.list.d/tor.list'
```

**Import deb.torproject.org's GPG signing key**

```
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
    | gpg --dearmor \
    | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
```

The signing key ensures the package retrieved from the server was created by `deb.torproject.org`.

**Install tor**

```
apt update && apt install -y tor
```

## Creating a Tor hidden service

Create a new hidden service directory:

```
mkdir /var/lib/tor/hidden_lemmy_service
```

Append the following to `/etc/tor/torrc` to tie the hidden service directory to the `tor` daemon:

```
HiddenServiceDir /var/lib/tor/hidden_lemmy_service/
HiddenServicePort 10080 127.0.0.1:80
```

`HiddenServiceDir [path]` is where `tor` will store data related to the hidden service, and `HiddenServicePort [hidden_service_port] [host_ip:port]` binds a port on the host to a hidden service port on the Tor network.

## Enable and start the Tor daemon

```
systemctl enable --now tor
```

At startup `tor` daemon will automatically populate `/var/lib/tor/hidden_lemmy_service/` with encryption keys, certificates, and assign a hostname for the new service.

## Determine your hidden service's hostname

```
cat /var/lib/tor/hidden_lemmy_service/hostname
```

The `.onion` address contained in this file will be referred to as `HIDDEN_SERVICE_ADDR` from here on.

# Configure your existing Lemmy instance

## Docker compose

Forward port `80` from the `proxy` container to the hidden service port `127.0.0.1:10080`. This exposes `10080/tcp` to the local host, and will not be directly accessible from the internet. For context `"80:80"` binds port `80/tcp` (HTTP) to `0.0.0.0:80` on the host. Unless a firewall is configured to block incoming traffic to `80` this will be exposed to other hosts on the local area network (LAN) and/or the open internet.

**docker-compose.yml**

```
services:
  # ...
  proxy:
    # ...
    ports:
      - "80:80"
      - "443:443"
      - "127.0.0.1:10080:80"
```

## Configure NGINX

Append a new `server {...}` block to handle tor traffic, and add the `Onion-Location` header to the SSL encrypted server exposed to the internet. This header informs Tor Browser users that an equivalent `.onion` site exists on the Tor network by displaying an icon next to the address bar.

**nginx.conf**

```
worker_processes 1;
events {
    worker_connections 1024;
}

http {
    # Original configuration listening on port 80
    server {
        listen 80;
        # ...
    }

    # Original configuration listening on port 443
    server {
        listen 443;
        # ...
        location / {
            # Handle Tor Browser's ".onion" link detection
            add_header Onion-Location "http://HIDDEN_SERVICE_ADDR$request_uri" always;
            # ...
        }
    }

    # Establish a rate limit for the hidden service address
    limit_req_zone $binary_remote_addr zone=HIDDEN_SERVICE_ADDR_ratelimit:10m rate=1r/s;

    # Add tor-specific upstream aliases as a visual aid to
    # avoid editing the incorrect server block in the future
    upstream lemmy-tor {
        server "lemmy:8536";
    }
    upstream lemmy-ui-tor {
        server "lemmy-ui:1234";
    }

    # Add a copy of your current internet-facing configuration with
    # "listen" and "server_listen" modified to send all traffic
    # over the Tor network, incorporating the visual upstream aliases
    # above.
    server {
        # Tell nginx to listen on the hidden service port
        listen 10080;

        # Set server_name to the contents of the file:
        # /var/lib/tor/hidden_lemmy_service/hostname
        server_name HIDDEN_SERVICE_ADDR;

        # Hide nginx version
        server_tokens off;

        # Enable compression for JS/CSS/HTML bundle, for improved client load times.
        # It might be nice to compress JSON, but leaving that out to protect against potential
        # compression+encryption information leak attacks like BREACH.
        gzip on;
        gzip_types text/css application/javascript image/svg+xml;
        gzip_vary on;

        # Only connect to this site via HTTPS for the two years
        add_header Strict-Transport-Security "max-age=63072000";

        # Various content security headers
        add_header Referrer-Policy "same-origin";
        add_header X-Content-Type-Options "nosniff";
        add_header X-Frame-Options "DENY";
        add_header X-XSS-Protection "1; mode=block";

        # Upload limit for pictrs
        client_max_body_size 20M;

        # frontend
        location / {
            # distinguish between ui requests and backend
            # don't change lemmy-ui or lemmy here, they refer to the upstream definitions on top
            set $proxpass "http://lemmy-ui-tor";

            if ($http_accept = "application/activity+json") {
                set $proxpass "http://lemmy-tor";
            }
            if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
                set $proxpass "http://lemmy-tor";
            }
            if ($request_method = POST) {
                set $proxpass "http://lemmy-tor";
            }
            proxy_pass $proxpass;

            rewrite ^(.+)/+$ $1 permanent;

            # Send actual client IP upstream
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # backend
        location ~ ^/(api|feeds|nodeinfo|.well-known) {
            proxy_pass "http://lemmy-tor";
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Rate limit
            limit_req zone=HIDDEN_SERVICE_ADDR_ratelimit burst=30 nodelay;

            # Add IP forwarding headers
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # pictrs only - for adding browser cache control.
        location ~ ^/(pictrs) {
            # allow browser cache, images never update, we can apply long term cache
            expires 120d;
            add_header Pragma "public";
            add_header Cache-Control "public";

            proxy_pass "http://lemmy-tor";
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Rate limit
            limit_req zone=HIDDEN_SERVICE_ADDR_ratelimit burst=30 nodelay;

            # Add IP forwarding headers
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Redirect pictshare images to pictrs
        location ~ /pictshare/(.*)$ {
            return 301 /pictrs/image/$1;
        }
    }

    # ...
}
```

# Apply the configuration(s)

Restart all services associated with your Lemmy instance:

```
docker compose down
docker compose up -d
```

# Test connectivity over Tor

Using `torsocks`, verify your hidden service is available on the Tor network.

```
torsocks curl -vI http://HIDDEN_SERVICE_ADDR
*   Trying 127.*.*.*:80...
* Connected to HIDDEN_SERVICE_ADDR (127.*.*.*) port 80 (#0)
> HEAD / HTTP/1.1
> Host: HIDDEN_SERVICE_ADDR
> User-Agent: curl/7.76.1
> Accept: */*
>
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Server: nginx
Server: nginx
< Date: Wed, 07 Jun 2023 17:06:00 GMT
Date: Wed, 07 Jun 2023 17:06:00 GMT
< Content-Type: text/html; charset=utf-8
Content-Type: text/html; charset=utf-8
< Content-Length: 98487
Content-Length: 98487
< Connection: keep-alive
Connection: keep-alive
< Vary: Accept-Encoding
Vary: Accept-Encoding
< X-Powered-By: Express
X-Powered-By: Express
< Content-Security-Policy: default-src 'self'; manifest-src *; connect-src *; img-src * data:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; form-action 'self'; base-uri 'self'; frame-src *
Content-Security-Policy: default-src 'self'; manifest-src *; connect-src *; img-src * data:; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; form-action 'self'; base-uri 'self'; frame-src *
< ETag: W/"180b7-EC9iFYAIlbnN8zHCayBwL3wAm64"
ETag: W/"180b7-EC9iFYAIlbnN8zHCayBwL3wAm64"
< Strict-Transport-Security: max-age=63072000
Strict-Transport-Security: max-age=63072000
< Referrer-Policy: same-origin
Referrer-Policy: same-origin
< X-Content-Type-Options: nosniff
X-Content-Type-Options: nosniff
< X-Frame-Options: DENY
X-Frame-Options: DENY
< X-XSS-Protection: 1; mode=block
X-XSS-Protection: 1; mode=block

<
* Connection #0 to host HIDDEN_SERVICE_ADDR left intact
```

## Logging behavior

Hidden service traffic will appear to originate from the `lemmyexternalproxy` docker network instead of an internet IP. Docker's default network address pool is `172.17.0.0/16`.

```
docker compose logs -f proxy
lemmy-proxy-1  | 172.*.0.1 - -  # ...
lemmy-proxy-1  | 172.*.0.1 - -  # ...
lemmy-proxy-1  | 172.*.0.1 - -  # ...
```
