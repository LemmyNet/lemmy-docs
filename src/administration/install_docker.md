# Docker Installation

Make sure you have both docker and docker-compose(>=`1.24.0`) installed. On Ubuntu, just run `apt install docker-compose docker.io`. Next,

```bash
# Create a folder for the lemmy files. the location doesnt matter, you can put this anywhere you want
mkdir lemmy
cd /lemmy
```

## Download default config files

These files contain `{{ }}` braces for variables, such as passwords and your domain.

Edit them before starting up lemmy for the first time.

The images will likely be: [dessalines/lemmy:VERSION](https://hub.docker.com/r/dessalines/lemmy) and [dessalines/lemmy-ui:VERSION](https://hub.docker.com/r/dessalines/lemmy-ui)

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/examples/config.hjson -O lemmy.hjson
wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx_internal.conf
```

If you'd like further customization, have a look at the [config file](configuration.md) named `lemmy.hjson`, and adjust it accordingly.

## Database tweaks

To optimize your database, add this file.

You can input your system specs, using this tool: https://pgtune.leopard.in.ua/

`wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/examples/customPostgresql.conf`

## Folder permissions

Set the correct permissions for pictrs folder:

```bash
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

Finally, run:

`docker-compose up -d`

lemmy-ui is accessible on the server at `http://localhost:{{ lemmy_port }}`

## Reverse Proxy / Webserver

Here's an optional nginx reverse proxy template, which you can place in `/etc/nginx/sites-enabled`

Alternatively, you can use any other web server such as caddy as a simple reverse proxy.

Be sure to edit the `{{ }}` to match your domain and port.

If you're using this, you will need to set up Let's Encrypt. See those instructions below.

`wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx.conf`

If you've set up Let's Encrypt and your reverse proxy, you can go to `https://{{ domain }}`

## Let's Encrypt

You should also setup TLS, for example with [Let's Encrypt](https://letsencrypt.org/). [Here's a guide for setting up letsencrypt on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04).

For federation to work, it is important that you do not change any headers that form part of the signature. This includes the `Host` header - you may need to refer to the documentation for your proxy server to pass through the `Host` header unmodified.

# Updating

To update to the newest version, you can manually change the version in `docker-compose.yml`. Alternatively, fetch the latest version from our [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repo:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/docker-compose.yml
# Then replace the {{ }} vars again
docker-compose up -d
```
