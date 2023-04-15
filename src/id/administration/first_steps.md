# Langkah Pertama Administrasi

Setelah Anda berhasil memasang Lemmy entah [secara manual dengan Docker](install_docker.md) atau [secara otomatis dengan Ansible](install_ansible.md), berikut adalah beberapa rekomendasi untuk administrator baru peladen Lemmy.

## Pengaturan Admin

Hal pertama yang dilakukan adalah pergi ke panel admin Anda, yang mana bisa ditemukan dengan mengklik gir di kanan atas di sebelah ikon pencarian. Di sini Anda bisa menentukan deskripsi situs Anda, sehingga orang-orang tahu jika situs Anda tentang topik tertentu atau semua topik diterima. Anda juga bisa menambahkan ikon dan spanduk yang mendefinisikan peladen Anda, contohnya logo organisasi Anda.

Luangkan waktu untuk menjelajah seluruh halaman untuk menemukan opsi berbeda untuk menyesuaikan peladen Lemmy Anda, di halaman yang sama Anda bisa menyunting [berkas konfigurasi](configuration.md) Anda, di mana Anda bisa mencari informasi tentang basis data Anda, surel yang digunakan oleh peladen, opsi federasi, atau siapa administrator utama.

Merupakan ide bagus untuk menunjuk administrator lain selain diri Anda sendiri, di mana jika harus melakukan suatu tindakan saat Anda terlelap. Lihatlah ke [petunjuk moderasi](../moderation/moderation.md) untuk informasi lebih lanjut tentang hal ini.

## Periksa bahwa semua sudah bekerja dengan benar

### Surel

Cara termudah untuk memeriksa bahwa surel sudah bekerja adalah meminta pembaruan kata sandi. Anda perlu untuk mengatur surel di pengaturan Anda jika Anda belum melakukannya.

Setelah itu, tinggal keluar, pergi ke halaman `Masuk`, masukkan surel Anda di kotak `Surel atau Nama Pengguna` dan klik `lupa kata sandi`. Jika semuanya diatur dengan benar, Anda akan menerima sebuah surel untuk memperbarui kata sandi Anda. Anda bisa mengabaikan surel tersebut.

### Federasi

Federasi dimatikan secara baku dan perlu dinyalakan antara lewat panel admin daring atau langsung lewat berkas `config.json`.

Untuk mencoba bahwa federasi peladen Anda bekerja dengan benar, jalankan `curl -H 'Accept: application/activity+json' https://your-instance.com/u/your-username`, itu seharusnya mengembalikan data json, bukan berkas .html. Jika itu tidak jelas untuk Anda, itu seharusnya sama dengan hasil dari `curl -H 'Accept: application/activity+json' https://lemmy.ml/u/nutomic`.

## Penyertaan pada daftar peladen di join-lemmy.org

Untuk dimasukkan pada daftar peladen Lemmy di [join-lemmy.org](https://join-lemmy.org/instances), Anda harus memenuhi persyaratan berikut:

- [x] Terfederasi dengan paling tidak satu peladen dari daftar
- [x] Mempunyai deskripsi dan ikon situs
- [x] Bersabar dan menunggu situs untuk diperbarui, tidak ada jadwal pasti untuk itu

Sementara menunggu, Anda selalu bisa mempromosikan peladen Anda di jejaring sosial lain seperti Mastodon menggunakan tagar `#Lemmy`.

## Selalu terkini

Anda bisa berlangganan ke umpan RSS GitHub untuk diinformasikan tentang rilis terbaru:

- [lemmy](https://github.com/LemmyNet/lemmy/releases.atom)
- [lemmy-ui](https://github.com/LemmyNet/lemmy-ui/releases.atom)
- [lemmy-js-client](https://github.com/LemmyNet/lemmy-js-client/releases.atom)
- [joinlemmy-site](https://github.com/LemmyNet/joinlemmy-site/releases.atom)

Ada juga [Matrix](https://matrix.to/#/!OwmdVYiZSXrXbtCNLw:matrix.org) untuk administrator peladen yang Anda bisa gabung. Anda akan bertemu orang-orang yang bersahabat yang akan membantu (atau paling tidak mencoba) jika Anda bertemu suatu masalah.
