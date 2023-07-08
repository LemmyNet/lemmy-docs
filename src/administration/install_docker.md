# Docker Installation

Lemmy may be run within a Docker container. This is the easiest way to get started with Lemmy, however it still requires some technical knowledge.

## Prerequisites

A working knowledge of Docker is required to deploy Lemmy using this method. For the unfamiliar with Docker, please refer to the [official documentation](https://docs.docker.com/).

Ensure that a modern version of `docker` and `docker-compose` (>=`1.24.0`) are available in the environment. On Ubuntu, this is accomplished by executing `apt install docker-compose docker.io`; other distributions may have different package names.

### Reverse Proxy / Webserver

Lemmy requires the use of a Reverse Proxy to properly direct requests to either the Lemmy server or Lemmy UI. This is because Lemmy is composed of two separate components, the server and the UI, which are served from different containers (or services in Docker Swarm mode) on different ports. The reverse proxy is responsible for directing requests to the correct component based on the URL while providing SSL termination for the proxied service.

Some common choices include webservers such as [NGINX](https://www.nginx.com/), or a dedicated proxy such as [Traefik](https://traefik.io/). Configuration is _not_ limited to these two options, however they are the most common and example configurations are provided for them.

The Reverse proxy may be part of the same Docker Compose file as the Lemmy server and UI, or it may be a separate service. In a production configuration it is recommended that the reverse proxy be a separate service, as this allows for greater flexibility in scaling and configuration.

## Deployment

First, create a location to store the Lemmy docker environment then set any required permissions. The location used in this example will be `/srv/lemmy/example.com`

> **Note**: this step is not required if using the Traefik template as the required directories are stored in the git repository.

```bash
# Create a folder for the lemmy files. the location doesnt matter, you can put this anywhere you want
mkdir -p /srv/lemmy/example.com/{volumes,config}
mkdir -p /srv/lemmy/example.com/volumes/{pictrs,postgres}
chown 991:991 /srv/lemmy/example.com/volumes/pictrs
cd /srv/lemmy/example.com
```

### Download an appropriate Docker template

There are many ways that the Lemmy docker environment can be configured. The following sections describe some of the more common configurations.

#### NGINX

Appropriate templates for nginx are available in the [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible) repository. While these templates are designed to be deployed via Ansible automation, they can be trivially hand-edited.


```bash
curl -O https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/docker-compose.yml
pushd config
curl -O https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/examples/config.hjson
curl -O https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx_internal.conf
popd
```

These templates contain `{{ }}` braces for variables, such as passwords and the domain name; edit them before starting up Lemmy for the first time.

Ensure that the configuration files mounted as volumes under each `service` are correct for the deployment environment - this example differs from the vanilla Ansible deployment by placing configuration files in the `config` directory.

#### Traefik

The Traefik template is configured to use an external Traefik (>=3.0) instance. If there is not already a Traefik instance in the deployment environment [this](https://gitlab.com/Matt.Jolly/traefik-grafana-prometheus-docker) may be used as a starting point:

```bash
git clone https://gitlab.com/Matt.Jolly/traefik-grafana-prometheus-docker /srv/traefik
```

Consult the [Traefik documentation](https://doc.traefik.io/traefik/) (and the README included in the above git repo) for configuration advice.

A repository containing a Lemmy configuration for Traefik may be checked out:

```bash
git clone https://gitlab.com/Matt.Jolly/lemmy-traefik-docker /srv/lemmy/example.com
```

Set appropriate permissions for the pictrs volume:

```bash
chown 991:991 /srv/lemmy/example.com/volumes/pictrs
```

> **Note**: The Traefik and Lemmy compose files are configured for deployment in via Docker Stack/Swarm. If deploying via `docker-compose` the `deploy` section of the `docker-compose.yml` file should be removed and the `labels` key included directly under each service.

### Service Configuration

Both the NGINX and Traefik templates should be configured for the environment that they are to be deployed into.

Unless a custom image has been created, the latest image tags can be identified here: [dessalines/lemmy](https://hub.docker.com/r/dessalines/lemmy) and [dessalines/lemmy-ui](https://hub.docker.com/r/dessalines/lemmy-ui)

Customise both the `docker-compose.yml` and the Lemmy [configuration file](configuration.md) `lemmy.hjson` to suit the environment in question.

For federation to work, it is important that the reverse proxy does not change any headers that form part of the `signature`. This includes the `Host` header; refer to the documentation for the reverse proxy if it is not NGINX or Traefik to ensure that it is configured to pass the `Host` header unmodified.

#### Database tweaks (optional);

It is possible to optimise the postgres configuration for the expected workload and hardware configuration; the following website can be used to generate a customised `postgresql.conf` file: <https://pgtune.leopard.in.ua/>

An example configuration file is also available from the `lemmy-ansible` repository:

```bash
pushd config
curl -O https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/examples/customPostgresql.conf
popd
```

### TLS certificates

TLS is required for federation; Although there are many methods of generating TLS certificates that will be trusted by browsers and other ActivityPub endpoints [Let's Encrypt](https://letsencrypt.org/) is the most straightforward for users that do not already have an alternative in mind:

- For [NGINX on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-22-04).
- Traefik can [automate the entire process](https://doc.traefik.io/traefik/https/acme/).

## Deployment

Run the following commands to deploy the Lemmy stack:

`docker-compose`:

```bash
docker-compose up -d
```

`docker stack`:

```bash
docker stack deploy -c docker-compose.yml lemmy
```

## Updating

To update Lemmy (and any other containers in the stack), change the version in `docker-compose.yml` then redeploy it using the appropriate mechanism.

Tools such as [Watchtower](https://github.com/containrrr/watchtower) for `docker-compose` or [Shepherd](https://github.com/containrrr/shepherd) for `docker stack` deployments can be used to automate this process by automatically deploying new versions of containers when the tag (e.g. `latest` or `18.3`) is updated to point at a different container. While it may be advantageous to enable hands-free upgrades for Lemmy and its associated services any administrator should be aware of the risks of doing so (and ensure that regular, automated, backups are in place).
