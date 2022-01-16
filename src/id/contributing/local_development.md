# Pengembangan Lokal

### Pasang persyaratan penyusunan
Pasang Rust menggunakan [opsi yang direkomendasikan di rust-lang.org](https://www.rust-lang.org/tools/install) (rustup).

#### Distro berbasis Debian
```
sudo apt install git cargo libssl-dev pkg-config libpq-dev yarn curl gnupg2 espeak
# pasang yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

#### Distro berbasis Arch
```
sudo pacman -S git cargo libssl-dev pkg-config libpq-dev yarn curl gnupg2 espeak
# pasang yarn (stabil)
curl -o- -L https://yarnpkg.com/install.sh | bash
```

#### macOS
Pasang [Homebrew](https://brew.sh/) jika Anda belum memasangnya.

Terakhir, pasang Node dan Yarn.

```
brew install node yarn
```

### Dapatkan kode sumber bagian-belakang
```
git clone https://github.com/LemmyNet/lemmy.git
# atau alternatif dari gitea
# git clone https://yerbamate.ml/LemmyNet/lemmy.git
```

### Susun bagian-belakang (Rust)
```
cargo build
# untuk pengembangan, gunakan `cargo check`
```

### Dapatkan kode sumber antarmuka
```
git clone https://github.com/LemmyNet/lemmy-ui.git --recurse-submodules
```

### Siapkan PostgreSQL
#### Distro berbasis Debian
```
sudo apt install postgresql
sudo systemctl start postgresql

# jalankan db-init.sh, atau inisialisasi basis data postgres secara manual:
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

#### Distro berbasis Arch
```
sudo pacman -S postgresql
sudo systemctl start postgresql

# jalankan db-init.sh, atau inisialisasi basis data postgres secara manual:
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

#### macOS
```
brew install postgresql
brew services start postgresql
/usr/local/opt/postgres/bin/createuser -s postgres

# jalankan db-init.sh, atau inisialisasi basis data postgres secara manual:
psql -c "create user lemmy with password 'password' superuser;" -U postgres
psql -c 'create database lemmy with owner lemmy;' -U postgres
export LEMMY_DATABASE_URL=postgres://lemmy:password@localhost:5432/lemmy
```

### Jalankan sebuah peladen pengembangan lokal
```
cd lemmy
cargo run
```

Kemudian buka [localhost:1235](http://localhost:1235) di peramban Anda. Untuk memuat ulang perubahan bagian-belakang, Anda akan harus menjalankan ulang `cargo run`. Anda bisa menggunakan `cargo check` sebagai jalan cepat untuk menemukan galat penyusunan.

Untuk melakukan pengembangan antarmuka:

```
cd lemmy-ui
yarn
yarn dev
```

dan pergi ke [localhost:1234](http://localhost:1234). Simpanan antarmuka seharusnya menyusun ulang proyek tersebut.

Mohon dicatat bahwa penyiapan ini tidak termasuk pengunggahan gambar. Jika Anda ingin menguji itu, Anda harus menggunakan [pengembangan Docker](docker_development.md).
