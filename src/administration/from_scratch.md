# From Scratch

These instructions are written for Ubuntu 20.04 / Ubuntu 22.04. They are particularly useful when you'd like to setup a Lemmy container (e.g. LXC on Proxmox) and cannot use Docker.

Lemmy is built from source in this guide, so this may take a while, especially on slow devices. For example, Lemmy v0.18.5 takes around 7 minutes to build on a quad core VPS. 

Installing and configuring Lemmy using this guide takes about 60-90 minutes. You might need to make yourself a fresh cup of coffee before you start.

While is not an officially supported installation method for Lemmy, it is not that hard. Maybe someone will eventually create an Ansible script for this as well. 

## Installation

### Database
For Ubuntu 20.04 the shipped PostgreSQL version is 12 which is not supported by Lemmy. So let's set up a newer one. 
The most recent stable version of PostgreSQL is 16 at the time of writing this guide.

#### Install dependencies
```
sudo apt install wget ca-certificates
sudo apt install pkg-config libssl-dev libpq-dev postgresql
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt install pkg-config libssl-dev libpq-dev postgresql
```

#### Setup Lemmy database

Replace db-passwd with a unique password of your choice in the commands below.

```
sudo -iu postgres psql -c "CREATE USER lemmy WITH PASSWORD 'db-passwd';"
sudo -iu postgres psql -c "CREATE DATABASE lemmy WITH OWNER lemmy;"
```

If you're migrating from an older version of Lemmy, the following might be required. 
```
sudo -iu postgres psql -c "ALTER USER lemmy WITH SUPERUSER;"
```
Tune your PostgreSQL settings to match your hardware via [this guide](https://pgtune.leopard.in.ua/#/)

#### Setup md5 auth

Lemmy currently only supports only non-SSL connections to databases. More info [here](https://github.com/LemmyNet/lemmy/issues/3007).

Your Postgres config might need to be edited to allow password authentication instead of peer authentication. Simply add the following to your `pg_hba.conf`:
```
local   lemmy           lemmy                                   md5
```

### Install Rust
For the Rust compiles, it is ideal to use a non-privledged Linux account on your system. 

Install Rust by following the instructions on [Rustup](https://rustup.rs/) (using a non-privledged Linux account, it will install file in that user's home folder for rustup and cargo).

protobuf-compiler may be required for Ubuntu 20.04 or 22.04 installs, please report testing in lemmy-docs issues. 
```
sudo apt install protobuf-compiler
```

### Setup pict-rs (Optional)

You can skip this section if you don't require image hosting, but **NOTE that Lemmy-ui will still allow users to attempt uploading images even if pict-rs is not configured. In this situation, the upload will fail and users will receive technical error messages.**

Lemmy supports image hosting using [pict-rs](https://git.asonix.dog/asonix/pict-rs/). We need to install a couple of dependencies for this. 

Depending on preference, pict-rs can be installed as a standalone application, or it can be embedded within Lemmy itself (see below). In both cases, pict-rs requires the `magick` command which comes with Imagemagick version 7, but Ubuntu 20.04 only comes with Imagemagick 6. So you need to install that command manually, eg from the [official website](https://imagemagick.org/script/download.php#linux). 

**NOTE: on standard LXC containers an AppImage-based ImageMagick installation [will not work properly](https://github.com/LemmyNet/lemmy/issues/4112) with both embdedded and standalone pict-rs. It uses FUSE which will emit "permission denied" errors when trying to upload an image through pict-rs. You must use alternative installation methods, such as [imei.sh](https://github.com/SoftCreatR/imei).**

#### AppImage-based installation of ImageMagick
```bash
sudo apt install ffmpeg exiftool libgexiv2-dev --no-install-recommends
# save the file to a working folder it can be verified before copying to /usr/bin/
wget https://download.imagemagick.org/ImageMagick/download/binaries/magick
# compare hash with the "message digest" on the official page linked above
sha256sum magick
sudo mv magick /usr/bin/
sudo chmod 755 /usr/bin/magick
```

#### imei.sh-based installation of ImageMagick
Follow the instructions from the [official imei.sh page on GitHub](https://github.com/SoftCreatR/imei)

#### Standalone pict-rs installation
Since we're building stuff from source here, let's do the same for pict-rs. Follow the [instructions here](https://git.asonix.dog/asonix/pict-rs/#user-content-compile-from-source). 

However, as mentioned above, the embedded pict-rs installation should work just fine for you. 

### Lemmy Backend
#### Build the backend
Create user account on Linux for the lemmy_server application
```
sudo adduser lemmy --system --disabled-login --no-create-home --group
```

Compile and install Lemmy, given the from-scratch intention, this will be done via GitHub checkout. This can be done by a normal unprivledged user (using the same Linux account you used for rustup).

```bash
git clone https://github.com/LemmyNet/lemmy.git lemmy
cd lemmy
git checkout 0.18.5
git submodule init
git submodule update --recursive --remote
echo "pub const VERSION: &str = \"$(git describe --tag)\";" > "crates/utils/src/version.rs"
```

When using the embedded pict-rs, use the following build command:
```
cargo build --release --features embed-pictrs
```

Otherwise, just move forward with the following.
```
cargo build --release
```

#### Deployment
Because we should [follow the Linux way](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html), we should use the `/opt` directory to colocate the backend, frontend and pict-rs.

```
sudo mkdir /opt/lemmy
sudo mkdir /opt/lemmy/lemmy-server
sudo mkdir /opt/lemmy/pictrs
sudo mkdir /opt/lemmy/pictrs/files
sudo mkdir /opt/lemmy/pictrs/sled-repo
sudo mkdir /opt/lemmy/pictrs/old
sudo chown -R lemmy:lemmy /opt/lemmy
```

Note that it might not be the most obvious thing, but **creating the pictrs directories is not optional**.

Then copy the binary.
```
sudo cp target/release/lemmy_server /opt/lemmy-server/lemmy_server
```

#### Configuration
This is the minimal Lemmy config, put this in `/opt/lemmy/lemmy-server/lemmy.hjson` (see [here](https://github.com/LemmyNet/lemmy/blob/main/config/config.hjson) for more config options). 

```hjson
{
  database: {
    # put your db-passwd from above
    password: "db-passwd"
  }
  # replace with your domain
  hostname: example.com
  bind: "127.0.0.1"
  federation: {
    enabled: true
  }
  # remove this block if you don't require image hosting
  pictrs: {
    url: "http://localhost:8080/"
  }
}
```
Set the correct owner
```
chown -R lemmy:lemmy /opt/lemmy/
```

#### Server daemon
Add a systemd unit file, so that Lemmy automatically starts and stops, logs are handled via journalctl etc. Put this file into /etc/systemd/system/lemmy.service.

```
[Unit]
Description=Lemmy Server
After=network.target

[Service]
User=lemmy
ExecStart=/opt/lemmy/lemmy-server/lemmy_server
Environment=LEMMY_CONFIG_LOCATION=/opt/lemmy/server/lemmy.hjson
Environment=PICTRS_ADDR=127.0.0.1:8080
Environment=RUST_LOG="info"
Restart=on-failure
WorkingDirectory=/opt/lemmy

# Hardening
ProtectSystem=yes
PrivateTmp=true
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

If you need debug output in the logs, change the RUST_LOG line in the file above to
```
Environment=RUST_LOG="debug,lemmy_server=debug,lemmy_api=debug,lemmy_api_common=debug,lemmy_api_crud=debug,lemmy_apub=debug,lemmy_db_schema=debug,lemmy_db_views=debug,lemmy_db_views_actor=debug,lemmy_db_views_moderator=debug,lemmy_routes=debug,lemmy_utils=debug,lemmy_websocket=debug"
```

Then run
```
sudo systemctl daemon-reload
sudo systemctl enable lemmy
sudo systemctl start lemmy
```
If you did everything right, the Lemmy logs from `sudo journalctl -u lemmy` should show "Starting http server at 127.0.0.1:8536". You can also run `curl localhost:8536/api/v3/site` which should give a successful response, looking like `{"site_view":null,"admins":[],"banned":[],"online":0,"version":"unknown version","my_user":null,"federated_instances":null}`. For pict-rs, run `curl 127.0.0.1:8080` and ensure that it outputs nothing (particularly no errors).

### Lemmy Front-end (lemmy-ui)
#### Install dependencies
Nodejs and yarn in Ubuntu 20.04 / Ubuntu 22.04 repos are too old, so let's install Node 20. 

```
# yarn 
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# nodejs
sudo apt install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt update
sudo apt install nodejs yarn
```

#### Build the front-end
Clone the git repo, checkout the version you want (0.18.5 in this case), and compile it.

```
# dont compile as admin
cd /opt/lemmy
sudo -u lemmy bash
git clone https://github.com/LemmyNet/lemmy-ui.git --recursive
cd lemmy-ui
git checkout 0.18.5 # replace with the version you want to install
yarn install --pure-lockfile
yarn build:prod
exit
```

#### UI daemon
Add another systemd unit file, this time for lemmy-ui. You need to replace `example.com` with your actual domain. Put the file in `/etc/systemd/system/lemmy-ui.service`

```
[Unit]
Description=Lemmy UI
After=lemmy.service
Before=nginx.service

[Service]
User=lemmy
WorkingDirectory=/opt/lemmy/lemmy-ui
ExecStart=/usr/bin/node dist/js/server.js
Environment=LEMMY_UI_LEMMY_INTERNAL_HOST=localhost:8536
Environment=LEMMY_UI_LEMMY_EXTERNAL_HOST=example.com
Environment=LEMMY_UI_HTTPS=false
Restart=on-failure

# Hardening
ProtectSystem=full
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

More UI-related variables can be [found here](https://github.com/LemmyNet/lemmy-ui#configuration).

Then run.
```
sudo systemctl daemon-reload
sudo systemctl enable lemmy-ui
sudo systemctl start lemmy-ui
```

If everything went right, the command `curl -I localhost:1234` should show `200 OK` at the top.

### Configure reverse proxy and TLS

Install dependencies

```bash
sudo apt install nginx certbot python3-certbot-nginx
```

Request Let's Encrypt TLS certificate (just follow the instructions)

```bash
sudo certbot certonly --nginx
```

Let's Encrypt certificates should be renewed automatically, so add the line below to your crontab, by running `sudo crontab -e`. Replace `example.com` with your actual domain.

```
@daily certbot certonly --nginx --cert-name example.com -d example.com --deploy-hook 'nginx -s reload'
```

Finally, add the nginx config file. After downloading, you need to replace some variables in the file.

```bash
curl https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx.conf \
    --output /etc/nginx/sites-enabled/lemmy.conf
# put your actual domain instead of example.com
sed -i -e 's/{{domain}}/example.com/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_port}}/8536/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_ui_port}}/1234/g' /etc/nginx/sites-enabled/lemmy.conf
nginx -s reload
```

If you don't need HTTPS on nginx, the below file can be used as an updated template. Otherwise, feel free to merge changes from it to your own version.

```
limit_req_zone $binary_remote_addr zone=YOURDOMAIN.COM_ratelimit:10m rate=1r/s;
proxy_cache_path /var/cache/nginx keys_zone=lemmy_cache_YOURDOMAIN.COM:1m;

server {
    listen 80;
    server_name YOURDOMAIN.COM;
    # Hide nginx version
    server_tokens off;

    # Upload limit, relevant for pictrs
    client_max_body_size 20M;

    # Enable compression for JS/CSS/HTML bundle, for improved client load times.
    # It might be nice to compress JSON, but leaving that out to protect against potential
    # compression+encryption information leak attacks like BREACH.
    gzip on;
    gzip_types text/css application/javascript image/svg+xml;
    gzip_vary on;

    # Various content security headers
    add_header Referrer-Policy "same-origin";
    add_header X-Content-Type-Options "nosniff";
    add_header X-Frame-Options "DENY";
    add_header X-XSS-Protection "1; mode=block";

    location / {
      proxy_http_version 1.1;

      set $proxpass "http://127.0.0.1:1234";  
      if ($http_accept ~ "^application/.*$") {
          set $proxpass "http://localhost:8536";
      }
                        
      if ($uri ~ "^(.*)/(api|pictrs|feeds|nodeinfo|.well-known)(.*)") {
          set $proxpass "http://127.0.0.1:8536";
      }
 
      if ($request_method = POST) {
          set $proxpass "http://127.0.0.1:8536";
      }

      proxy_pass $proxpass;
    }
}
```

Now open your Lemmy domain in the browser, and it should show you a configuration screen. Use it to create the first admin user and the default community.

## Upgrading

### Lemmy

Compile and install lemmy_server changes. This compile can be done by a normal unprivledged user (using the same Linux account you used for rustup and first install of Lemmy).

```bash
rustup update
cd lemmy
git checkout main
git pull --tags
git checkout 0.18.5 # replace with version you are updating to
git submodule update --recursive --remote
echo "pub const VERSION: &str = \"$(git describe --tag)\";" > "crates/utils/src/version.rs"
# These instructions assume you build pictrs independent, but it is
# OPTIONAL on next command: --features embed-pictrs
cargo build --release
# copy compiled binary to destination
# the old file will be locked by the already running application, so this sequence is recommended:
sudo -- sh -c 'systemctl stop lemmy && cp target/release/lemmy_server /opt/lemmy/lemmy-server/lemmy_server && systemctl start lemmy'
```

### Lemmy UI

```bash
sudo -u lemmy bash
cd /opt/lemmy/lemmy-ui
git checkout main
git pull --tags
git checkout 0.18.5 # replace with the version you are updating to
git submodule update
yarn install --pure-lockfile
yarn build:prod
exit
sudo systemctl restart lemmy-ui
```

### Pict-rs

If you used the `--features embed-pictrs` flag, pict-rs should update with lemmy_server. Otherwise, refer to [pict-rs documentation](https://git.asonix.dog/asonix/pict-rs) for instructions on upgrading.
