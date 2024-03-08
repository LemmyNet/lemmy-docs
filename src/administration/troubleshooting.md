# Troubleshooting

Different problems that can occur on a new instance, and how to solve them.

Many Lemmy features depend on a correct reverse proxy configuration. Make sure yours is equivalent to our [nginx config](https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/nginx.conf).

## General

### Logs

For frontend issues, check the [browser console](https://webmasters.stackexchange.com/a/77337) for any error messages.

For server logs, run `docker compose logs -f lemmy` in your installation folder. You can also do `docker compose logs -f lemmy lemmy-ui pictrs` to get logs from different services.

If that doesn't give enough info, try changing the line `RUST_LOG=error` in `docker-compose.yml` to `RUST_LOG=info` or `RUST_LOG=verbose`, then do `docker compose restart lemmy`.

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

Also ensure that the time is accurately set on your server. Activities are signed with a timestamp, and will be discarded if it is off by more than 10 seconds.

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

Due to the lemmy queue, remove lemmy instances will be sending apub sync actions serially to you. If your server rate of processing them is slower than the rate the origin server is sending them, when visiting the [lemmy-federation-state](https://phiresky.github.io/lemmy-federation-state/site) for the remote server, you'll see your instance in the "lagging behing" section.

Typically the speed at which you process an incoming action should be less than 100ms. If this is higher, this might signify problems with your database performance or your networking setup.

Note that even apub action ingestion speed which seems sufficient for most other instances, might become insufficient if the origin server is receiving actions faster than you can process them. I.e. if the origin server receives 10 actions per second, but you can only process 8 actions per second, you'll inevitably start falling behind that one server only.

These steps might help you diagnose this.

#### Check processing time on the loadbalancer

Check how long a request takes to process on the backend. In haproxy for example, the following command will show you the time it takes for apub actions to complete 
   
```bash
tail -f /var/log/haproxy.log | grep  "POST \/inbox"
```
If these actions take more than 100ms, you might want to investigate deeper.

####  Check your Database performance

Ensure that it's not very high in CPU or RAM utilization. 

Afterwards check for slow queries. If you regularly see common queries  with high max and mean exec time, it might signify your database is struggling. The below SQL query will show you all queries (you will need `pg_stat_statements` enabled)

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

