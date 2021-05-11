# Резервное копирование и восстановление

## Docker и Ansible

При использовании docker или ansible, должен быть создан каталог `volumes` , содержащий обе базы данных, и все изображения. Скопируйте этот каталог в новый инстанс для восстановления ваших данных.

### Инкрементное резервное копирование базы данных

Для инкрементного резервного копирование БД в `.sql` файл, вы можете запустить: 

```bash
docker-compose exec postgres pg_dumpall -c -U lemmy >  lemmy_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
```
### Пример сценария резервного копирования

```bash
#!/bin/sh
# DB Backup
ssh MY_USER@MY_IP "docker-compose exec postgres pg_dumpall -c -U lemmy" >  ~/BACKUP_LOCATION/INSTANCE_NAME_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql

# Volumes folder Backup
rsync -avP -zz --rsync-path="sudo rsync" MY_USER@MY_IP:/LEMMY_LOCATION/volumes ~/BACKUP_LOCATION/FOLDERNAME
```

### Восстановление БД

Если вам необходимо восстановить из `pg_dumpall` файла, для начала необходимо очистить уже существующую БД

```bash
# Сбросьте существующую БД
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Восстановите БД из резервного .sql 
cat db_dump.sql  |  docker exec -i FOLDERNAME_postgres_1 psql -U lemmy # restores the db

# Возможно при импортировании БД, вам понадобится установить новый пароль, отличающийся от предыдущего.
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "alter user lemmy with password 'bleh'"
```

### Изменение вашего доменного имени

Если вы еще не федерируетесь, вы можете изменить свое доменное имя в БД. **Внимание: не делайте этого после начала федерирования, иначе сломаете процесс федерации.**

Зайдите в `psql` вашего docker : 

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

## Больше информации

- https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database
