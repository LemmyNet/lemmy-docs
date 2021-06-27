# Desarrollo Local

### Instalar requisitos
Instala Rust utilizando [la opción recomendada en rust-lang.org](https://www.rust-lang.org/tools/install) (rustup).

#### Distro basada en Debian
```
sudo apt install git cargo libssl-dev pkg-config libpq-dev yarn curl gnupg2 espeak
# install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

#### Distro basada en Arch
```
sudo pacman -S git cargo libssl-dev pkg-config libpq-dev yarn curl gnupg2 espeak
# install yarn (stable)
curl -o- -L https://yarnpkg.com/install.sh | bash
```

#### macOS
Instala [Homebrew](https://brew.sh/) si aún no lo has instalado.

Finalmente, instala Node y Yarn.

```
brew install node yarn
```

### Obtener el código fuente del back end
```
git clone https://github.com/LemmyNet/lemmy.git
# or alternatively from gitea
# git clone https://yerbamate.ml/LemmyNet/lemmy.git
```

### Compila el backend (Rust)
```
cargo build
# para desarrollo, usa `cargo check` en su lugar)
```

### Obtener el código fuente del front end
```
git clone https://github.com/LemmyNet/lemmy-ui.git --recurse-submodules
```

### Configurar postgresql
#### Distro basada en Debian
```
sudo apt install postgresql
sudo systemctl start postgresql

# Either execute db-init.sh, or manually initialize the postgres database:
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

#### Distro basada en Arch
```
sudo pacman -S postgresql
sudo systemctl start postgresql

# Either execute db-init.sh, or manually initialize the postgres database:
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

#### macOS
```
brew install postgresql
brew services start postgresql
/usr/local/opt/postgres/bin/createuser -s postgres

# Either execute db-init.sh, or manually initialize the postgres database:
psql -c "create user lemmy with password 'password' superuser;" -U postgres
psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

### Ejecutar una instancia de desarrollo local
```
cd lemmy
cargo run
```

Después abre [localhost:1235](http://localhost:1235) en tu navegador. Para recargar los cambios en el back-end, tendrás que volver ejecutar `cargo run`. Puedes usar `cargo check` como una manera mas rapida de econtrar errores de compilación.

Para hacer desarrollo front end:

```
cd lemmy-ui
yarn
yarn dev
```

Enseguida entra a [localhost:1234](http://localhost:1234). Al guardar cambios, el frond end se debe recargar automáticamenete. 

Toma en cuenta que esta configuración no incluye la carga de imagenes ni la previsualización de enlaces (proporcionada por pict-rs y iframely respectivamente). Si quieres probarlos, debes de usar el [desarrollo Docker](docker_development.md).
