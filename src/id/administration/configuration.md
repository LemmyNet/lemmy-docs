# Konfigurasi

Konfigurasi didasarkan pada berkas config.hjson, yang di mana ditempatkan secara baku di `config/config.hjson`. Untuk mengubah lokasi baku, Anda bisa mengatur variabel lingkungan `LEMMY_CONFIG_LOCATION`.

Variabel lingkungan tambahan `LEMMY_DATABASE_URL` juga tersedia, yang bisa digunakan dengan string koneksi PostgreSQL seperti `postgres://lemmy:password@lemmy_db:5432/lemmy`, meneruskan semua detail koneksi sekaligus.

Jika kontainer Docker tidak digunakan, buat basis data yang disebutkan di atas secara manual dengan menjalankan perintah berikut:

```bash
cd server
./db-init.sh
```

**Federasi tidak diatur secara baku.** Anda bisa menambahkan [blok federasi ini](https://github.com/lemmynet/lemmy/blob/main/config/config.hjson#L64) ke `lemmy.hjson` Anda dan minta peladen lain untuk menambahkan Anda ke daftar yang diperbolehkan mereka.

## Semua konfigurasi dengan nilai baku

```hjson
{{#include ../../../include/config/defaults.hjson}}
```
