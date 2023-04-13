# Docker Installation

Make sure you have both docker and docker-compose(>=`1.24.0`) installed. On Ubuntu, just run `apt install docker-compose docker.io`. Next,

```bash
# create a folder for the lemmy files. the location doesnt matter, you can put this anywhere you want
mkdir /lemmy
cd /lemmy

# download default config files
wget https://raw.githubusercontent.com/LemmyNet/lemmy/release/v0.17/docker/prod/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/release/v0.17/docker/lemmy.hjson

# Set correct permissions for pictrs folder
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

If you'd like a different database password, you should also change it in the `docker-compose.yml` **before** your first run.

After this, have a look at the [config file](configuration.md) named `lemmy.hjson`, and adjust it, in particular the hostname, and possibly the db password. Then run:

`docker-compose up -d`

You can access the lemmy-ui at `http://localhost:80`

To make Lemmy available outside the server, you need to setup a reverse proxy, like Nginx. You can use the following simple proxy:

```
server_name your_domain;
location / {
    proxy_pass http://localhost:LEMMY_PORT;
    include proxy_params;
}
```

You can also setup TLS, for example with [Let's Encrypt](https://letsencrypt.org/). After this you need to restart Nginx to reload the config.

## Updating

To update to the newest version, you can manually change the version in `docker-compose.yml`. Alternatively, fetch the latest version from our git repo:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/docker-compose.yml
docker-compose up -d
```
