# Guide de sauvegarde et de restauration

## Docker et Ansible

Lorsque vous utilisez docker ou ansible, il devrait y avoir un dossier `volumes`, qui contient à la fois la base de données, et toutes les images. Copiez ce dossier dans la nouvelle instance pour restaurer vos données.

### Sauvegarde incrémentale de la base de données

Pour sauvegarder de manière incrémentielle la base de données dans un fichier `.sql`, vous pouvez exécuter : 

```bash
docker-compose exec postgres pg_dumpall -c -U lemmy >  lemmy_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
```
### Un exemple de script de sauvegarde

```bash
#!/bin/sh
# DB Backup
ssh MY_USER@MY_IP "docker-compose exec postgres pg_dumpall -c -U lemmy" >  ~/BACKUP_LOCATION/INSTANCE_NAME_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql

# Dossier Volumes Sauvegarde
rsync -avP -zz --rsync-path="sudo rsync" MY_USER@MY_IP:/LEMMY_LOCATION/volumes ~/BACKUP_LOCATION/FOLDERNAME
```

### Restauration de la BD

Si vous avez besoin de restaurer à partir d'un fichier `pg_dumpall`, vous devez d'abord vider votre base de données existante.

```bash
# Abandon de la BD existante
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Restauration à partir de la sauvegarde .sql
cat db_dump.sql  |  docker exec -i FOLDERNAME_postgres_1 psql -U lemmy # restores the db

# Cela peut également être nécessaire lors de l'importation d'une base de données avec un mot de passe différent.
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "alter user lemmy with password 'bleh'"
```

### Changer votre nom de domaine

Si vous ne vous êtes pas encore fédéré, vous pouvez changer votre nom de domaine dans la base de données. **Attention : ne faites pas cela après vous être fédéré, ou cela brisera la fédération.**

Entrez dans `psql` pour votre docker : 

`docker-compose exec postgres psql -U lemmy`

```
-- Post
update post set ap_id = replace (ap_id, 'ancien_domaine', 'nouveau_domaine');
update post set url = replace (url, 'ancien_domaine', 'nouveau_domaine');
update post set body = replace (body, 'ancien_domaine', 'nouveau_domaine');
update post set thumbnail_url = replace (thumbnail_url, 'ancien_domaine', 'nouveau_domaine');

-- Comments
update comment set ap_id = replace (ap_id, 'ancien_domaine', 'nouveau_domaine');
update comment set content = replace (content, 'ancien_domaine', 'nouveau_domaine');

-- User
update user_ set actor_id = replace (actor_id, 'ancien_domaine', 'nouveau_domaine');
update user_ set inbox_url = replace (inbox_url, 'ancien_domaine', 'nouveau_domaine');
update user_ set shared_inbox_url = replace (shared_inbox_url, 'ancien_domaine', 'nouveau_domaine');
update user_ set avatar = replace (avatar, 'ancien_domaine', 'nouveau_domaine');

-- Community
update community set actor_id = replace (actor_id, 'ancien_domaine', 'nouveau_domaine');
update community set followers_url = replace (followers_url, 'ancien_domaine', 'nouveau_domaine');
update community set inbox_url = replace (inbox_url, 'ancien_domaine', 'nouveau_domaine');
update community set shared_inbox_url = replace (shared_inbox_url, 'ancien_domaine', 'nouveau_domaine');

```

## Plus de ressources

- https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database


