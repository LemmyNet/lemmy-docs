# Administrasi Federasi

Catatan: federasi ActivityPub sedang dalam pengembangan. Untuk saat ini, direkomendasikan hanya diaktifkan di peladen uji dulu.

Untuk mengaktifkan federasi, ubah pengaturan `federation.enabled` ke `true` di `lemmy.hjson`, dan mulai ulang Lemmy.

Federasi tidak dimulai secara otomatis, tapi harus dipicu secara manual melalui pencarian. Untuk itu, Anda harus memasukkan referensi ke objek jarak jauh, seperti:

- `!main@lemmy.ml` (Komunitas)
- `@nutomic@lemmy.ml` (Pengguna)
- `https://lemmy.ml/c/programming` (Komunitas)
- `https://lemmy.ml/u/nutomic` (Pengguna)
- `https://lemmy.ml/post/123` (Pos)
- `https://lemmy.ml/comment/321` (Komentar)

Untuk tinjauan bagaimana federasi di Lemmy bekerja dalam tingkat teknis, periksa [Tinjauan Federasi](overview.md) kami.

## Mode Federasi

Melalui kombinasi pilihan konfigurasi federasi, ada beberapa mode federasi yang berbeda, tergantung kepada pembatasannya. Untuk sekarang, kami tidak merekomendasikan untuk menggunakan federasi terbuka, karena alat moderasi masih lacak dan mungkin masih ada masalah keamanan di kode federasi. Federasi terbuka seharusnya baik-baik saja untuk peladen uji atau kecil, tapi peladen besar disarankan untuk menggunakan federasi yang lebih tertutup.

Perlu dicatat bahwa pengaturan tersebut hanya mempengaruhi pengiriman dan penerimaan data antar peladen. Jika federasi dibolehkan dengan suatu peladen, kemudian dihapus dari daftar yang dibolehkan, ini tidak mempengaruhi data yang sudah difederasi sebelumnya. Komunitas, pengguna, pos, dan komentar tersebut masih terlihat, hanya tidak diperbarui saja. Dan bahkan jika suatu peladen diblokir, ia masih bisa mengambil dan menampilkan data publik dari peladen Anda.

### Menggunakan daftar yang dibolehkan, strict_allowlist = true

Mode paling ketat. Lemmy hanya akan terfederasi dengan peladen dari daftar yang dibolehkan, dan memblokir yang lainnya. Ini termasuk semua pos, komentar, pilihan (pilih atas atau bawah), dan pesan pribadi, Anda hanya akan bisa melihat mereka jika pembuatnya ada di peladen yang dibolehkan. Ini berarti komunitas atau utas jarak jauh bisa tidak lengkap, karena peladen Anda memblokir semua pos dan komentar yang pembuatnya tidak di peladen yang dibolehkan.

Daftar yang diblokir diabaikan.

### Menggunakan daftar yang dibolehkan, strict_allowlist = false

Mode ini lebih terbuka dari pada yang sebelumnya. Untuk komunitas lokal, perilakunya identik, hanya pengguna dari peladen yang dibolehkan yang bisa pos, komentar, atau memilih. Perbedaannya adalah dengan komunitas jarak jauh. Daftar yang dibolehkan tidak berlaku untuk mereka, jadi Anda akan melihat semua pos, komentar, dan pilihan di komunitas jarak jauh (kecuali peladen yang buat diblokir). Pesan pribadi bisa dikirim oleh pengguna jarak jauh yang tidak diblokir.

Jika daftar yang diblokir diatur, semua komunikasi dengan peladen yang diblokir akan dicegah, apa pun itu.

### Hanya menggunakan daftar yang diblokir

Jika tidak ada daftar yang dibolehkan yang ditunjukkan, Lemmy akan terfederasi dengan peladen apa pun. Ini adalah mode federasi paling terbuka, dan paling riskan, karena bisa saja seseorang membuat peladen yang berbahaya dan langsung mengirim _spam_ dan konten problematis lainnya ke peladen Anda. Anda bisa menggunakan daftar yang diblokir untuk mencegah terfederasi dengan peladen seperti itu.

`strict_allowlist` diabaikan.
