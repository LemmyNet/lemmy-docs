# Dari Awal

> ⚠️ **Peringatan:** metode pemasangan ini tidak direkomendasikan oleh pengembang Lemmy. Jika Anda ada masalah, Anda harus menyelesaikannya sendiri atau tanya pembuat terkait. Jika Anda melihat ada galat di peladen yang dipasang menggunakan metode ini, harap sebutkan di laporan galat.

Instruksi ini ditulis untuk Ubuntu 20.04.

## Pemasangan

### Bagian-Belakang Lemmy

Karena dibuat dari sumber, jadi mungkin akan memakan waktu yang lama, terutama pada perangkat yang lambat. Contohnya, Lemmy v0.12.2 membutuhkan 17 menit untuk dibangun pada VPS inti ganda. Jika Anda lebih suka binari sudah siap, gunakan Docker.

Susun dan pasang Lemmy, siapkan basis data:

```bash
apt install pkg-config libssl-dev libpq-dev cargo postgresql
# pasang rilis terbaru, anda juga bisa menspesifikkannya dengan --version
# argumen --locked menggunakan versi dependensi yang sama dengan yang dispesifikkan di
# `cargo.lock` saat waktu perilisan. menjalankannya tanpa bendera akan menggunakan versi
# rilis minor dari dependensi tersebut, yang tidak selalu terjamin akan tersusun.
cargo install lemmy_server --target-dir /usr/bin/ --locked
# ganti db-passwd dengan kata sandi yang dibuat acak
sudo -iu postgres psql -c "CREATE USER lemmy WITH PASSWORD 'db-passwd';"
sudo -iu postgres psql -c "CREATE DATABASE lemmy WITH OWNER lemmy;"
adduser lemmy --system --disabled-login --no-create-home --group
```

Konfigurasi minimal Lemmy, taruh ini di `/etc/lemmy/lemmy.hjson` (lihat di [sini](https://github.com/LemmyNet/lemmy/blob/main/config/config.hjson) untuk pilihan konfigurasi lebih banyak). Jalankan `chown lemmy:lemmy /etc/lemmy/ -R` untuk mengatur pemilik yang benar.

```hjson
{
  database: {
    # taruh db-passwd anda dari atas
    password: "db-passwd"
  }
  # ganti dengan domain anda
  hostname: example.com
  bind: "127.0.0.1"
  # taruh kata acak di sini (diperlukan untuk enkripsi token masuk)
  jwt_secret: "changeme"
}
```

Berkas unit systemd, sehingga Lemmy bisa secara otomatis dimulai dan diberhentikan, log dikelola lewat journalctl dll. Taruh berkas ini ke /etc/systemd/system/lemmy.service, kemudian jalankan `systemctl enable lemmy` dan `systemctl start lemmy`.

```
[Unit]
Description=Lemmy - A link aggregator for the fediverse
After=network.target

[Service]
User=lemmy
ExecStart=/usr/bin/lemmy_server
Environment=LEMMY_CONFIG_LOCATION=/etc/lemmy/lemmy.hjson
Restart=on-failure

# penguatan
ProtectSystem=yes
PrivateTmp=true
MemoryDenyWriteExecute=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

Jika Anda melakukan semuanya dengan benar, log Lemmy dari `journalctl -u lemmy` akan menampilkan "Starting http server at 127.0.0.1:8536". Anda juga bisa menjalankan `curl localhost:8536/api/v3/site` yang seharusnya mengembalikan respons yang berhasil , seperti `{"site_view":null,"admins":[],"banned":[],"online":0,"version":"unknown version","my_user":null,"federated_instances":null}`.

### Pasang lemmy-ui (antarmuka web)

Pasang dependensi (nodejs dan yarn di repositori Ubuntu 20.04 terlalu tua)

```bash
# https://classic.yarnpkg.com/en/docs/install/#debian-stable
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
# https://github.com/nodesource/distributions/blob/master/README.md#installation-instructions
curl -fsSL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt install nodejs yarn
```

Klon repositori git, checkout versi yang Anda inginkan (dalam contoh ini adalah 0.12.2) dan susun itu.

```bash
mkdir /var/lib/lemmy-ui
cd /var/lib/lemmy-ui
chown lemmy:lemmy .
# jangan susun sebagai admin
sudo -u lemmy bash
git clone https://github.com/LemmyNet/lemmy-ui.git --recursive .
git checkout 0.12.2 # ganti dengan versi yang ingin anda pasang
yarn install --pure-lockfile
yarn build:prod
exit
```

Tambahkan berkas unit systemd yang lain, kali ini untuk lemmy-ui. Anda perlu mengganti example.com dengan domain Anda. Taruh berkas di `/etc/systemd/system/lemmy-ui.service`, kemudian jalankan `systemctl enable lemmy-ui` dan `systemctl start lemmy-ui`.

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

Jika semuanya benar, perintah `curl -I localhost:1234` seharusnya menampilkan `200 OK` di bagian atas.

### Mengonfigurasi proksi-balik dan TLS

Pasang dependensi

```bash
apt install nginx certbot python3-certbot-nginx
```

Minta sertifikat TLS Let's Encrypt (ikuti saja instruksinya)

```bash
certbot certonly --nginx
```

Sertifikat Let's Encrypt akan diperbarui secara otomatis, jadi tambahkan baris di bawah ini ke crontab Anda, dengan menjalankan `sudo crontab -e`. Ganti example.com dengan domain Anda.

```
@daily certbot certonly --nginx --cert-name example.com -d example.com --deploy-hook 'nginx -s reload'
```

Akhirnya, tambahkan konfigurasi nginx. Setelah mengunduh, Anda perlu mengubah beberapa variabel di berkas.

```bash
curl https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx.conf \
    --output /etc/nginx/sites-enabled/lemmy.conf
# taruh domain anda alih-alih example.com
sed -i -e 's/{{domain}}/example.com/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_port}}/8536/g' /etc/nginx/sites-enabled/lemmy.conf
sed -i -e 's/{{lemmy_ui_port}}/1234/g' /etc/nginx/sites-enabled/lemmy.conf
nginx -s reload
```

Sekarang buka domain Lemmy Anda di peramban, dan itu seharusnya menampilkan sebuah layar konfigurasi. Gunakan untuk membuat pengguna admin pertama dan komunitas baku.

### Pict-rs (untuk hos gambar, opsional)

Pict-rs memerlukan Rust versi yang lebih baru dari yang tersedia di repositori Ubuntu 20.04. Jadi Anda perlu memasang [Rustup](https://rustup.rs/) yang akan memasang toolchain untuk Anda.

```bash
apt install ffmpeg exiftool libgexiv2-dev --no-install-recommends
adduser pictrs --system --disabled-login --no-create-home --group
mkdir /var/lib/pictrs-source
cd /var/lib/pictrs
git clone https://git.asonix.dog/asonix/pict-rs.git .
# periksa docker-compose.yml untuk versi pict-rs yang digunakan oleh lemmy
# https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/docker-compose.yml#L40
git checkout v0.2.6-r2
# atau tinggal tambahkan folder bin ke $PATH anda
$HOME/.cargo/bin/cargo build --release
cp target/release/pict-rs /usr/bin/
# buat folder untuk menyimpan data gambar
mkdir /var/lib/pictrs
chown pictrs:pictrs /var/lib/pictrs
```

Pict-rs memerlukan perintah `magick` yang ada di ImageMagick versi 7, tapi Ubuntu 20.04 hanya ada ImageMagick 6. Jadi Anda harus memasangnya secara manual, seperti lewat [situs web resmi](https://imagemagick.org/script/download.php#linux).

```
wget https://download.imagemagick.org/ImageMagick/download/binaries/magick
# bandingkan hash dengan "message digest" di halaman resmi yang ditautkan di atas
sha256sum magick
mv magick /usr/bin/
chmod 755 /usr/bin/magick
```

Seperti sebelumnya, letakkan konfigurasi di bawah ini ke `/etc/systemd/system/pictrs.service`, kemudian jalankan `systemctl enable pictrs` dan `systemctl start pictrs`.

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

Jika berjalan dengan benar, `curl 127.0.0.1:8080` seharusnya tidak menampilkan apa-apa (terutama tidak ada galat).

Sekarang tambahkan baris `pictrs_url: "http://127.0.0.1:8080"` ke `/etc/lemmy/lemmy.hjson` sehingga Lemmy mengetahui bagaimana menjangkau Pict-rs. Kemudian mulai ulang Lemmy dengan `systemctl restart lemmy` dan pengunggahan gambar seharusnya bisa bekerja.

## Meningkatkan/Memperbarui

### Lemmy

```bash
# pasang rilis terbaru, anda juga bisa menspesifikkannya dengan --version
cargo install lemmy_server --target-dir /usr/bin/
systemctl restart lemmy
```

### Lemmy UI

```bash
cd /var/lib/lemmy-ui
sudo -u lemmy
git checkout main
git pull --tags
git checkout 0.12.2 # ganti dengan versi yang ingin anda pasang
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
# periksa docker-compose.yml untuk versi pict-rs yang digunakan oleh lemmy
# https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/docker-compose.yml#L40
git checkout v0.2.6-r2
# atau tinggal tambahkan folder bin ke $PATH anda
$HOME/.cargo/bin/cargo build --release
cp target/release/pict-rs /usr/bin/
systemctl restart pictrs
```
