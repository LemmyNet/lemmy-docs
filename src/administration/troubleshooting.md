# Troubleshooting

Different problems that can occur on a new instance, and how to solve them.

Many Lemmy features depend on a correct reverse proxy configuration. Make sure yours is equivalent to our [nginx config](https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/nginx.conf).

## General

### Logs

For frontend issues, check the [browser console](https://webmasters.stackexchange.com/a/77337) for any error messages.

For server logs, run `docker compose logs -f lemmy` in your installation folder. You can also do `docker compose logs -f lemmy lemmy-ui pictrs` to get logs from different services.

If that doesn't give enough info, try changing the line `RUST_LOG=error` in `docker-compose.yml` to `RUST_LOG=info` or `RUST_LOG=trace`, then do `docker compose restart lemmy`.

### Creating admin user doesn't work

Make sure that websocket is working correctly, by checking the browser console for errors. In nginx, the following headers are important for this:

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Rate limit error when many users access the site

Check that the headers `X-Real-IP` and `X-Forwarded-For` are sent to Lemmy by the reverse proxy. Otherwise, it will count all actions towards the rate limit of the reverse proxy's IP. In nginx it should look like this:

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Federation

### Other instances can't fetch local objects (community, post, etc)

Your reverse proxy (eg nginx) needs to forward requests with header `Accept: application/activity+json` to the backend. This is handled by the following lines:

```
set $proxpass "http://0.0.0.0:{{ lemmy_ui_port }}";
if ($http_accept = "application/activity+json") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
proxy_pass $proxpass;
```

You can test that it works correctly by running the following commands, all of them should return valid JSON:

```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # the id of a local post
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # the id of a local comment
```

### Fetching remote objects works, but posting/commenting in remote communities fails

Check that [federation is allowed on both instances](federation_getting_started.md).

Also ensure that the time is correct on your server. Activities are signed with a timestamp, and will be discarded if it is off by more than one hour.

It is possible that federation requests to `/inbox` are blocked by tools such as Cloudflare. The sending instance can find HTTP errors with the following steps:

- If you use a [separate container for outgoing federation](horizontal_scaling.md), you need to apply the following steps to that container only
- Set `RUST_LOG=lemmy_federate=trace` for Lemmy
- Reload the new configuration: `docker compose up -d`
- Search for messages containing the target instance domain: `docker compose logs -f --tail=100 lemmy |  grep -F lemm.ee -C 10`
- You also may have to reset the fail count for the target instance (see below)

### Reset federation fail count for instance

If federation sending to a specific instance has been failing consistently, Lemmy will slow down sending using exponential backoff. For testing it can be useful to reset this and make Lemmy send activities immediately. To do this use the following steps:

- Stop Lemmy, or specifically the container for outgoing federation `docker compose stop lemmy`
- Enter SQL command line: `sudo docker compose exec postgres psql -U lemmy`
- Reset failure count via SQL:
```sql
update federation_queue_state
set fail_count = 0
from instance
where instance.id = federation_queue_state.instance_id
and instance.domain = 'lemm.ee';
```
- Exit SQL command line with `\q`, then restart Lemmy: `docker compose start lemmy`

### Other instances don't receive actions reliably

Lemmy uses one queue per federated instance to send out activities. Search the logs for "Federation state" for summaries. Errors will also be logged.

For details, execute this SQL query:

```sql
select domain,currval('sent_activity_id_seq') as latest_id, last_successful_id,fail_count,last_retry from federation_queue_state
join instance on instance_id = instance.id order by last_successful_id asc;
```

You will see a table like the following:

| domain                     | latest_id | last_successful_id | fail_count | last_retry                    |
| -------------------------- | --------- | ------------------ | ---------- | ----------------------------- |
| toad.work                  | 6837196   | 6832351            | 14         | 2023-07-12 21:42:22.642379+00 |
| lemmy.deltaa.xyz           | 6837196   | 6837196            | 0          | 1970-01-01 00:00:00+00        |
| battleangels.net           | 6837196   | 6837196            | 0          | 1970-01-01 00:00:00+00        |
| social.fbxl.net            | 6837196   | 6837196            | 0          | 1970-01-01 00:00:00+00        |
| mastodon.coloradocrest.net | 6837196   | 6837196            | 0          | 1970-01-01 00:00:00+00        |

This will show you exactly which instances are up to date or not.

You can also use this website which will help you monitor this without admin rights, and also let others see it

https://phiresky.github.io/lemmy-federation-state/site

### You don't receive actions reliably

Due to the lemmy queue, remote lemmy instances will be sending apub sync actions serially to you. If your server rate of processing them is slower than the rate the origin server is sending them, when visiting the [lemmy-federation-state](https://phiresky.github.io/lemmy-federation-state/site) for the remote server, you'll see your instance in the "lagging behind" section.

This can be avoided by setting the config value `federation.concurrent_sends_per_instance` to a value greater than 1 on the sending instance.

Typically the speed at which you process an incoming action should be less than 100ms. If this is higher, this might signify problems with your database performance or your networking setup.

Note that even apub action ingestion speed which seems sufficient for most other instances, might become insufficient if the origin server is receiving actions from their userbase faster than you can process them. I.e. if the origin server receives 10 actions per second, but you can only process 8 actions per second, you'll inevitably start falling behind that one server only.

These steps might help you diagnose this.

#### Check processing time on the loadbalancer

Check how long a request takes to process on the backend. In haproxy for example, the following command will show you the time it takes for apub actions to complete

```bash
tail -f /var/log/haproxy.log | grep  "POST \/inbox"
```

[See here for nginx](https://www.nginx.com/blog/using-nginx-logging-for-application-performance-monitoring/)

If these actions take more than 100ms, you might want to investigate deeper.

#### Check your Database performance

Ensure that it's not very high in CPU or RAM utilization.

Afterwards check for slow queries. If you regularly see common queries with high max and mean exec time, it might signify your database is struggling. The below SQL query will show you all queries (you will need `pg_stat_statements` [enabled](https://www.postgresql.org/docs/current/pgstatstatements.html))

```sql
\x auto
SELECT user,query,max_exec_time,mean_exec_time,calls FROM pg_stat_statements WHERE max_exec_time > 10 AND CALLS > 100 ORDER BY max_exec_time DESC;
```

If you see very high time on inserts, you might want to consider disabling `synchronous_commit` to see if this helps.

#### Check your backend performance.

Like the DB, if the server where your lemmy rust backend is running is overloaded, you might see such an impact

#### Check your Network Layout

If your backend and database appear to be in good condition, it might be that your issue is network based.

One problem can occur is your backend and your database are not in the same server and are too far from each other in geographic location. Due to the amount of DB queries performed for each apub sync request, even a small amount of latency can quickly add up.

Check the latency between your rust backend and your DB using ping

```bash
ping your_database_ip
```

if the `time` you see if above 1-2ms, this can start causing such delays. In that case, you might want to consider moving your backend closer to your DB geographically, so that your latency is below 2ms

Note that your external loadbalancer(s) (if any) do not necessarily need to be closer to the DB, as they do not do multiple small DB requests.

## Downgrading

If you upgraded your instance to a newer version (by mistake or planned) and need to downgrade it. Often you need to reverse database changes as well.

First you need to figure out what SQL changes happened between your upgraded version, and the one you're downgrading. Then in that diff, check which files were added in the `migrations` dir.

Let's say that for the migration you're doing, the following were added

```
2023-10-24-131607_proxy_links
2023-10-27-142514_post_url_content_type
2023-12-19-210053_tolerable-batch-insert-speed
2023-12-22-040137_make-mixed-sorting-directions-work-with-tuple-comparison
2024-01-05-213000_community_aggregates_add_local_subscribers
2024-01-15-100133_local-only-community
2024-01-22-105746_lemmynsfw-changes
2024-01-25-151400_remove_auto_resolve_report_trigger
2024-02-15-171358_default_instance_sort_type
2024-02-27-204628_add_post_alt_text
2024-02-28-144211_hide_posts
```

Each of these folders contains a `down.sql` file. We need to run that against our postgresql DB to rollback those DB changes.

1. Stop your lemmy backend, and take a backup of your DB.
1. Copy the `migrations` folder to your DB container or server
1. Acquire a shell in your postgresql container or server and switch to the `postgres` user
1. Run each relevant script with this command
   ```bash
   downfolder=2024-02-28-144211_hide_posts
   psql -d lemmy -a -f /path/to/migrations/${downfolder}/down.sql
   ```
   Alternatively, copy the content of the file and paste into a psql session
1. You now need to clean the `__diesel_schema_migrations` table from the migration records, so that they will be correctly applied the next time you upgrade. You can use this command to sort them
   ```sql
   select * from __diesel_schema_migrations ORDER BY run_on ASC;
   ```
   You have to delete the entries in that table which match the current timestamp you applied them (This should typically be any time in the past few minutes)
   ```sql
   delete from __diesel_schema_migrations where version='20240228144211';
   ```
1. You should now be able to start your lemmy in the previous version
