# Administration info

Information for Lemmy instance admins, and those who want to run a server.

## Install
### Official/Supported methods

Lemmy has two primary installation methods: 
- [Manually with Docker](install_docker.md)
- [Automated with Ansible](install_ansible.md)

We recommend using Ansible, because it simplifies the installation and also makes updating easier.

Lemmy uses roughly 150 MB of RAM in the default Docker installation. CPU usage is negligible. 

### Other installation methods
> ⚠️ **Under your own risk.**

In some cases, it might be necessary to use different installation methods. But we don't recommend this, and can't provide support for them.
- [From Scratch](from_scratch.md)
- [Yunohost](https://install-app.yunohost.org/?app=lemmy) ([source code](https://github.com/YunoHost-Apps/lemmy_ynh))
- [On Amazon Web Services (AWS)](on_aws.md)
