# Pemasangan Menggunakan Docker

Pastikan Anda sudah punya docker dan docker-compose(>=`1.24.0`) terpasang. Di Ubuntu, tinggal jalankan `apt install docker-compose docker.io`. Kemudian,

```bash
# buat sebuah folder untuk berkas lemmy. lokasinya tidak penting, bisa ditaruh dimana saja
mkdir /lemmy
cd /lemmy

# unduh berkas konfigurasi baku
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/lemmy.hjson

# atur izin yang benar untuk folder pictrs
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

Buka `docker-compose.yml` Anda dan pastikan `LEMMY_EXTERNAL_HOST` untuk `lemmy-ui` diatur ke hos yang benar Anda.

```
- LEMMY_INTERNAL_HOST=lemmy:8536
- LEMMY_EXTERNAL_HOST=your-domain.com
- LEMMY_HTTPS=false
```

Jika Anda ingin kata sandi basis data yang berbeda, Anda harus menggantinya juga di `docker-compose.yml` **sebelum** pemulaian pertama Anda.

Setelah ini, coba lihat ke [berkas konfigurasi](configuration.md) bernama `lemmy.hjson` dan coba sesuaikan, khususnya nama hos dan mungkin kata sandi basis data. Kemudian jalankan: 

`docker-compose up -d`

Anda bisa mengakses lemmy-ui di `http://localhost:1235`

Untuk membuat Lemmy tersedia di luar peladen, Anda perlu mengatur proksi balik, seperti Nginx. [Contoh konfigurasi nginx](https://github.com/LemmyNet/lemmy-ansible/blob/main/templates/nginx.conf), dapat disiapkan dengan:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy-ansible/main/templates/nginx.conf
# ganti dengan {{ vars }}
# lemmy_port baku adalah 8536
# lemmy_ui_port baku adalah 1235
sudo mv nginx.conf /etc/nginx/sites-enabled/lemmy.conf
```

Anda juga harus menyiapkan TLS, seperti [Let's Encrypt](https://letsencrypt.org/). Setelah ini, Anda harus memulai ulang Nginx untuk memuat ulang konfigurasi.

## Memperbarui

Untuk memperbarui ke versi terbaru, Anda bisa secara manual mengganti versi di `docker-compose.yml`. Atau, ambil versi terbaru dari repositori git kami:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
docker-compose up -d
```
