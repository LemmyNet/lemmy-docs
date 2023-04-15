# Federasi

Lemmy memiliki tiga jenis federasi:

- Daftar yang diperbolehkan: Secara jelas mendaftar peladen untuk terhubung.
- Daftar yang diblokir: Secara jelas mendaftar peladen untuk tidak terhubung. Federasi masih bisa untuk semua peladen lainnya.
- Terbuka: Terfederasi dengan semua peladen yang mungkin.

**Federasi tidak diatur secara baku.** Anda bisa menambahkan [blok federasi ini](https://github.com/lemmynet/lemmy/blob/main/config/config.hjson#L64) ke `lemmy.hjson` Anda dan minta peladen lain untuk menambahkan Anda ke daftar yang diperbolehkan mereka.

Lemmy menggunakan protokol ActivityPub (standar W3C) untuk mengaktifkan federasi antar peladen berbeda. Ini sangat sama dengan bagaimana surel bekerja. Contohnya, jika Anda menggunakan gmail.com, maka Anda bisa tidak hanya mengirim surel ke pengguna gmail.com lain, tapi juga ke pengguna yahoo.com, yandex.ru, dll. Surel menggunakan protokol SMTP untuk mencapai hal tersebut, jadi Anda bisa menganggap ActivityPub adalah "SMTP untuk media sosial". Jumlah tindakan berbeda yang mungkin dilakukan di media sosial (pos, komentar, suka, bagikan, dll) berarti bahwa ActivityPub jauh lebih rumit daripada SMTP.

Sama seperti surel, federasi ActivityPub hanya terjadi antar peladen. Jadi jika Anda terdaftar pada `enterprise.lemmy.ml`, Anda hanya terhubung ke API dari `enterprise.lemmy.ml`, sementara peladen mengurus pengiriman dan penerimaan data dari peladen lainnya (mis. `voyager.lemmy.ml`). Keuntungan besar dari pendekatan ini adalah pengguna biasa tidak harus melakukan apa pun untuk menggunakan federasi. Bahkan jika Anda menggunakan Lemmy, kemungkinan besar Anda sudah menggunakannya. Salah satu cara untuk mengonfirmasinya adalah dengan membuka komunitas atau profil pengguna. Jika Anda berada di `enterprise.lemmy.ml` dan Anda melihat pengguna seperti `@nutomic@voyager.lemmy.ml`, atau komunitas seperti `!main@ds9.lemmy.ml`, maka itu berarti Anda sudah terfederasi, artinya mereka menggunakan peladen yang berbeda dari Anda.

Salah satu cara Anda bisa mengambil keuntungan dari federasi adalah dengan membuka peladen lain, seperti `ds9.lemmy.ml` dan jelajahi itu. Jika Anda melihat sebuah komunitas, pos, atau pengguna yang menarik yang Anda ingin berinteraksi dengan mereka, tinggal salin URL-nya dan tempel itu di pencarian dari peladen Anda sendiri. Peladen Anda akan terhubung ke yang disebutkan (menganggap daftar yang diperbolehkan/diblokir memperbolehkannya), dan secara langsung menampilkan konten jarak jauh untuk Anda, sehingga Anda bisa mengikuti sebuah komunitas atau berkomentar di sebuah pos. Berikut adalah beberapa contoh dari pencarian yang bekerja:

- `!main@lemmy.ml` (Komunitas)
- `@nutomic@lemmy.ml` (Pengguna)
- `https://lemmy.ml/c/programming` (Komunitas)
- `https://lemmy.ml/u/nutomic` (Pengguna)
- `https://lemmy.ml/post/123` (Pos)
- `https://lemmy.ml/comment/321` (Komentar)

Anda bisa melihat daftar dari peladen yang terhubung dengan mengikuti pada tautan "Peladen" pada bagian bawah dari setiap halaman Lemmy.

## Mengambil komunitas

Jika Anda mencari sebuah komunitas untuk pertama kali, awal-awal 20 pos akan diambil. Hanya jika paling tidak satu pengguna dari peladen Anda berlangganan ke komunitas jarak jauh yang akan membuat komunitas tersebut mengirim pembaruan ke peladen Anda. Pembaruan termasuk:

- Pos dan komentar baru
- Pilihan (Pilih Atas/Bawah)
- Penyuntingan dan penghapusan pos dan komentar
- Tindakan moderator

Anda bisa menyalin URL dari komunitas di bilah alamat peramban Anda dan memasukkannya ke bilah pencarian Anda. Tunggu beberapa saat dan pos akan muncul. Saat ini tidak ada penunjuk sedang memuat untuk pencarian, jadi tunggu beberapa saat jika muncul "no results".

## Mengambil pos

Tempel URL dari pos ke bilah pencarian peladen Lemmy Anda. Tunggu beberapa saat sampai posnya muncul. Ini juga akan mengambil profil komunitas dan profil dari pembuat pos.

## Mengambil komentar

Jika Anda menemukan sebuah komentar yang menarik di bawah pos di peladen lain, Anda bisa mencari di bawah komentar di menu 3 tombol sebuah ikon tautan. Salin tautan tersebut. Bentuknya seperti `https://lemmy.ml/post/56382/comment/40796`. Hapus bagian `post/XXX` dan taruh di bilah pencarian Anda. Untuk contoh tadi, bentuknya seperti `https://lemmy.ml/comment/40796`. Komentar tersebut, semua komentar induk, pengguna dan komunitas, dan semua pos yang berhubungan diambil dari peladen jarak jauh, jika mereka belum dikenali secara lokal.

Komentar saudara tidak diambil! Jika Anda ingin lebih banyak komentar dari pos lama, Anda harus mencari mereka satu per satu seperti yang dijelaskan di atas.
