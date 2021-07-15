# From Scratch 

> ⚠️ **Disclaimer:** this installation method is not recommended by the Lemmy developers. If you have any problems, you need to solve them yourself or ask the respective authors. If you notice any Lemmy bugs on an instance installed like this, please mention it in the bug report.

## Installing Lemmy from source code

Instructions for installing Lemmy natively, without relyng on Docker. Originally posted on [Some resources on setting Lemmy up from source - Lemmy dot C.A.](https://lemmy.ca/post/1066) **The current transcription has been adapted to improve readability**.

### Important

> Software package references below are all Gentoo-based - there's information in the docker files about what's required on debian-like systems, and for anything else you'll probably be able to easily adjust as necessary.

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
| app-shells                   | bash-completion                           |


### Get postgresql service up & running

```bash
emerge --config dev-db/postgresql
rc-service postgresql-12 start
useradd -m -s /bin/bash lemmy
cd ~lemmy
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy.git
cd lemmy
```

### List the tags/releases available

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.11.0
```

### Build prod?  (Remove --release for dev)

```bash
sudo -Hu lemmy cargo build --release
cd ..
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy-ui.git
cd lemmy-ui
```

### List the tags/releases available

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.8.10
sudo -Hu lemmy git submodule init
sudo -Hu lemmy git submodule update --remote
```

### Build the frontend

#### This is for dev

```bash
sudo -Hu lemmy yarn
```

#### This is for prod

```bash
sudo -Hu lemmy yarn install --pure-lockfile
sudo -Hu lemmy yarn build:prod
```

**And this is just to run a dev env, but I think we'll prefer prod - use the init script**

```bash
sudo -Hu lemmy yarn dev
```

For prod, we'll use the [init script](#initlemmy), but the prod commandline is:

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

```bash
sudo -Hu iframely cp ~lemmy/lemmy/docker/iframely.config.local.js ~lemmy/iframely/config.local.js
```

Start the iframely server OR, use an [init script](#initiframely) instead, which is better than running this manually

```bash
sudo -Hu iframely node server
```

### pict-rs install

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

But we'll just use the init script. 

At this point, fire everything up via the [init scripts](#init-scripts), should all go. Setup the init scripts to run at boot time. Presumably you've setup nginx and you can reach your instance.

---

## Updating

```bash
su - lemmy
cd lemmy
```

BACKUP [config/config.hjson](#configuration) somewhere

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

## Index

### configuration

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

