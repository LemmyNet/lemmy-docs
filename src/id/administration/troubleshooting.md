# Penyelesaian Masalah

Berbagai masalah yang bisa terjadi di peladen baru dan bagaimana untuk menyelesaikan mereka.

Banyak fitur Lemmy bergantung pada konfigurasi proksi-balik yang benar. Pastikan yang Anda sama dengan [konfigurasi nginx](https://github.com/LemmyNet/lemmy/blob/main/ansible/templates/nginx.conf) kami.

## Umum

### Log

Untuk masalah antarmuka, periksa [konsol peramban](https://webmasters.stackexchange.com/a/77337) untuk pesan galat apa pun.

Untuk log peladen, jalankan `docker-compose logs -f lemmy` di folder pemasangan Anda. Anda juga bisa menjalankan `docker-compose logs -f lemmy lemmy-ui pictrs` untuk mendapatkan log dari layanan yang berbeda.

Jika itu tidak memberikan informasi yang cukup, coba ubah baris `RUST_LOG=error` di `docker-compose.yml` ke `RUST_LOG=info` atau `RUST_LOG=verbose`, kemudian jalankan `docker-compose restart lemmy`.

### Membuat pengguna admin tidak bekerja

Pastikan bahwa websocket bekerja dengan benar, dengan memeriksa konsol peramban untuk galat. Di nginx, tajuk berikut penting untuk ini:

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Membatasi galat ketika banyak pengguna mengakses situs

Periksa bahwa tajuk `X-Real-IP` dan `X-Forwarded-For` dikirim ke Lemmy oleh proksi-balik. Kalau tidak, itu akan menghitung semua tindakan terhadap batas dari proksi-balik IP. Di nginx, itu seharusnya tertampil sebagai:

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Federasi

### Peladen lain tidak bisa mengambil konten lokal (komunitas, pos, dll.)

Proksi-balik Anda (mis. nginx) perlu meneruskan permintaan dengan tajuk `Accept: application/activity+json` ke bagian-belakang. Itu ditangani oleh baris berikut:
```
set $proxpass "http://0.0.0.0:{{ lemmy_ui_port }}";
if ($http_accept = "application/activity+json") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
proxy_pass $proxpass;
```

Anda bisa memeriksa bahwa itu bekerja dengan benar dengan menjalankan perintah berikut, semuanya seharusnya mengembalikan JSON yang valid:
```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # id dari sebuah pos lokal
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # id dari sebuah komentar lokal
```
### Mengambil konten jarak jauh bekerja, tapi mengepos/berkomentar di komunitas jarak jauh gagal

Periksa bahwa [federasi dibolehkan pada kedua belah peladen](../federation/administration.md#instance-allowlist-and-blocklist).

Juga pastikan bahwa waktu di peladen Anda sudah akurat. Aktifitas ditandai dengan waktu dan akan dihapus jika meleset lebih dari 10 detik.
