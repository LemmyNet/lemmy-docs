# Scaling Lemmy horizontally

This is a collection of notes on scaling different Lemmy components horizontally. This is not meant as a step-by-step guide, rather as general tips and knowledge that might be useful to somebody who is already familiar with and horizontal scaling concepts and best practices. If you don't already know about concepts like load balancing, object storage, and reverse proxies, then this document will probably be hard (or impossible) to understand.

**Note: scaling Lemmy this way is not necessary, and for small instances, the added overhead most likely outweighs any benefits.**

## Why scale horizontally?

- If one of your Lemmy servers dies for any reason, your instance can still remain operational
- Having multiple Lemmy servers allows you to do rolling upgrades (no downtime needed to upgrade Lemmy!)
- Horizontal scaling provides additional flexibility in how you upgrade your infrastructure
- As of Lemmy version 0.18.2, Lemmy appears to be able to use the same resources more efficiently if they are split between multiple Lemmy processes

## Breakdown of Lemmy components

See [Lemmy components](administration.md#lemmy-components) for a high level overview of what each component does.

### Lemmy-ui

Lemmy-ui can be horizontally scaled, but make sure you read the following section for information about rolling upgrades.

#### Rolling upgrades

In general, there is nothing preventing you from running multiple load balanced Lemmy-ui servers in parallel, but without some custom configuration, **rolling upgrades will break Lemmy for your users!** This is because by default, Lemmy-ui will serve static files through the express process.

Consider the scenario where you have 2 Lemmy-ui servers, one is running on version 1, and the other has just come online running version 2. A user opening your Lemmy in their browser might have their front page html request routed to version 1. This html will contain a reference to many other static files which are specific to version 1. Most likely, some of these requests will get routed to the server running version 2. **The files will not exist on this server, the server will respond with 404, and the UI will remain in a broken state.**

There are a few ways to work around this issue:

1. The safest option is to ensure that all servers are able to serve static files for all currently active Lemmy-ui versions.

   - There are many ways to achieve this, the most obvious one being to upload your static files to object storage, and have reverse proxies route static file requests to your static files bucket.
   - Here's one possible example of how to do this with nginx:

   ```
   location /static {
      expires 1y;
      add_header Cache-Control "public";
      proxy_pass https://${bucket_fqdn};

      limit_except GET {
          deny  all;
      }

      proxy_intercept_errors on;
      # invalid keys result in 403
      error_page 403 =404 /@404static;
   }
   ```

   Replace `${bucket_fqdn}` with the URL to your bucket. With this setup, you should upload the contents of the lemmy-ui `dist/` directory to a "directory" named `static/$LEMMY_UI_HASH` in your bucket, where the hash is calculated from the commit you are deploying: `export LEMMY_UI_HASH=$(git rev-parse --short HEAD)`. Note that this setup requires public acl on uploaded files, so it's recommended to limit access to your bucket with an IP allowlist policy.

2. An alternative option is to configure sticky sessions in your load balancer. This will ensure that subsequent requests all end up on the same Lemmy-ui server, and as long as your sticky sessions last longer than your upgrade process, most clients should remain functional.
3. Similarly to sticky sessions, another possibility is to configure ip hash based load balancing.
4. There is always the option to just employ downtime and upgrade all servers at once (but that's not very fun!)

### Lemmy_server

Lemmy_server can be horizontally scaled, with a few caveats.

Here's a quick example on how you could start 3 web servers, 3 federation servers and one scheduled task process:

```
lemmy_server --http-server=false --federate-activities=false # scheduled tasks
lemmy_server --http-server=true --federate-activities=false --disable-scheduled-task # http server 1
lemmy_server --http-server=true --federate-activities=false --disable-scheduled-task # http server 2
lemmy_server --http-server=true --federate-activities=false --disable-scheduled-task # http server 3

# federation server 1/3
lemmy_server --http-server=false --federate-activities=true --federate-process-index=1 --federate-process-count=3 --disable-scheduled-tasks
# federation server 2/3
lemmy_server --http-server=false --federate-activities=true --federate-process-index=2 --federate-process-count=3 --disable-scheduled-tasks
# federation server 3/3
lemmy_server --http-server=false --federate-activities=true --federate-process-index=3 --federate-process-count=3 --disable-scheduled-tasks
```

#### Scheduled tasks

By default, a Lemmy_server process will run background scheduled tasks, which must be run only on one server. Launching multiple processes with the default configuration will result in multiple duplicated scheduled tasks all starting at the same moment and trying to do the same thing at once.

To solve this, Lemmy must be started with the `--disable-scheduled-tasks` flag on all but one instance. In general, there are two approaches:

1. Run all your load balanced Lemmy servers with the `--disable-scheduled-tasks` flag, and run one additional Lemmy server without this flag which is not in your load balancer and does not accept any HTTP traffic.
2. Run one load balanced Lemmy server without the flag, and all other load balanced servers with the flag.

#### Federation queue

The persistent federation queue (since 0.19) is split by federated domain and can be processed in equal-size parts run in separate processes. To split the queue up into N processes numbered 1...N, use the arguments `--federate-process-index=i --federate-process-count=N` on each. It is important that each index is is given to exactly one process, otherwise you will get undefined behaviour (missing, dupe federation, crashes).

Federation processes can be started and stopped at will. They will restart federation to each instance from the last transmitted activity regardless of downtime.

#### Rolling upgrades

For most versions, rolling releases have been completely OK, but there have been some cases where a database migration slips in which is NOT backwards compatible (causing any servers running the older version of Lemmy to potentially start generating errors). To be safe, you should always first take a look at [what database migrations are included in a new version](https://github.com/LemmyNet/lemmy/tree/main/migrations), and evaluate whether the changes are for sure safe to apply with running servers.

Note that even if there are no backwards incompatible migrations between immediate version upgrades (version 1 -> 2 is safe and 2 -> 3 is safe), doing bigger upgrades might cause these same migrations to become backwards incompatible (a server running version 1 might not be compatible with migrations from version 3 in this scenario). **It is generally best to only upgrade one version at a time!**.

For the scheduled task process, it shouldn't cause any major issues to have two servers running in parallel for a short duration during an upgrade, but shutting the old one down before starting the new one will always be safer.

### Pict-rs

Pict-rs does not scale horizontally as of writing this document. This is due to a dependency on a Sled database, which is a disk based database file.

The developer of pict-rs has mentioned plans to eventually add Postgres support (which should in theory enable horizontal scaling), but work on this has not yet started.

Note that by caching pict-rs images (for example, with nginx, or with a CDN), you can really minimize load on the pict-rs server!

## Other tips

1. Your lemmy-ui servers need to access your backend as well. If you don't want a complicated setup with multiple load balancers, you could just have each of your servers contain nginx, lemmy-ui, and lemmy_server, and just load balance to an nginx on each of your servers
2. Make sure you're passing the real client ip address to Lemmy, otherwise Lemmy's built in rate limiter will trigger very often (if it rate limits based on your load balancer's IP address, for example). With nginx, you should use something like this in your nginx.conf:

   ```
   real_ip_recursive on;
   real_ip_header X-Forwarded-For;
   set_real_ip_from <your load balancer ip here>;
   ```

3. The internal Lemmy load balancer works based on an in-memory storage of ip addresses. That means that by adding more Lemmy servers, you are effectively making your rate limits less strict. If you rely on the built in limiter, make sure to adjust the limits accordingly!
