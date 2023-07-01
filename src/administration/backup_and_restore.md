# Backup and Restore Guide

## Docker and Ansible

When using docker or ansible, there should be a `volumes` folder, which contains both the database, and all the pictures. Copy this folder to the new instance to restore your data.

### Full Database backup

To take a complete backup of the DB to a `.sql.gz` file, you can run:

```bash
docker-compose exec postgres pg_dumpall -c -U lemmy | gzip > lemmy_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql.gz
```

_For compression, you can use either gzip and gunzip, or xz and unxz._

### A Sample backup script

```bash
#!/bin/sh
# DB Backup
ssh MY_USER@MY_IP "docker-compose exec postgres pg_dumpall -c -U lemmy" | gzip > ~/BACKUP_LOCATION/INSTANCE_NAME_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql.gz

# Volumes folder Backup
rsync -avP -zz --rsync-path="sudo rsync" MY_USER@MY_IP:/LEMMY_LOCATION/volumes ~/BACKUP_LOCATION/FOLDERNAME
```

### Restoring the DB

To restore, run:

```bash
docker-compose up -d postgres

# Restore from the .sql.gz backup
gunzip < db_dump.sql  |  docker-compose exec -T postgres psql -U lemmy

# Note: You may need to change the permissions on the postgres directory, depending on your system.
chown -R $USER volumes
docker-compose restart postgres

# Continue with the startup
docker-compose up -d
```

If you've accidentally already started the lemmy service, you need to clear out your existing database:

```bash
# Drop the existing DB
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# This also might be necessary when doing a db import with a different password.
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "alter user lemmy with password 'bleh'"
```

Then run the restore commands above.

### Changing your domain name

If you haven't federated yet, you can change your domain name in the DB. **Warning: do not do this after you've federated, or it will break federation.**

Get into `psql` for your docker:

`docker-compose exec postgres psql -U lemmy`

```sql
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

## More resources

- https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database
