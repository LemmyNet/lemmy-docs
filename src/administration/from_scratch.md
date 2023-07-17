# From Scratch

These instructions are written for Ubuntu 20.04 / Ubuntu 22.04.

## Installation

### Lemmy Backend

It is built from source, so this may take a while, especially on slow devices. For example, Lemmy v0.12.2 takes 17 minutes to build on a dual core VPS. If you prefer prebuilt binaries, use Docker or Ansible install methods.

For the Rust compiles, it is ideal to use a non-privledged Linux account on your system.

Install Rust by following the instructions on [Rustup](https://rustup.rs/) (using a non-privledged Linux account, it will install file in that user's home folder for rustup and cargo).

Lemmy supports image hosting using [pict-rs](https://git.asonix.dog/asonix/pict-rs/). We need to install a couple of dependencies for this. You can also skip these steps if you don't require image hosting. **NOTE: Lemmy-ui will still allow users to attempt uploading images even if pict-rs is not configured, in this situation, the upload will fail and users will receive technical error messages.**

Depending on preference, pict-rs can be installed as a standalone application, or it can be embedded within Lemmy itself (see below). In both cases, pict-rs requires the `magick` command which comes with Imagemagick version 7, but Ubuntu 20.04 only comes with Imagemagick 6. So you need to install that command manually, eg from the [official website](https://imagemagick.org/script/download.php#linux).

```bash
sudo apt install ffmpeg exiftool libgexiv2-dev --no-install-recommends
# save the file to a working folder it can be verified before copying to /usr/bin/
wget https://download.imagemagick.org/ImageMagick/download/binaries/magick
# compare hash with the "message digest" on the official page linked above
sha256sum magick
sudo mv magick /usr/bin/
sudo chmod 755 /usr/bin/magick
```

Install dependencies and setup database:

```bash
sudo apt install pkg-config libssl-dev libpq-dev postgresql

# replace db-passwd with a unique password of your choice
sudo -iu postgres psql -c "CREATE USER lemmy WITH PASSWORD 'db-passwd';"
sudo -iu postgres psql -c "CREATE DATABASE lemmy WITH OWNER lemmy;"
# NOTE: this may be required by migration, depending on version of Lemmy
#   sudo -iu postgres psql -c "ALTER USER lemmy WITH SUPERUSER;"
# create user account on Linux for the lemmy_server application
sudo adduser lemmy --system --disabled-login --no-create-home --group
```

Tune your PostgreSQL settings to match your hardware via https://pgtune.leopard.in.ua/#/

Compile and install Lemmy, given the from-scratch intention, this will be done via GitHub checkout. This can be done by a norm unprivledged user (using the same Linux account you used for rustup). 

```bash
# protobuf-compiler may be required for Ubuntu 22.04.2 installs, please report testing in lemmy-docs issues
sudo apt install protobuf-compiler
git clone https://github.com/LemmyNet/lemmy.git lemmy
cd lemmy
git checkout 0.18.2
git submodule init
git submodule update --recursive --remote
echo "pub const VERSION: &str = \"$(git describe --tag)\";" > "crates/utils/src/version.rs"
# These instructions assume you build pictrs independent, but it is
# OPTIONAL on next command: --features embed-pictrs
cargo build --release
# copy compiled binary to destination
sudo cp target/release/lemmy_server /usr/bin/lemmy_server
```

Note:

- Lemmy currently only supports non-SSL connections to databases. More info [here](https://github.com/LemmyNet/lemmy/issues/3007).
- Your postgres config might need to be edited to allow password authentication instead of peer authentication. Simply add:
  ```
  local   lemmy           lemmy                                   md5
  # Add the line above.
  # Do not add the line below, it should already exist in your pg_hba.conf in some form.
  local   all             all                                     peer
  ```

Minimal Lemmy config, put this in `/etc/lemmy/lemmy.hjson` (see [here](https://github.com/LemmyNet/lemmy/blob/main/config/config.hjson) for more config options). Run `chown lemmy:lemmy /etc/lemmy/ -R` to set the correct owner.

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

Systemd unit file, so that Lemmy automatically starts and stops, logs are handled via journalctl etc. Put this file into /etc/systemd/system/lemmy.service, then run `systemctl enable lemmy` and `systemctl start lemmy`.

```
[Unit]
Description=Lemmy - A link aggregator for the fediverse
After=network.target

[Service]
User=lemmy
ExecStart=/usr/bin/lemmy_server
Environment=LEMMY_CONFIG_LOCATION=/etc/lemmy/lemmy.hjson
# remove these two lines if you don't need pict-rs
Environment=PICTRS_PATH=/var/lib/pictrs
Environment=PICTRS_ADDR=127.0.0.1:8080
Environment=RUST_LOG=info
Restart=on-failure

# Hardening
ProtectSystem=yes
PrivateTmp=true
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

If you did everything right, the Lemmy logs from `journalctl -u lemmy` should show "Starting http server at 127.0.0.1:8536". You can also run `curl localhost:8536/api/{version}/site` which should give a successful response, looking like `{"site_view":null,"admins":[],"banned":[],"online":0,"version":"unknown version","my_user":null,"federated_instances":null}`. For pict-rs, run `curl 127.0.0.1:8080` and ensure that it outputs nothing (particularly no errors).

### Install lemmy-ui (web frontend)

Install dependencies (nodejs and yarn in Ubuntu 20.04 / Ubuntu 22.04 repos are too old)

```bash
# https://classic.yarnpkg.com/en/docs/install/#debian-stable
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs yarn
```

Clone the git repo, checkout the version you want (0.18.2 in this case), and compile it.

```bash
mkdir /var/lib/lemmy-ui
cd /var/lib/lemmy-ui
chown lemmy:lemmy .
# dont compile as admin
sudo -u lemmy bash
git clone https://github.com/LemmyNet/lemmy-ui.git --recursive .
git checkout 0.18.2 # replace with the version you want to install
yarn install --pure-lockfile
yarn build:prod
exit
```

Add another systemd unit file, this time for lemmy-ui. You need to replace example.com with your actual domain. Put the file in `/etc/systemd/system/lemmy-ui.service`, then run `systemctl enable lemmy-ui` and `systemctl start lemmy-ui`. More UI-related variables can be [found here](https://github.com/LemmyNet/lemmy-ui#configuration).

```
[Unit]
Description=Lemmy UI - Web frontend for Lemmy
After=lemmy.service
Before=nginx.service

[Service]
User=lemmy
WorkingDirectory=/var/lib/lemmy-ui
ExecStart=/usr/bin/node dist/js/server.js
Environment=LEMMY_UI_LEMMY_INTERNAL_HOST=localhost:8536
Environment=LEMMY_UI_LEMMY_EXTERNAL_HOST=example.com
Environment=LEMMY_UI_HTTPS=true
Restart=on-failure

# Hardening
ProtectSystem=full
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

If everything went right, the command `curl -I localhost:1234` should show `200 OK` at the top.

### Configure reverse proxy and TLS

Install dependencies

```bash
apt install nginx certbot python3-certbot-nginx
```

Request Let's Encrypt TLS certificate (just follow the instructions)

```bash
certbot certonly --nginx
```

Let's Encrypt certificates should be renewed automatically, so add the line below to your crontab, by running `sudo crontab -e`. Replace example.com with your actual domain.

```
@daily certbot certonly --nginx --cert-name example.com -d example.com --deploy-hook 'nginx -s reload'
```

Finally, add the nginx config. After downloading, you need to replace some variables in the file.

```bash
curl https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx.conf \
    --output /etc/nginx/sites-enabled/lemmy.conf
# put your actual domain instead of example.com
sed -i -e 's/{{domain}}/example.com/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_port}}/8536/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_ui_port}}/1234/g' /etc/nginx/sites-enabled/lemmy.conf
nginx -s reload
```

Now open your Lemmy domain in the browser, and it should show you a configuration screen. Use it to create the first admin user and the default community.

## Upgrading

### Lemmy

Compile and install Lemmy changes. This can be done by a norm unprivledged user (using the same Linux account you used for rustup and first install of Lemmy). 

```bash
cd lemmy
git pull
git checkout 0.18.2 # replace with version you are updating to
git submodule update --recursive --remote
echo "pub const VERSION: &str = \"$(git describe --tag)\";" > "crates/utils/src/version.rs"
# These instructions assume you build pictrs independent, but it is
# OPTIONAL on next command: --features embed-pictrs
cargo build --release
# copy compiled binary to destination
sudo cp target/release/lemmy_server /usr/bin/lemmy_server
```


### Lemmy UI

```bash
cd /var/lib/lemmy-ui
sudo -u lemmy bash
git checkout main
git pull --tags
git checkout 0.18.2 # replace with the version you are updating to
git submodule update
yarn install --pure-lockfile
yarn build:prod
exit
systemctl restart lemmy-ui
```

### Pict-rs

If you did **not** use the `--features embed-pictrs` flag, then this script below is necessary for installing/updating Pict-rs as a standalone server.
Otherwise, pict-rs should update with lemmy_server.

```bash
rustup update
cd /var/lib/pictrs-source
git checkout main
git pull --tags
# check docker-compose.yml for pict-rs version used by lemmy
# https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/docker-compose.yml#L43
git checkout v0.2.6-r2  # replace with the version you want to install
# or simply add the bin folder to your $PATH
$HOME/.cargo/bin/cargo build --release
cp target/release/pict-rs /usr/bin/
systemctl restart pictrs
```
