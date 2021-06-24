# From Scratch 

> ⚠️ **Disclaimer:** this installation method is not recommended by the Lemmy developers. If you have any problems, you need to solve them yourself or ask the respective authors. If you notice any Lemmy bugs on an instance installed like this, please mention it in the bug report.

## Installing Lemmy from source code

Instructions for installing Lemmy natively, without relyng on Docker. Originally posted on [Some resources on setting Lemmy up from source - Lemmy dot C.A.](https://lemmy.ca/post/1066) **The current transcription has been adapted to improve readability**.

### Important
Note that building Lemmy requires a lot of hardware resources.  If you want to run Lemmy on a small VPS with very limited RAM (which seems like a perfectly acceptable way to run a production instance), maybe stick with the Docker image, or do your code building on another system that has more RAM.  RAM is huge with rust builds.

Tag/release versions included in this note come from lemmy/docker/prod/docker-compose.yml and were current at the time this document was created.  **Definitely adjust to appropriate versions as necessary**.

I had to switch from using `sudo` to `su`'ing in some places as the user was doing something odd/incomplete with the sudo env for pictrs

## Setup

| Dependencies                 |                                           |
|------------------------------|-------------------------------------------|
| app-admin                    | sudo                                      |
| dev-vcs                      | [git](https://git-scm.com/)               |
| dev-lang                     | [rust](https://www.rust-lang.org/)        |
| dev-db                       | [postgresql](https://www.postgresql.org/) |
| www-servers                  | [nginx](https://nginx.org/en/)            |
| sys-apps                     | [yarn](https://yarnpkg.com/)              |
| (optional) app-accessibility | espeak                                    |
| app-shells                   | bash-completion                           |


### Get postgresql service up & running

#### Gentoo

```bash
emerge --config dev-db/postgresql
rc-service postgresql-12 start
useradd -m -s /bin/bash lemmy
cd ~lemmy
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy.git
cd lemmy
```

### List the tags/releases available

#### Gentoo

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.11.0
```

### Build prod?  (Remove --release for dev)

#### Gentoo

```bash
sudo -Hu lemmy cargo build --release
cd ..
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy-ui.git
cd lemmy-ui
```

### List the tags/releases available

#### Gentoo

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.8.10
sudo -Hu lemmy git submodule init
sudo -Hu lemmy git submodule update --remote
```

### Build the frontend

#### This is for dev

##### Gentoo

```bash
sudo -Hu lemmy yarn
```

#### This is for prod

##### Gentoo

```bash
sudo -Hu lemmy yarn install --pure-lockfile
sudo -Hu lemmy yarn build:prod
```

**And this is just to run a dev env, but I think we'll prefer prod - use the init script**

##### Gentoo

```bash
sudo -Hu lemmy yarn dev
```

For prod, we'll use the [init script](#initlemmy), but the prod commandline is:

##### Gentoo

```bash
sudo -Hu node dist/js/server.js
```

### Setup the DB

#### Adjust 'password' to an actual password here and execute:

```bash
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
```

### iFramely install

git and nodejs required, but nodejs should be installed as a dependency of yarn.

#### Mentioned in case iFramely installed on separate system

##### Gentoo

```bash
useradd -m -s /bin/bash iframely

cd ~iframely
sudo -Hu iframely git clone https://github.com/itteco/iframely.git
cd iframely
sudo -Hu iframely git tag -l
sudo -Hu iframely git checkout tags/v1.5.0
sudo -Hu iframely npm install
```

Replace port 80 in this config? - why not leave at 8061; also, potentially replace or disable cache storage for now?  (CACHE_ENGINE: 'no-cache')

##### Gentoo

```bash
sudo -Hu iframely cp ~lemmy/lemmy/docker/iframely.config.local.js ~lemmy/iframely/config.local.js
```

Start the iframely server OR, use an [init script](#initiframely) instead, which is better than running this manually

See the [iframely config](#iframely-script) example.

##### Gentoo

```bash
sudo -Hu iframely node server
```

### pict-rs install

##### Gentoo
```bash
useradd -m -s /bin/bash pictrs
cp target/release/pict-rs .
```

Added hdri as magick_rust fails to compile if it's not there. Mentioned in [error[E0425]: cannot find value QuantumRange in module bindings](https://github.com/nlfiedler/magick-rust/issues/40)

```bash
echo "media-gfx/imagemagick hdri jpeg lzma png webp" >> /etc/portage/package.use
echo "*/* -llvm_targets_NVPTX -llvm_targets_AMDGPU" >> /etc/portage/package.use

```

Install extra packages required for pict-rs:

| packages    |                                                  |
|-------------|--------------------------------------------------|
| media-libs  | [gexiv2](https://gitlab.gnome.org/GNOME/gexiv2)  |
| media-gfx   | [imagemagick](https://imagemagick.org/index.php) |
| media-video | [ffmpeg](https://ffmpeg.org/)                    |
| sys-devel   | [clang](https://clang.llvm.org/)                 |

Packages required for pict-rs (in case on separate system):

| packages |                                    |
|----------|------------------------------------|
| dev-lang | [rust](https://www.rust-lang.org/) |

Script this or it has to be run manually as user...?

```bash
su - pictrs
git clone https://git.asonix.dog/asonix/pict-rs.git
cd pict-rs
git tag -l
git checkout tags/v0.2.5-r0

cargo build --release
cp target/release/pict-rs .
cd ~pictrs
mkdir pictrs-data
```

**Something missing in the pict-rs README - it created & uses a pict-rs folder in /tmp**

If you do anything funky like I have (changing the user pict-rs runs under) and you wind up with permission problems (which the logs don't tell you *what* it's having a permission issue with), this could be your issue. Also, time will tell whether this folder gets cleaned up appropriately or not.

Running pictrs is along the lines of:

```bash
pict-rs/pict-rs -a 127.0.0.1:9000 -p ~pictrs/pictrs-data/
```

But we'll just use the [init script](#initpict-rs). At this point, fire everything up via the [init scripts](#init-scripts), should all go. Setup the init scripts to run at boot time. Presumably you've [setup nginx as per examples](#nginx-script) and you can reach your instance.

---

## Updating

```bash
su - lemmy
cd lemmy
```

BACKUP [config/config.hjson](#config-script) somewhere

```bash
git fetch
git tag -l
git checkout tags/WHATEVER

cargo build --release

cd ~/lemmy-ui
```

#### List the tags/releases available

```bash
git fetch
git tag -l
git checkout tags/WHATEVER
git submodule update --remote
```

### Build the frontend

#### This is for prod

```bash
yarn install --pure-lockfile   # Is this step really needed?
#yarn upgrade --pure-lockfile  # ?? Did I get it?
#yarn   # Is this step really needed?  One of these steps is for sure. (Should be unnecessary)
yarn build:prod
```

restart lemmy-ui

### iFramely update

```bash
su - iframely
cd iframely
git fetch
git tag -l
git checkout tags/v1.6.0  # Or whatever the current appropriate release is
npm install
```

restart iframely

### pict-rs update

```bash
su - pictrs
cd pict-rs
git fetch
git tag -l
git checkout tags/v0.2.5-r0  # (or whatever is currently mentioned in the lemmy docker file)

cargo build --release
cp target/release/pict-rs .
```

restart pictrs

---

## Index: scripts

### config script

config/config.hjson example

```json
{
  database: {
    user: "lemmy"
    password: "whatever"
    host: "localhost"
    port: 5432
    database: "lemmy"
    pool_size: 5
  }
  hostname: "lemmy.ca"
  bind: "127.0.0.1"
  port: 8536
  docs_dir: "/home/lemmy/lemmy/docs/book"
  pictrs_url: "http://localhost:9000"
  iframely_url: "http://localhost:8061"
  federation: {
    enabled: true
    allowed_instances: ""
    blocked_instances: ""
  }
  email: {
    smtp_server: "localhost:25"
    smtp_from_address: "lemmy@lemmy.ca"
    use_tls: false
  }
}
```

### init scripts

##### init/iframely

```bash
#!/sbin/openrc-run

name="Iframely Daemon"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Iframely"
        start-stop-daemon --start --background --make-pidfile --user iframely --group iframely --pidfile /home/iframely/iframely.pid --chdir /home/iframely/iframely -3 /usr/bin/logger -4 /usr/bin/logger --exec node -- server
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/iframely/iframely.pid
        eend $?
}
```

##### init/lemmy

```bash
#!/sbin/openrc-run

name="Lemmy Backend"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Lemmy"
        start-stop-daemon --start --background --make-pidfile --user lemmy --group lemmy --pidfile /home/lemmy/lemmy.pid --chdir /home/lemmy/lemmy -3 /usr/bin/logger -4 /usr/bin/logger --exec ~lemmy/lemmy/target/release/lemmy_server
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/lemmy/lemmy.pid
        eend $?
}
```

##### init/lemmy-ui

```bash
#!/sbin/openrc-run

name="Lemmy UI"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Lemmy UI"
        start-stop-daemon --start --background --make-pidfile --user lemmy --group lemmy --pidfile /home/lemmy/lemmy-ui.pid --chdir /home/lemmy/lemmy-ui -3 /usr/bin/logger -4 /usr/bin/logger --exec node dist/js/server.js --env LEMMY_INTERNAL_HOST=127.0.0.1:8536 --env LEMMY_EXTERNAL_HOST=lemmy.ca --env LEMMY_HTTPS=true
        eend $?
}
```

##### init/pict-rs

```bash
#!/sbin/openrc-run

name="pict-rs Daemon"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting pictrs"
        start-stop-daemon --start --background --make-pidfile --user pictrs --group pictrs --pidfile /home/pictrs/pictrs.pid --chdir /home/pictrs/pict-rs -3 /usr/bin/logger -4 /usr/bin/logger --exec /home/pictrs/pict-rs/pict-rs -- -a 127.0.0.1:9000 -p ~pictrs/pictrs-data
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/pictrs/pictrs.pid
        eend $?
}
```

### iframely script

iframely.local.js example

```bash
(function() {
    var config = {

        // Specify a path for custom plugins. Custom plugins will override core plugins.
        // CUSTOM_PLUGINS_PATH: __dirname + '/yourcustom-plugin-folder',

        DEBUG: false,
        RICH_LOG_ENABLED: false,

        // For embeds that require render, baseAppUrl will be used as the host.
        baseAppUrl: "http://yourdomain.com",
        relativeStaticUrl: "/r",

        // Or just skip built-in renders altogether
        SKIP_IFRAMELY_RENDERS: true,

        // For legacy reasons the response format of Iframely open-source is
        // different by default as it does not group the links array by rel.
        // In order to get the same grouped response as in Cloud API,
        // add `&group=true` to your request to change response per request
        // or set `GROUP_LINKS` in your config to `true` for a global change.
        GROUP_LINKS: true,

        // Number of maximum redirects to follow before aborting the page
        // request with `redirect loop` error.
        MAX_REDIRECTS: 4,

        SKIP_OEMBED_RE_LIST: [
            // /^https?:\/\/yourdomain\.com\//,
        ],

        /*
        // Used to pass parameters to the generate functions when creating HTML elements
        // disableSizeWrapper: Don't wrap element (iframe, video, etc) in a positioned div
        GENERATE_LINK_PARAMS: {
            disableSizeWrapper: true
        },
        */

        port: 8061, //can be overridden by PORT env var
        host: '127.0.0.1',    // Dockers beware. See https://github.com/itteco/iframely/issues/132#issuecomment-242991246
                            //can be overridden by HOST env var

        // Optional SSL cert, if you serve under HTTPS.
        /*
        ssl: {
            key: require('fs').readFileSync(__dirname + '/key.pem'),
            cert: require('fs').readFileSync(__dirname + '/cert.pem'),
            port: 443
        },
        */

        /*
        Supported cache engines:
        - no-cache - no caching will be used.
        - node-cache - good for debug, node memory will be used (https://github.com/tcs-de/nodecache).
        - redis - https://github.com/mranney/node_redis.
        - memcached - https://github.com/3rd-Eden/node-memcached
        */
        CACHE_ENGINE: 'no-cache',
        CACHE_TTL: 0, // In seconds.
        // 0 = 'never expire' for memcached & node-cache to let cache engine decide itself when to evict the record
        // 0 = 'no cache' for redis. Use high enough (e.g. 365*24*60*60*1000) ttl for similar 'never expire' approach instead

        /*
        // Redis cache options.
        REDIS_OPTIONS: {
            host: '127.0.0.1',
            port: 6379
        },
        */

        /*
        // Memcached options. See https://github.com/3rd-Eden/node-memcached#server-locations
        MEMCACHED_OPTIONS: {
            locations: "127.0.0.1:11211"
        }
        */

        /*
        // Access-Control-Allow-Origin list.
        allowedOrigins: [
            "*",
            "http://another_domain.com"
        ],
        */

        /*
        // Uncomment to enable plugin testing framework.
        tests: {
            mongodb: 'mongodb://localhost:27017/iframely-tests',
            single_test_timeout: 10 * 1000,
            plugin_test_period: 2 * 60 * 60 * 1000,
            relaunch_script_period: 5 * 60 * 1000
        },
        */

        // If there's no response from remote server, the timeout will occur after
        RESPONSE_TIMEOUT: 5 * 1000, //ms

        /* From v1.4.0, Iframely supports HTTP/2 by default. Disable it, if you'd rather not.
           Alternatively, you can also disable per origin. See `proxy` option below.
        */
        // DISABLE_HTTP2: true,

        // Customize API calls to oembed endpoints.
        ADD_OEMBED_PARAMS: [{
            // Endpoint url regexp array.
            re: [/^http:\/\/api\.instagram\.com\/oembed/],
            // Custom get params object.
            params: {
                hidecaption: true
            }
        }, {
            re: [/^https:\/\/www\.facebook\.com\/plugins\/page\/oembed\.json/i],
            params: {
                show_posts: 0,
                show_facepile: 0,
                maxwidth: 600
            }
        }, {
            // match i=user or i=moment or i=timeline to configure these types invidually
            // see params spec at https://dev.twitter.com/web/embedded-timelines/oembed
            re: [/^https?:\/\/publish\.twitter\.com\/oembed\?i=user/i],
            params: {
                limit: 1,
                maxwidth: 600
            }
        /*
        }, {
            // Facebook https://developers.facebook.com/docs/plugins/oembed-endpoints
            re: [/^https:\/\/www\.facebook\.com\/plugins\/\w+\/oembed\.json/i],
            params: {
                // Skip script tag and fb-root div.
                omitscript: true
            }
        */
         }],

        /*
        // Configure use of HTTP proxies as needed.
        // You don't have to specify all options per regex - just what you need to override
        PROXY: [{
            re: [/^https?:\/\/www\.domain\.com/],
            proxy_server: 'http://1.2.3.4:8080',
            user_agent: 'CHANGE YOUR AGENT',
            headers: {
                // HTTP headers
                // Overrides previous params if overlapped.
            },
            request_options: {
                // Refer to: https://github.com/request/request
                // Overrides previous params if overlapped.
            },
            disable_http2: true
        }],
        */

        // Customize API calls to 3rd parties. At the very least - configure required keys.
        providerOptions: {
            locale: "en_US",    // ISO 639-1 two-letter language code, e.g. en_CA or fr_CH.
                                // Will be added as highest priotity in accept-language header with each request.
                                // Plus is used in FB, YouTube and perhaps other plugins
            "twitter": {
                "max-width": 550,
                "min-width": 250,
                hide_media: false,
                hide_thread: false,
                omit_script: false,
                center: false,
                // dnt: true,
                cache_ttl: 100 * 365 * 24 * 3600 // 100 Years.
            },
            readability: {
                enabled: false
                // allowPTagDescription: true  // to enable description fallback to first paragraph
            },
            images: {
                loadSize: false, // if true, will try an load first bytes of all images to get/confirm the sizes
                checkFavicon: false // if true, will verify all favicons
            },
            tumblr: {
                consumer_key: "INSERT YOUR VALUE"
                // media_only: true     // disables status embeds for images and videos - will return plain media
            },
            google: {
                // https://developers.google.com/maps/documentation/embed/guide#api_key
                maps_key: "INSERT YOUR VALUE"
            },

            /*
            // Optional Camo Proxy to wrap all images: https://github.com/atmos/camo
            camoProxy: {
                camo_proxy_key: "INSERT YOUR VALUE",
                camo_proxy_host: "INSERT YOUR VALUE"
                // ssl_only: true // will only proxy non-ssl images
            },
            */

            // List of query parameters to add to YouTube and Vimeo frames
            // Start it with leading "?". Or omit alltogether for default values
            // API key is optional, youtube will work without it too.
            // It is probably the same API key you use for Google Maps.
            youtube: {
                // api_key: "INSERT YOUR VALUE",
                get_params: "?rel=0&showinfo=1"     // https://developers.google.com/youtube/player_parameters
            },
            vimeo: {
                get_params: "?byline=0&badge=0"     // https://developer.vimeo.com/player/embedding
            },

            /*
            soundcloud: {
                old_player: true // enables classic player
            },
            giphy: {
                media_only: true // disables branded player for gifs and returns just the image
            }
            */
            /*
            bandcamp: {
                get_params: '/size=large/bgcol=333333/linkcol=ffffff/artwork=small/transparent=true/',
                media: {
                    album: {
                        height: 472,
                        'max-width': 700
                    },
                    track: {
                        height: 120,
                        'max-width': 700
                    }
                }
            }
            */
        },

        // WHITELIST_WILDCARD, if present, will be added to whitelist as record for top level domain: "*"
        // with it, you can define what parsers do when they run accross unknown publisher.
        // If absent or empty, all generic media parsers will be disabled except for known domains
        // More about format: https://iframely.com/docs/qa-format

        /*
        WHITELIST_WILDCARD: {
              "twitter": {
                "player": "allow",
                "photo": "deny"
              },
              "oembed": {
                "video": "allow",
                "photo": "allow",
                "rich": "deny",
                "link": "deny"
              },
              "og": {
                "video": ["allow", "ssl", "responsive"]
              },
              "iframely": {
                "survey": "allow",
                "reader": "allow",
                "player": "allow",
                "image": "allow"
              },
              "html-meta": {
                "video": ["allow", "responsive"],
                "promo": "allow"
              }
        }
        */

        // Black-list any of the inappropriate domains. Iframely will return 417
        // At minimum, keep your localhosts blacklisted to avoid SSRF
        BLACKLIST_DOMAINS_RE: [
            /^https?:\/\/127\.0\.0\.1/i,
            /^https?:\/\/localhost/i,

            // And this is AWS metadata service
            // https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html
            /^https?:\/\/169\.254\.169\.254/
        ]
    };

    module.exports = config;
})();
```

### nginx script

nginx.conf example

```bash
user nginx nginx;
worker_processes 1;

error_log /var/log/nginx/error_log info;

events {
        worker_connections 1024;
        use epoll;
}

http {

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        log_format main
                '$remote_addr - $remote_user [$time_local] '
                '"$request" $status $bytes_sent '
                '"$http_referer" "$http_user_agent" '
                '"$gzip_ratio"';

        client_header_timeout 10m;
        client_body_timeout 10m;
        send_timeout 10m;

        connection_pool_size 256;
        client_header_buffer_size 1k;
        large_client_header_buffers 4 2k;
        request_pool_size 4k;

        gzip off;

        output_buffers 1 32k;
        postpone_output 1460;

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;

        keepalive_timeout 75 20;

        ignore_invalid_headers on;

        index index.html;

## Lemmy config starts here

limit_req_zone $binary_remote_addr zone=lemmy_ratelimit:10m rate=1r/s;

server {
    server_name yoursite.com www.yoursite.com;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    # Hide nginx version
    server_tokens off;

    # Enable compression for JS/CSS/HTML bundle, for improved client load times.
    # It might be nice to compress JSON, but leaving that out to protect against potential
    # compression+encryption information leak attacks like BREACH.
    gzip on;
    gzip_types text/css application/javascript image/svg+xml;
    gzip_vary on;

    # Only connect to this site via HTTPS for the two years
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # Various content security headers
    add_header Referrer-Policy "same-origin";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Frame-Options "DENY";
    add_header X-XSS-Protection "1; mode=block";

    # Upload limit for pictrs
    client_max_body_size 20M;

    # frontend
    location / {
      # The default ports:
      # lemmy_ui_port: 1234
      # lemmy_port: 8536

      set $proxpass "http://127.0.0.1:1234";
      if ($http_accept = "application/activity+json") {
        set $proxpass "http://127.0.0.1:8536";
      }
      if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
        set $proxpass "http://127.0.0.1:{{ lemmy_port }}";
      }
      if ($request_method = POST) {
        set $proxpass "http://127.0.0.1:8536";
      }
      proxy_pass $proxpass;

      rewrite ^(.+)/+$ $1 permanent;

      # Add IP forwarding headers
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # backend
    location ~ ^/(api|docs|pictrs|feeds|nodeinfo|.well-known) {
      proxy_pass http://127.0.0.1:8536;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";

      # Rate limit
      limit_req zone=lemmy_ratelimit burst=30 nodelay;

      # Add IP forwarding headers
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }


    # Redirect pictshare images to pictrs
    location ~ /pictshare/(.*)$ {
      return 301 /pictrs/image/$1;
    }

    location /iframely/ {
      proxy_pass http://127.0.0.1:8061/;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header Host $host;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    listen [::]:443 ssl http2 ipv6only=off; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/yoursite.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/yoursite.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}

# Anonymize IP addresses
# https://www.supertechcrew.com/anonymizing-logs-nginx-apache/
#map $remote_addr $remote_addr_anon {
#  ~(?P<ip>\d+\.\d+\.\d+)\.    $ip.0;
#  ~(?P<ip>[^:]+:[^:]+):       $ip::;
#  127.0.0.1                   $remote_addr;
#  ::1                         $remote_addr;
#  default                     0.0.0.0;
#}
#log_format main '$remote_addr_anon - $remote_user [$time_local] "$request" '
#'$status $body_bytes_sent "$http_referer" "$http_user_agent"';
#access_log /var/log/nginx/access.log main;
access_log /var/log/nginx/access.log main;



server {
    if ($host = www.yoursite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = yoursite.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen [::]:80 ipv6only=off;
    server_name yoursite.com www.yoursite.com;
    return 404; # managed by Certbot




}}
```

