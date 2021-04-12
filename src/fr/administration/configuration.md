# Configuration

La configuration est basée sur le fichier [config.hjson](https://github.com/lemmynet/lemmy/blob/main/config/config.hjson). Ce fichier contient également la documentation de toutes les options disponibles. Les instructions d'installation vous indiquent comment remplacer les valeurs par défaut.

Le fichier `config.hjson` est situé à `config/config.hjson`. Pour changer l'emplacement par défaut, vous pouvez définir la variable d'environnement `LEMMY_CONFIG_LOCATION`.

Une variable d'environnement supplémentaire `LEMMY_DATABASE_URL` est disponible, qui peut être utilisée avec une chaîne de connexion PostgreSQL comme `postgres://lemmy:password@lemmy_db:5432/lemmy`, en passant tous les détails de connexion en une fois.

Si le conteneur Docker n'est pas utilisé, créez manuellement la base de données spécifiée ci-dessus en exécutant les commandes suivantes :

```bash
cd server
./db-init.sh
```
