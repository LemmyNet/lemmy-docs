# Panduan Membuat Tema

Lemmy menggunakan [Bootstrap v4](https://getbootstrap.com/) dan sangat sedikit kelas CSS kostum, jadi tema yang kompatibel dengan Bootstrap v4 seharusnya bekerja dengan baik.

## Membuat

- Gunakan alat seperti [bootstrap.build](https://bootstrap.build/) untuk membuat tema Bootstrap v4. Ketika sudah, ekspor `bootstrap.min.css` dan simpan juga `_variables.scss`.

## Menguji

- Untuk menguji tema, Anda bisa antara menggunakan alat web peramban Anda atau plugin seperti Stylus untuk menyalin tempel tema ketika menjelajah Lemmy.

## Menambahkan

1. _Fork_ [lemmy-ui](https://github.com/LemmyNet/lemmy-ui).
1. Salin `{my-theme-name}.min.css` ke `src/assets/css/themes`. (Anda juga bisa menyalin `_variables.scss` ).
1. Pergi ke `src/shared/utils.ts` dan tambahkan `{my-theme-name}` ke daftar tema.
1. Uji lokal
1. Lakukan permintaan dorong (pull request) dengan perubahan tersebut.
