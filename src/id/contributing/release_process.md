# Pencabangan dan Rilis

## Cabang

Secara umum, pengelolaan kami terhadap cabang seperti yang dijelaskan pada [A stable mainline branching model for Git (Model Pencabangan Jalur Utama yang Stabil untuk Git)](https://www.bitsnbites.eu/a-stable-mainline-branching-model-for-git/). Satu perbedaan adalah kami menghidari rebase dan gantinya gabung (merge) cabang dasar ke cabang aktif saat itu. Ini membantu menghindari dorong-paksa (force push) dan konflik.

## Rilis

- Untuk rilis besar: buat sebuah cabang baru `release/v0.x`
- Untuk rilis kecil: cherry-pick perubahan yang dinginkan ke cabang `release/v0.x`
- Buat sebuah beta atau versi kandidat rilis menggunakan `docker/prod/deploy.sh`
- Lakukan yang sama untuk `lemmy-ui`: `./deploy.sh 0.x.0-rc-x`
- Terapkan ke peladen uji federasi
  - Menjaga satu peladen pada versi stabil terbaru untuk menguji kompatibilitas federasi (otomatisasi ini dengan Ansible)
  - `ansible-playbook -i federation playbooks/site.yml --vault-password-file vault_pass -e rc_version=0.x.0-rc.x`
- Uji coba bahwa seluruhnya bekerja sesuai yang diharapkan, buat rilis beta/rc baru jika dibutuhkan
- Terapkan ke lemmy.ml, untuk menemukan masalah yang tersisa
- Jika itu berjalan baik, buat rilis `0.x.0` yang resmi dengan `docker/prod/deploy.sh`
- Mengumumkan rilis di Lemmy, Matrix, Mastodon
