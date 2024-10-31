# Local Development

### Install build requirements

Install the latest Rust version using [rustup](https://www.rust-lang.org/tools/install).

Debian-based distro:

```bash
sudo apt install git cargo pkg-config libpq-dev curl
```

Arch-based distro:

```bash
sudo pacman -S git cargo pkg-config postgresql-libs curl
```

Fedora-based distro:

```bash
sudo dnf install git cargo pkg-config libpq-devel curl postgresql-server postgresql-contrib
```

macOS:

Install [Homebrew](https://brew.sh/) if you don't already have it installed. Then install Node and pnpm.

```bash
brew install node
```

### Install pnpm

The install instructions are [here](https://pnpm.io/installation), or you can run

```bash
npm install -g pnpm
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

After making changes, you need to format the code with `cargo +nightly fmt --all` and run the linter with `./scripts/lint.sh`.

### Frontend development

Install dependencies by running `pnpm i`. Then run `pnpm dev` to launch lemmy-ui locally. It automatically connects to the Lemmy backend on `localhost:8536`. Open [localhost:1234](http://localhost:1234) in your browser. The project is rebuilt automatically when you change any files.

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

Then run the following script:

```bash
cd api_tests
./run-federation-test.sh
```
