# Tinjauan Federasi


Dokumen ini untuk siapa saja yang ingin mengetahui bagaimana federasi Lemmy bekerja, tanpa terlalu teknis. Ini dimaksudkan untuk memberikan tinjauan umum tingkat tinggi terhadap federasi ActivityPub di Lemmy. Jika Anda mengimplementasikan ActivityPub sendiri dan ingin kompatibel dengan Lemmy, baca [Garis Besar API ActivityPub](contributing_apub_api_outline.md) kami.

## Konvensi dokumentasi

Untuk mempermudah, kadang kala Anda akan melihat sesuatu diformat seperti `Create/Note` atau `Delete/Event` atau `Undo/Follow`. Hal sebelum garis miring adalah Aktivitas dan setelahnya adalah Objek di dalam Aktivitas, di properti `object`. Jadi itu dibaca sebagai berikut:

* `Create/Note`: sebuah aktivitas `Create` yang mengandung `Note` di bidang `object`
* `Delete/Event`: sebuah aktivitas `Delete` yang mengandung `Event` di bidang `object`
* `Undo/Follow`: sebuah aktivitas `Undo` yang mengandung `Follow` di bidang `object`

Di Lemmy, kami menggunakan beberapa hal spesifik yang merujuk kepada item ActivityPub. Mereka sejatinya adalah implementasi kami terhadap konsep ActivityPub: 

- Komunitas: `Group`
- Pengguna: `Person`
- Pos: `Page`
- Komentar: `Note`

Dokumentasi ini memiliki tiga bagian utama:

* __Filosofi Federasi__ menjabarkan gambaran umum bagaimana ini ditujukan untuk federasi
* __Aktivitas Pengguna__ menjelaskan tindakan apa yang Pengguna bisa lakukan untuk berinteraksi
* __Aktivitas Komunitas__ menjelaskan apa yang Komunitas lakukan sebagai respons terhadap tindakan beberapa Pengguna

## Filosofi Federasi

Aktor utama di Lemmy adalah Komunitas. Setiap komunitas berada di suatu peladen tunggal dan terdiri dari daftar Pos dan daftar pengikut. Interaksi utama adalah Pengguna mengirim Pos atau Komentar terkait aktivitas ke kotak masuk Komunitas, yang kemudian mengumumkannya ke seluruh pengikutnya.

Setiap Komunitas memiliki Pengguna pembuat tertentu, yang bertanggung jawab untuk mengatur peraturan, mengangkat moderator, dan menghapus konten yang melanggar peraturan. 

Selain moderasi di tingkat komunitas, setiap peladen memiliki seperangkat Pengguna administrator, yang mempunyai kekuasaan untuk melakukan penghapusan dan pelarangan tingkat situs.

Pengguna mengikuti Komunitas yang mereka tertarik kepada mereka untuk menerima Pos dan Komentar. Mereka juga memilih pada Pos dan Komentar, dan juga membuat yang baru. Komentar dikelola dalam struktur pohon dan biasanya diurut berdasarkan jumlah pilihan. Pesan langsung antar Pengguna juga didukung.

Pengguna tidak bisa mengikuti satu sama lain dan Komunitas juga tidak bisa mengikuti apa pun.

Implementasi federasi kami sudah komplit fitur, tapi kami sampai saat ini belum fokus untuk mengikuti spesifikasi ActivityPub. Karena itu, Lemmy kemungkinan besar tidak akan kompatibel dengan implementasi yang mengharapkan untuk mengirim dan menerima aktivitas yang valid. Ini adalah sesuatu yang kami akan perbaiki di masa mendatang. Periksa [#698](https://github.com/LemmyNet/lemmy/issues/698) untuk gambaran penyimpangan kami.

## Aktivitas Pengguna

### Mengikuti sebuah Komunitas

Setiap halaman Komunitas memiliki tombol "Ikuti". Mengkliknya akan memicu sebuah aktivitas `Follow` untuk dikirim dari pengguna ke kotak masuk Komunitas. Komunitas akan secara otomatis merespons dengan aktivitas `Accept/Follow` ke kotak masuk pengguna. Itu juga akan menambahkan pengguna tersebut ke daftar pengikutnya dan mengirimkan setiap aktivitas terkait Pos/Komentar di Komunitas ke pengguna. 

### Batal Mengikuti Komunitas

Setelah mengikuti sebuah Komunitas, tombol "Ikuti" berubah menjadi "Batal Ikuti". Mengklik ini akan mengirim aktivitas `Undo/Follow` ke kotak masuk Komunitas. Komunitas tersebut menghapus Pengguna dari daftar pengikutnya dan tidak akan mengirim aktivitas apa pun lagi ke ia.

### Membuat Pos

Ketika pengguna membuat Pos di Komunitas tertentu, itu akan dikirim sebagai `Create/Page` ke kotak masuk Komunitas tersebut.

### Membuat Komentar

Ketika sebuah Komentar baru dibuat untuk sebuah Pos, baik ID Pos dan ID Komentar induk (jika ada) ditulis ke bidang `in_reply_to`. Ini memungkinkan untuk menetapkannya ke Pos yang benar dan membangun pohon Komentar. Kemudian itu dikirim ke kotak masuk Komunitas sebagai `Create/Note` 

Peladen asal juga memindai Komentar untuk sebutan Pengguna apa pun dan mengirim aktivitas `Create/Note` ke Pengguna tersebut.

### Menyunting Pos

Mengubah konten dari Pos yang sudah ada. Hanya bisa dilakukan oleh Pengguna yang membuat.

### Menyunting Komentar

Mengubah konten dari Komentar yang sudah ada. Hanya bisa dilakukan oleh Pengguna yang membuat.

### Suka dan Tidak Suka

Pengguna bisa suka dan tidak sukai Pos atau Komentar apa pun. Itu dikirim sebagai `Like/Page`, `Dislike/Note`, dll. ke kotak masuk Komunitas.

### Penghapusan

Pembuat dari Pos, Komentar, atau Komunitas bisa menghapus yang dibuatnya. Itu kemudian dikirim ke pengikut Komunitas. Kemudian itu disembunyikan dari seluruh pengguna.

### Pembersihan

Moderator bisa membersihkan Pos dan Komentar dari Komunitas mereka. Administrator bisa membersihkan Pos dan Komentar apa pun dari seluruh peladen ia sendiri. Komunitas juga bisa dibersihkan oleh administrator. Kemudian, itu disembunyikan dari seluruh pengguna.

Pembersihan dikirim ke seluruh pengikut dari sebuah Komunitass, supaya mereka akan terkena efeknya di sana. Pengecualian dari ini adalah jika administrator membersihkan sesuatu dari Komunitas yang dihos di peladen yang berbeda. Jika begitu, pembersihan hanya berefek secara lokal.

### Mengurungkan Tindakan Sebelumnya

Tidak ada yang dihapus dari basis data, hanya menyembunyikannya dari pengguna. Komunitas/Pos/Komentar yang telah dihapus atau dibersihkan memiliki tombol "pulihkan". Tombol ini menghasilkan aktivitas `Undo` yang menetapkan aktivitas penghapusan/pembersihan sebelumnya sebagai objek, seperti `Undo/Remove/Post` atau `Undo/Delete/Community`.

Mengklik tombol pilih naik dari pos/komentar yang sudah dipilih naikkan (atau pilih turun dari pos/komentar yang sudah dipilih turunkan) akan juga menghasilkan `Undo`. Dalam contoh tersebut akan menghasilkan `Undo/Like/Post` atau `Undo/Dislike/Comment`.

### Buat Pesan Pribadi

Di profil pengguna ada tombol "Kirim Pesan", yang akan membuka dialog perizinan untuk mengirimkan pesan pribadi ke pengguna ini. Ini dikirim sebagai `Create/Note` ke kotak masuk pengguna tersebut. Pesan pribadi hanya bisa ditujukan kepada satu pengguna tunggal.

### Sunting Pesan Pribadi

`Update/Note` mengubah teks dari pesan yang telah dikirim sebelumnya.

### Hapus Pesan Pribadi

`Delete/Note` menghapus pesan pribadi.

### Memulihkan Pesan Pribadi

`Undo/Delete/Note` mengurungkan penghapusan pesan pribadi.

## Aktivitas Komunitas

Komunitas itu secara dasarnya adalah bot, yang hanya akan melakukan sesuatu sebagai balasan untuk tindakan dari pengguna. Pengguna yang pertama kali membuat komunitas akan menjadi moderator pertama dan bisa menambahkan moderator tambahan. Secara umum, kapan pun komunitas menerima aktivitas yang valid di kotak masuknya, aktivitas tersebut akan diteruskan ke seluruh pengikutnya.

### Menerima Ikuti

Jika komunitas menerima aktivitas `Follow`, maka komunitas akan secara otomatis membalas dengan `Accept/Follow`. Komunitas juga menambahkan pengguna tersebut ke daftar pengikutnya. 

### Batal Ikuti

Ketika menerima `Undo/Follow`, Komunitas menghapus Pengguna tersebut dari daftar pengikutnya.
 
### Mengumumkan

Jika Komunitas menerima aktivitas terkait Pos atau Komentar (Buat, Perbarui, Suka, Tidak Suka, Hapus, Bersihkan, Urung), Komunitas akan mengumumkannya ke pengikutnya. Untuk ini, Mengumumkan dibuat dengan Komunitas sebagai aktor dan aktivitas yang diterima sebagai objek. Karena itu, peladen tersebut dapat terus pembaruan terkait aktivitas di Komunitas yang diikutinya.

### Menghapus Komunitas

Jika pembuat atau administrator menghapus sebuah Komunitas, itu mengirim `Delete/Group` ke seluruh pengikutnya.
