# From Scratch 

> ⚠️ **Disclaimer:** this installation method is not recommended by the Lemmy developers. If you have any problems, you need to solve them yourself or ask the respective authors. If you notice any Lemmy bugs on an instance installed like this, please mention it in the bug report.

These instructions are written for Ubuntu 20.04.

## Installation

### Lemmy Backend

It is built from source, so this may take a while, especially on slow devices. For example, Lemmy v0.12.2 takes 17 minutes to build on a dual core VPS. If you prefer prebuilt binaries, use Docker.

Compile and install Lemmy, setup database:
```bash
apt install pkg-config libssl-dev libpq-dev cargo postgresql
# installs latest release, you can also specify one with --version
cargo install lemmy_server --target-dir /usr/bin/
# replace db-passwd with a randomly generated password
sudo -iu postgres psql -c "CREATE USER lemmy WITH PASSWORD 'db-passwd';"
sudo -iu postgres psql -c "CREATE DATABASE lemmy WITH OWNER lemmy;"
adduser lemmy --system --disabled-login --no-create-home --group
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
  # put a random string here (required for login token encryption)
  jwt_secret: "changeme"
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
Restart=on-failure

# Hardening
ProtectSystem=yes
PrivateTmp=true
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

If you did everything right, the Lemmy logs from `journalctl -u lemmy` should show "Starting http server at 127.0.0.1:8536". You can also run `curl localhost:8536/api/v3/site` which should give a successful response, looking like `{"site_view":null,"admins":[],"banned":[],"online":0,"version":"unknown version","my_user":null,"federated_instances":null}`.

### Install lemmy-ui (web frontend)

Install dependencies (nodejs and yarn in Ubuntu 20.04 repos are too old)
```bash
# https://classic.yarnpkg.com/en/docs/install/#debian-stable
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs yarn
```

Clone the git repo, checkout the version you want (0.12.2 in this case), and compile it.
```bash
mkdir /var/lib/lemmy-ui
cd /var/lib/lemmy-ui
chown lemmy:lemmy .
# dont compile as admin
sudo -u lemmy bash
git clone https://github.com/LemmyNet/lemmy-ui.git --recursive .
git checkout 0.12.2 # replace with the version you want to install
yarn install --pure-lockfile
yarn build:prod
exit
```

Add another systemd unit file, this time for lemmy-ui. You need to replace example.com with your actual domain. Put the file in `/etc/systemd/system/lemmy-ui.service`, then run `systemctl enable lemmy-ui` and `systemctl start lemmy-ui`.
```
[Unit]
Description=Lemmy UI - Web frontend for Lemmy
After=lemmy.service
Before=nginx.service

[Service]
User=lemmy
WorkingDirectory=/var/lib/lemmy-ui
ExecStart=/usr/bin/node dist/js/server.js
Environment=LEMMY_INTERNAL_HOST=localhost:8536
Environment=LEMMY_EXTERNAL_HOST=example.com
Environment=LEMMY_HTTPS=true
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

### Pict-rs (for image hosting, optional)

Pict-rs requires a newer Rust version than the one available in Ubuntu 20.04 repos. So you need to install [Rustup](https://rustup.rs/) which installs the toolchain for you.

```bash
apt install ffmpeg exiftool libgexiv2-dev --no-install-recommends
adduser pictrs --system --disabled-login --no-create-home --group
mkdir /var/lib/pictrs-source
cd /var/lib/pictrs
git clone https://git.asonix.dog/asonix/pict-rs.git .
# check docker-compose.yml for pict-rs version used by lemmy
# https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/docker-compose.yml#L40 
git checkout v0.2.6-r2
# or simply add the bin folder to your $PATH
$HOME/.cargo/bin/cargo build --release
cp target/release/pict-rs /usr/bin/
# create folder to store image data
mkdir /var/lib/pictrs
chown pictrs:pictrs /var/lib/pictrs
```

Pict-rs requires the `magick` command which comes with Imagemagick version 7, but Ubuntu 20.04 only comes with Imagemagick 6. So you need to install that command manually, eg from the [official website](https://imagemagick.org/script/download.php#linux).
```
wget https://download.imagemagick.org/ImageMagick/download/binaries/magick
# compare hash with the "message digest" on the official page linked above
sha256sum magick
mv magick /usr/bin/
chmod 755 /usr/bin/magick
```

Just like before, place the config below in `/etc/systemd/system/pictrs.service`, then run `systemctl enable pictrs` and `systemctl start pictrs`.
```
[Unit]
Description=pict-rs - A simple image host
After=network.target

[Service]
User=pictrs
ExecStart=/usr/bin/pict-rs
Environment=PICTRS_PATH=/var/lib/pictrs
Environment=PICTRS_ADDR=127.0.0.1:8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

If it is working correctly, `curl 127.0.0.1:8080` should output nothing (particularly no errors).

Now add the line `pictrs_url: "http://127.0.0.1:8080"` to `/etc/lemmy/lemmy.hjson` so that Lemmy knows how to reach Pict-rs. Then restart Lemmy with `systemctl restart lemmy`, and image uploads should be working.

## Upgrading

### Lemmy

```bash
# installs latest release, you can also specify one with --version
cargo install lemmy_server --target-dir /usr/bin/
systemctl restart lemmy
```

### Lemmy UI

```bash
cd /var/lib/lemmy-ui
sudo -u lemmy
git checkout main
git pull --tags
git checkout 0.12.2 # replace with the version you want to install
git submodule update
yarn install --pure-lockfile
yarn build:prod
exit
systemctl restart lemmy-ui
```

### Pict-rs

```bash
rustup update
cd /var/lib/pictrs-source
git checkout main
git pull --tags
# check docker-compose.yml for pict-rs version used by lemmy
# https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/docker-compose.yml#L40 
git checkout v0.2.6-r2
# or simply add the bin folder to your $PATH
$HOME/.cargo/bin/cargo build --release
cp target/release/pict-rs /usr/bin/
systemctl restart pictrs
```
