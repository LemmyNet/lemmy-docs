# Guía de Copia de Seguridad Y Restauración

## Docker y Ansible

Cuando se utiliza docker o ansible, debe haber una carpeta llamada `volumes`, la cual contiene tanto la Base de Datos como todas las Imágenes. Copia esta carpeta a la nueva instancia para restaurar tus datos.

### Copia de seguridad incremental de la BD

Para hacer una copia de seguridad incremental de una base de datos en archivo `.sql` puedes ejecutar:

```bash
docker-compose exec postgres pg_dumpall -c -U lemmy >  lemmy_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
```

### Un ejemplo de script de copia de seguridad

```bash
#!/bin/sh
# DB Backup
ssh MY_USER@MY_IP "docker-compose exec postgres pg_dumpall -c -U lemmy" >  ~/BACKUP_LOCATION/INSTANCE_NAME_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql

# Volumes folder Backup
rsync -avP -zz --rsync-path="sudo rsync" MY_USER@MY_IP:/LEMMY_LOCATION/volumes ~/BACKUP_LOCATION/FOLDERNAME
```

### Restauración de la BD

Si necesitas restaurar la base de datos a partir de un archivo `pg_dumpall`, primero necesitas borrar la base de datos existente

```bash
# Drop the existing DB
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Restore from the .sql backup
cat db_dump.sql  |  docker exec -i FOLDERNAME_postgres_1 psql -U lemmy # restores the db

# This also might be necessary when doing a db import with a different password.
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "alter user lemmy with password 'bleh'"
```

### Cambiar el nombre de dominio

Si aún no te has federado, puedes cambiar tu nombre de dominio en la base de datos.
**Advertencia: no haga esto después de haber federado o romperás la federación.**

Entra al `psql` de tu docker:

`docker-compose exec postgres psql -U lemmy`

```
-- Post
update post set ap_id = replace (ap_id, 'old_domain', 'new_domain');
update post set url = replace (url, 'old_domain', 'new_domain');
update post set body = replace (body, 'old_domain', 'new_domain');
update post set thumbnail_url = replace (thumbnail_url, 'old_domain', 'new_domain');

-- Comments
update comment set ap_id = replace (ap_id, 'old_domain', 'new_domain');
update comment set content = replace (content, 'old_domain', 'new_domain');

-- User
update user_ set actor_id = replace (actor_id, 'old_domain', 'new_domain');
update user_ set inbox_url = replace (inbox_url, 'old_domain', 'new_domain');
update user_ set shared_inbox_url = replace (shared_inbox_url, 'old_domain', 'new_domain');
update user_ set avatar = replace (avatar, 'old_domain', 'new_domain');

-- Community
update community set actor_id = replace (actor_id, 'old_domain', 'new_domain');
update community set followers_url = replace (followers_url, 'old_domain', 'new_domain');
update community set inbox_url = replace (inbox_url, 'old_domain', 'new_domain');
update community set shared_inbox_url = replace (shared_inbox_url, 'old_domain', 'new_domain');

```

## Más recursos

- https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database
