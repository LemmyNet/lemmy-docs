# Установка Ansible

Это то же самое, что и [установка Docker](install_docker.md), за исключением того, что Ansible обрабатывает всё это автоматически. Он также выполняет некоторые дополнительные действия, такие как настройка TLS и электронной почты для вашего экземпляра Lemmy.

Прежде всего вам нужны [установка Ansible на ваш локальный компьютер](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). Вам также необходимо будет установить [Docker SDK для Python](https://pypi.org/project/docker/) используя `pip install docker` ([больше информации в документации Ansible](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#id4)).

Затем запустите следующую команду на вашем локальном компьютере:

```bash
git clone https://github.com/LemmyNet/lemmy.git
cd lemmy/ansible/
cp inventory.example inventory
nano inventory # enter your server, domain, contact email
# If the command below fails, you may need to comment out this line
# In the ansible.cfg file:
# interpreter_python=/usr/bin/python3
ansible-playbook lemmy.yml --become
```

Для обновления до новой версии, просто запустите следующее в локальном репозитарии Lemmy:

```bash
git pull origin main
cd ansible
ansible-playbook lemmy.yml --become
```
