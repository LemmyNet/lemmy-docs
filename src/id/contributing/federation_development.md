# Pengembangan Federasi

## Menjalankan secara lokal

Pasang dependensi yang dijelaskan di [pengembangan Docker](docker_development.md). Kemudian, jalankan berikut 

```bash
cd docker/federation
./start-local-instances.bash
```

Pengujian federasi membangun lima peladen: 

Peladen | Nama Pengguna | Lokasi | Catatan
--- | --- | --- | ---
lemmy-alpha | lemmy_alpha | [127.0.0.1:8540](http://127.0.0.1:8540) | terfederasi dengan seluruh peladen lainnya
lemmy-beta | lemmy_beta | [127.0.0.1:8550](http://127.0.0.1:8550) | terfederasi dengan seluruh peladen lainnya
lemmy-gamma | lemmy_gamma | [127.0.0.1:8560](http://127.0.0.1:8560) | terfederasi dengan seluruh peladen lainnya
lemmy-delta | lemmy_delta | [127.0.0.1:8570](http://127.0.0.1:8570) | hanya memperbolehkan federasi dengan lemmy-beta
lemmy-epsilon | lemmy_epsilon | [127.0.0.1:8580](http://127.0.0.1:8580) | menggunakan daftar-hitam, memblokir lemmy-alpha

Anda bisa masuk ke setiap itu dengan nama peladen dan `lemmy` sebagai kata sandinya, misal (`lemmy_alpha`, `lemmy`). 

Untuk memulai federasi antar peladen, kunjungi salah satu dari itu dan cari satu pengguna, komunitas, atau pos, seperti ini. Mohon dicatat bahwa bagian-belakang Lemmy berjalan di port yang berbeda dari antarmuka, jadi Anda harus menambahkan angka port di bilah URL dengan satu.
- `!main@lemmy-alpha:8541`
- `http://lemmy-beta:8551/post/3`
- `@lemmy-gamma@lemmy-gamma:8561`

Kontainer Firefox merupakan cara terbaik untuk menguji interaksi mereka.

## Jalankan di sebuah peladen

**Gunakan hanya untuk pengujian**, tidak di peladen aktif, dan ketahuilah bahwa mengaktifkan federasi dapat merusak peladen Anda.

Ikuti instruksi pemasangan normal, entah menggunakan [Ansible](../administration/install_ansible.md) atau [secara manual](../administration/install_docker.md). Kemudian, ganti baris `image: dessalines/lemmy:v0.x.x` di `/lemmy/docker-compose.yml` dengan `image: dessalines/lemmy:federation`. Tambah dan konfigurasi [blok federasi ini](https://github.com/lemmynet/lemmy/blob/main/config/config.hjson#L64) ke `lemmy.hjson` Anda.

Setelah itu, dan kapan pun yang Anda inginkan untuk memperbarui ke versi terbaru, jalankan perintah ini di peladen: 

```
cd /lemmy/
sudo docker-compose pull
sudo docker-compose up -d
```

## Model Keamanan

- Verifikasi tanda digital HTTP : Ini menjamin bahwa aktifitas memang datang dari aktifitas yang diklaim
- check_is_apub_valid : Memastikan bahwa itu ada di daftar peladen yang diperbolehkan
- Pemeriksaan tingkat rendah : Untuk memastikan bahwa pengguna bisa membuat/memperbarui/menghapus pos di peladen yang sama dengan pos tersebut

Untuk poin terakhir, harap dicatat bahwa kita *tidak* memeriksa apakah aktor yang mengirimkan aktifitas membuat sebuah pos sebenarnya sama dengan pembuat pos, atau pengguna yang menghapus pos merupakan moderator/admin. Hal tersebut diperiksa oleh kode API, dan merupakan tanggung jawab setiap peladen untuk memeriksa izin pengguna. Ini tidak meninggalkan vektor serangan apa pun, karena sebagai pengguna peladen normal tidak bisa melakukan aksi yang melanggar peraturan API. Satu-satunya yang bisa melakukannya adalah admin (dan perangkat lunak yang digunakan oleh admin). Tapi admin bisa melakukan apa pun di peladen, termasuk mengirim aktifitas dari akun pengguna lainnya. Jadi kita tidak akan mendapatkan keamanan apa pun dengan memeriksa izin mod dan serupa.
