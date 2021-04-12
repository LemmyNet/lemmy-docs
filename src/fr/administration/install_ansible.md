# Installation Ansible

Ceci est la même chose que l'[installation Docker](install_docker.md), sauf qu'Ansible s'occupe de tout automatiquement. Il fait aussi des choses supplémentaires comme la configuration de TLS et de l'email pour votre instance Lemmy.

Tout d'abord, vous devez [installer Ansible sur votre ordinateur local](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html). Vous devez également installer le [Docker SDK pour Python](https://pypi.org/project/docker/) en utilisant `pip install docker` ([plus d'informations dans la documentation Ansible](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_compose_module.html#id4)).

Exécutez ensuite les commandes suivantes sur votre ordinateur local :

```bash
git clone https://github.com/LemmyNet/lemmy.git
cd lemmy/ansible/
cp inventory.example inventory
nano inventory # entrez votre serveur, domaine, email de contact
# Si la commande ci-dessous échoue, vous devrez peut-être décommenter cette ligne
# Dans le fichier ansible.cfg :
# interpreter_python=/usr/bin/python3
ansible-playbook lemmy.yml --become
```

Pour mettre à jour une nouvelle version, il suffit d'exécuter la commande suivante dans votre dépôt Lemmy local :
```bash
git pull origin main
cd ansible
ansible-playbook lemmy.yml --become
```
