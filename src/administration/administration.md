# Administration info

Information for Lemmy instance admins, and those who want to run a server.

If you have any problems in the installation, you can ask for help in [!lemmy_support](https://lemmy.ml/c/lemmy_support) or [Matrix](https://matrix.to/#/#lemmy-support-general:discuss.online). Do not open Github issues for support.

## Install

### Official/Supported methods

Lemmy has two primary installation methods:

- [Manually with Docker](install_docker.md)
- [Automated with Ansible](install_ansible.md)

We recommend using Ansible, because it simplifies the installation and also makes updating easier.

Lemmy uses roughly 150 MB of RAM in the default Docker installation. CPU usage is negligible.

### Managed Hostings

- [Elestio](https://elest.io/open-source/lemmy)
- [K&T Host](https://www.knthost.com/lemmy)

### Other installation methods

> ⚠️ **Under your own risk.**

In some cases, it might be necessary to use different installation methods.

- [From Scratch](from_scratch.md)
- [YunoHost](https://install-app.yunohost.org/?app=lemmy) ([source code](https://github.com/YunoHost-Apps/lemmy_ynh))
- [On Amazon Web Services (AWS)](on_aws.md)
- [Nomad](https://www.nomadproject.io/) ([see this external repo for examples](https://github.com/Cottand/lemmy-on-nomad-examples))

### You could use any other reverse proxy

An Example [Caddy configuration](caddy.md).

## Lemmy components

### Lemmy-ui

Lemmy-ui is the main frontend for Lemmy. It consists of an expressjs based server-side process (necessary for SSR) and client code which run in the browser. It does not use a lot of resources and will happily run on quite low powered servers.

### Lemmy_server

Lemmy_server is the backend process, which handles:

- Incoming HTTP requests (both from Lemmy clients and incoming federation from other servers)
- Outgoing federation
- Scheduled tasks (most notably, constant hot rank calculations, which keep the front page fresh)

### Pict-rs

Pict-rs is a service which does image processing. It handles user-uploaded images as well as downloading thumbnails for external images.
