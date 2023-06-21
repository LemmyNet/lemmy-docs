# Docker Installation

Make sure you have both docker and docker-compose(>=`1.24.0`) installed. On Ubuntu, just run `apt install docker-compose docker.io`. Next,

```bash
# create a folder for the lemmy files. the location doesnt matter, you can put this anywhere you want
mkdir /lemmy
cd /lemmy

# download default config files
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/lemmy.hjson

# Set correct permissions for pictrs folder
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

If you'd like a different database password, you should also change it in the `docker-compose.yml` **before** your first run.

You'll also need to copy the following to `nginx.conf` in the root of your `lemmy` folder. This will ensure the proxy setup by `docker-compose` will function properly:

```
worker_processes 1;
events {
    worker_connections 1024;
}
http {
    upstream lemmy {
        # this needs to map to the lemmy (server) docker service hostname
        server "lemmy:8536";
    }
    upstream lemmy-ui {
        # this needs to map to the lemmy-ui docker service hostname
        server "lemmy-ui:1234";
    }

    server {
        # this is the port inside docker, not the public one yet
        listen 80;
        # change if needed, this is facing the public web
        server_name localhost;
        server_tokens off;

        gzip on;
        gzip_types text/css application/javascript image/svg+xml;
        gzip_vary on;

        # Upload limit, relevant for pictrs
        client_max_body_size 20M;

        add_header X-Frame-Options SAMEORIGIN;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";

        # frontend general requests
        location / {
            # distinguish between ui requests and backend
            # don't change lemmy-ui or lemmy here, they refer to the upstream definitions on top
            set $proxpass "http://lemmy-ui";

            if ($http_accept ~ "^application/.*$") {
              set $proxpass "http://lemmy";
            }
            if ($request_method = POST) {
              set $proxpass "http://lemmy";
            }
            proxy_pass $proxpass;

            rewrite ^(.+)/+$ $1 permanent;
            # Send actual client IP upstream
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # backend
        location ~ ^/(api|pictrs|feeds|nodeinfo|.well-known) {
            proxy_pass "http://lemmy";
            # proxy common stuff
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            # Send actual client IP upstream
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

After this, have a look at the [config file](configuration.md) named `lemmy.hjson`, and adjust it, in particular the hostname, and possibly the db password. Then run:

`docker-compose up -d`

You can access the lemmy-ui at `http://localhost:80`

To make Lemmy available outside the server, you need to set up a reverse proxy, like Nginx. You can use the following simple proxy:

Note: If you are planning on running your reverse proxy on port 80, you'll need to update the docker-compose.yml file you just downloaded to change the internal proxy's listening port. If you are setting up Let's Encrypt on the same machine, you'll need to do this.

```
server {
    listen 80;
    server_name my_domain.tld;

    location / {
        proxy_pass http://localhost:LEMMY_PORT;
        proxy_set_header Host $host;
        include proxy_params;
    }
}
```

### Let's Encrypt

You should also setup TLS, for example with [Let's Encrypt](https://letsencrypt.org/). [Here's a guide for setting up letsencrypt on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04).

For federation to work, it is important that you do not change any headers that form part of the signature. This includes the `Host` header - you may need to refer to the documentation for your proxy server to pass through the `Host` header unmodified.

## Updating

To update to the newest version, you can manually change the version in `docker-compose.yml`. Alternatively, fetch the latest version from our git repo:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/docker-compose.yml
docker-compose up -d
```
