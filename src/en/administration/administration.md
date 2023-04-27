# Administration info

Information for Lemmy instance admins, and those who want to run a server.

If you have any problems in the installation, you can ask for help in [!lemmy_support](https://lemmy.ml/c/lemmy_support). Do not use Github for support.

## Install

### Official/Supported methods

Lemmy has two primary installation methods:

- [Manually with Docker](install_docker.md)
- [Automated with Ansible](install_ansible.md)

We recommend using Ansible, because it simplifies the installation and also makes updating easier.

Lemmy uses roughly 150 MB of RAM in the default Docker installation. CPU usage is negligible.

### Other installation methods

> ⚠️ **Under your own risk.**

In some cases, it might be necessary to use different installation methods.

- [From Scratch](from_scratch.md)
- [Yunohost](https://install-app.yunohost.org/?app=lemmy) ([source code](https://github.com/YunoHost-Apps/lemmy_ynh))
- [On Amazon Web Services (AWS)](on_aws.md)

### You could use any other reverse proxy

An Example [Caddy configuration](caddy.md).
