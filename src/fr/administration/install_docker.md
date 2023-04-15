# Installation de Docker

Assurez-vous que vous avez à la fois docker et docker-compose(>=`1.24.0`) installés. Sur Ubuntu, exécutez simplement `apt install docker-compose docker.io`. Suivant,

```bash
# créez un dossier pour les fichiers lemmy. l'emplacement n'a pas d'importance, vous pouvez le mettre où vous voulez
mkdir /lemmy
cd /lemmy

# télécharger les fichiers de configuration par défaut
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/lemmy.hjson
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/iframely.config.local.js

# Définir les permissions correctes pour le dossier pictrs
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

Ouvrez votre `docker-compose.yml`, et assurez-vous que `LEMMY_EXTERNAL_HOST` pour `lemmy-ui` est réglé sur votre hôte correct.

```
- LEMMY_INTERNAL_HOST=lemmy:8536
- LEMMY_EXTERNAL_HOST=votre-domaine.com
- LEMMY_HTTPS=false
```

Si vous souhaitez un mot de passe différent pour la base de données, vous devez également le changer dans le fichier `docker-compose.yml` **avant** votre première exécution.

Après cela, jetez un oeil au [fichier de configuration](configuration.md) nommé `lemmy.hjson`, et ajustez-le, en particulier le nom d'hôte, et éventuellement le mot de passe de la base de données. Puis lancez :

`docker-compose up -d`

Vous pouvez accéder au lemmy-ui à l'adresse `http://localhost:1235`.

Pour rendre Lemmy disponible en dehors du serveur, vous devez configurer un proxy inverse, comme Nginx. Un exemple de configuration de Nginx (https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf), peut être configuré avec :

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf
# Remplacer les {{ variables}}
# Le lemmy_port par défaut est 8536
# Le lemmy_ui_port par défaut est 1235
sudo mv nginx.conf /etc/nginx/sites-enabled/lemmy.conf
```

Vous devrez également configurer TLS, par exemple avec [Let's Encrypt](https://letsencrypt.org/). Après cela, vous devez redémarrer Nginx pour recharger la configuration.

## Mise à jour

Pour mettre à jour la dernière version, vous pouvez changer manuellement la version dans `docker-compose.yml`. Alternativement, récupérez la dernière version depuis notre dépôt git :

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
docker-compose up -d
```
