## Local Development

### Install build requirements

Install the latest Rust version using [rustup](https://www.rust-lang.org/tools/install).

Debian-based distro:

```bash
sudo apt install git cargo libssl-dev pkg-config libpq-dev curl
# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

NOTE: you may find it is useful to reference the - [Install from Scratch](../administration/from_scratch.md)
steps for Debian/Ubuntu, as production servers are assumed to be same.

Arch-based distro:

```bash
sudo pacman -S git cargo openssl pkg-config postgresql-libs curl yarn
```

macOS:

Install [Homebrew](https://brew.sh/) if you don't already have it installed. Then install Node and Yarn.

```bash
brew install node yarn
```

### Setup PostgreSQL database

Debian-based distro:

```bash
sudo apt install postgresql
sudo systemctl start postgresql
```

Arch-based distro:

```bash
sudo pacman -S postgresql
sudo systemctl start postgresql
# If the systemctl command errors, then run the following
sudo mkdir /var/lib/postgres/data
sudo chown postgres:postgres /var/lib/postgres/data
sudo -u postgres initdb -D /var/lib/postgres/data
sudo systemctl start postgresql
```

macOS:

```bash
brew install postgresql
brew services start postgresql
$(brew --prefix postgresql)/bin/createuser -s postgres
```

Either execute `scripts/db-init.sh`, or manually initialize the postgres database:

```bash
psql -c "create user lemmy with password 'password' superuser;" -U postgres
psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

### Get the code

Clone frontend and backend code to local folders. Be sure to include `--recursive` to initialize git submodules.

```bash
git clone https://github.com/LemmyNet/lemmy.git --recursive
git clone https://github.com/LemmyNet/lemmy-ui.git --recursive
```

### Backend development

Use `cargo check` to find compilation errors. To start the Lemmy backend, run `cargo run`. It will bind to `0.0.0.0:8536`.

After making changes, you need to format the code with `cargo +nightly fmt --all` and run the linter with `./scripts/fix-clippy.sh`.

### Frontend development

Install dependencies by running `yarn`. Then run `yarn dev` to launch lemmy-ui locally. It automatically connects to the Lemmy backend on `localhost:8536`. Open [localhost:1234](http://localhost:1234) in your browser. The project is rebuilt automatically when you change any files.

Note that this setup doesn't support image uploads. If you want to test those, you need to use the
[Docker development](03-docker-development.md).

### Tests

Run Rust unit tests:

```bash
./scripts/test.sh
```

To run federation/API tests, first add the following lines to `/etc/hosts`:

```
127.0.0.1       lemmy-alpha
127.0.0.1       lemmy-beta
127.0.0.1       lemmy-gamma
127.0.0.1       lemmy-delta
127.0.0.1       lemmy-epsilon
```

You will need to hand-edit the api_tests/run-federation-test.sh script file, add your PostgreSQL lemmy password. Note, the LEMMY_DATABASE_URL environment variable inside that script file is not in the same format as normally required, the "/lemmy" database is not on the URL. Then run the following script:

```bash
cd api_tests
./run-federation-test.sh
```
