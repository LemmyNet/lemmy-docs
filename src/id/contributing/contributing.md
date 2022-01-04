# Berkontribusi

Informasi tentang berkontribusi ke Lemmy, entah itu penerjemahan, menguji, pendesainan, atau pemrograman.

## Pelacak Isu/Repositori

- [GitHub (untuk isu dan permintaan dorong (pull request))](https://github.com/LemmyNet/lemmy)
- [Gitea (hanya untuk permintaan dorong)](https://yerbamate.ml/LemmyNet/lemmy)
- [Codeberg](https://codeberg.org/LemmyNet/lemmy)

## Penerjemahan

Periksa [Weblate Lemmy](https://weblate.yerbamate.ml/projects/lemmy/) untuk penerjemahan. Anda bisa juga membantu dengan [menerjemahkan dokumentasi ini](https://github.com/LemmyNet/lemmy-docs#adding-a-new-language).


## Arsitektur

### Antarmuka

- Antarmuka ditulis dengan `Typescript`, menggunakan kerangka mirip-React yang dikenal sebagai [Inferno](https://infernojs.org/). Semua elemen antarmuka merupakan komponen `.tsx` yang dapat digunakan ulang.
- Repositori antarmuka adalah [lemmy-ui](https://github.com/LemmyNet/lemmy-ui).
- Rutenya adalah `src/shared/routes.ts`.
- Komponen berada di `src/shared/components`.

### Bagian-Belakang

- Bagian-belakang dengan `Rust`, menggunakan `Diesel` dan `Actix`.
- Kode peladen dibagi ke bagian utama di `src`. Mereka termasuk: 
  - `db` - Aksi basis data tingkat rendah. 
    - Penambahan basis data dilakukan menggunakan migrasi Diesel. Jalankan `diesel migration generate xxxxx` untuk menambahkan sesuatu yang baru. 
  - `api` - Interaksi pengguna tingkat tinggi (hal seperti `CreateComment`) 
  - `routes` - Endpoint peladen.
  - `apub` - Konversi activitypub.
  - `websocket` - Membuat peladen websocket. 

## Linting / Formatting

- Every front and back end commit is automatically formatted then linted using `husky`, and `lint-staged`.
- Rust with `cargo fmt` and `cargo clippy`.
- Typescript with `prettier` and `eslint`.
