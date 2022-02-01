# Petunjuk Pencadangan dan Pemulihan

## Docker dan Ansible

Ketika menggunakan Docker atau Ansible, seharusnya ada folder `volumes` yang mengandung baik basis data dan seluruh gambar. Salin folder ini ke peladen baru untuk memulihkan data Anda

### Pencadangan basis data bertahap

Untuk pencadangan DB bertahap ke berkas `.sql`, Anda bisa menjalankan:

```bash
docker-compose exec postgres pg_dumpall -c -U lemmy >  lemmy_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql
```
### Contoh skrip pencadangan

```bash
#!/bin/sh
# Pencadangan DB
ssh MY_USER@MY_IP "docker-compose exec postgres pg_dumpall -c -U lemmy" >  ~/BACKUP_LOCATION/INSTANCE_NAME_dump_`date +%Y-%m-%d"_"%H_%M_%S`.sql

# Pencadangan folder volumes
rsync -avP -zz --rsync-path="sudo rsync" MY_USER@MY_IP:/LEMMY_LOCATION/volumes ~/BACKUP_LOCATION/FOLDERNAME
```

### Memulihkan DB

Jika Anda perlu untuk memulihkan dari berkas `pg_dumpall`, pertama-tama Anda perlu membersihkan basis data telah ada Anda. 

```bash
# Drop the existing DB
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Restore from the .sql backup
cat db_dump.sql  |  docker exec -i FOLDERNAME_postgres_1 psql -U lemmy # restores the db

# This also might be necessary when doing a db import with a different password.
docker exec -i FOLDERNAME_postgres_1 psql -U lemmy -c "alter user lemmy with password 'bleh'"
```

### Mengubah nama domain Anda

Jika Anda belum terfederasi, Anda bisa mengubah nama domain Anda di DB. **Peringatan: jangan lakukan ini setelah Anda terfederasi atau itu akan merusak federasi.**

Pergi ke `psql` dari Docker Anda: 

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

## Lihat juga

- https://stackoverflow.com/questions/24718706/backup-restore-a-dockerized-postgresql-database


