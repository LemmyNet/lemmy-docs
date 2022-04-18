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

### Unfollow a Community

After following a Community, the "Follow" button is replaced by "Unfollow". Clicking this sends an `Undo/Follow` activity to the Community inbox. The Community removes the User from its followers list and doesn't send any activities to it anymore.

### Create a Post

When a user creates a new Post in a given Community, it is sent as `Create/Page` to the  Community
inbox. 

### Create a Comment

When a new Comment is created for a Post, both the Post ID and the parent Comment ID (if it exists)
are written to the `in_reply_to` field. This allows assigning it to the correct Post, and building
the Comment tree. It is then sent to the Community inbox as `Create/Note`

The origin instance also scans the Comment for any User mentions, and sends the `Create/Note` to
those Users as well.

### Edit a Post

Changes the content of an existing Post. Can only be done by the creating User.

### Edit a Comment

Changes the content of an existing Comment. Can only be done by the creating User.

### Likes and Dislikes

Users can like or dislike any Post or Comment. These are sent as `Like/Page`, `Dislike/Note` etc to the Community inbox.

### Deletions

The creator of a Post, Comment or Community can delete it. It is then sent to the Community followers. The item is then hidden from all users.

### Removals

Mods can remove Posts and Comments from their Communities. Admins can remove any Posts or Comments on the entire site. Communities can also be removed by admins. The item is then hidden from all users.

Removals are sent to all followers of the Community, so that they also take effect there. The exception is if an admin removes an item from a Community which is hosted on a different instance. In this case, the removal only takes effect locally.

### Revert a previous Action

We don't delete anything from our database, just hide it from users. Deleted or removed Communities/Posts/Comments have a "restore" button. This button generates an `Undo` activity which sets the original delete/remove activity as object, such as `Undo/Remove/Post` or `Undo/Delete/Community`.

Clicking on the upvote button of an already upvoted post/comment (or the downvote button of an already downvoted post/comment) also generates an `Undo`. In this case and `Undo/Like/Post` or `Undo/Dislike/Comment`.

### Create private message

User profiles have a "Send Message" button, which opens a dialog permitting to send a private message to this user. It is sent as a `Create/Note` to the user inbox. Private messages can only be directed at a single User.

### Edit private message

`Update/Note` changes the text of a previously sent message

### Delete private message

`Delete/Note` deletes a private message.

### Restore private message

`Undo/Delete/Note` reverts the deletion of a private message.

## Community Activities

The Community is essentially a bot, which will only do anything in reaction to actions from Users. The User who first created the Community becomes the first moderator, and can add additional moderators. In general, whenever the Community receives a valid activity in its inbox, that activity is forwarded to all its followers.

### Accept follow

If the Community receives a `Follow` activity, it automatically responds with `Accept/Follow`. It also adds the User to its list of followers. 

### Unfollow

Upon receiving an `Undo/Follow`, the Community removes the User from its followers list.
 
### Announce

If the Community receives any Post or Comment related activity (Create, Update, Like, Dislike, Remove, Delete, Undo), it will Announce this to its followers. For this, an Announce is created with the Community as actor, and the received activity as object. Following instances thus stay updated about any actions in Communities they follow.

### Delete Community

If the creator or an admin deletes the Community, it sends a `Delete/Group` to all its followers.
