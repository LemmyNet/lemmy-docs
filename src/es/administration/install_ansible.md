# Instalación con Ansible

Esto es lo mismo que la [instalación con Docker](install_docker.md), excepto que Ansible lo maneja todo automáticamente. También hace algunas cosas adicionales como la configuración de TLS y el correo electrónico para tu instancia Lemmy.

En primer lugar, necesitas [instalar Ansible en tu computador local](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). Tambien necesitas instalar el [SDK de Docker para Python](https://pypi.org/project/docker/) usando `pip install docker` ([más información en la documentación de Ansible](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#id4)).

A continuación, ejecuta los siguientes comandos en tu computador local:

```bash
git clone https://github.com/LemmyNet/lemmy.git
cd lemmy/ansible/
cp inventory.example inventory
nano inventory # ingresa tu servidor, dominio, correo electrónico de contacto
# Si el comando siguiente falla, es posible que tengas que comentar esta linea
# En el archivo ansible.cfg:
# interpreter_python=/usr/bin/python3
ansible-playbook lemmy.yml --become
```

Para actualizar a una nueva versión, simplemente ejecute lo siguiente en tu repo local de Lemmy:
```bash
git pull origin main
cd ansible
ansible-playbook lemmy.yml --become
```
