# Protokol Federasi Lemmy

Protokol Lemmy (atau Protokol Federasi Lemmy) merupakan bagian dari Protokol ActivityPub, dengan beberapa tambahan.

Dokumen ini ditujukan untuk pengembang yang familiar dengan protokol ActivityPub dan ActivityStreams. Dokumen ini memberikan gambaran rinci tentang aktor, objek, dan aktivitas yang digunakan oleh Lemmy.

Sebelum membaca bagian ini, coba lihat pada [Tinjauan Federasi](overview.md) kami untuk mendapatkan gambaran bagaimana federasi Lemmy bekerja pada tingkat tinggi.

<!-- toc -->

- [Context](#context)
- [Actors](#actors)
  * [Community](#community)
  * [User](#user)
- [Objects](#objects)
  * [Post](#post)
  * [Comment](#comment)
  * [Private Message](#private-message)
- [Collections](#collections)
  * [Community Outbox](#community-outbox)
  * [Community Followers](#community-followers)
  * [Community Moderators](#community-moderators)
  * [User Outbox](#user-outbox)
- [Activities](#activities)
  * [User to Community](#user-to-community)
    + [Follow](#follow)
    + [Unfollow](#unfollow)
    + [Report Post or Comment](#report-post-or-comment)
  * [Community to User](#community-to-user)
    + [Accept Follow](#accept-follow)
    + [Announce](#announce)
  * [Announcable](#announcable)
    + [Create or Update Post](#create-or-update-post)
    + [Create or Update Comment](#create-or-update-comment)
    + [Like Post or Comment](#like-post-or-comment)
    + [Dislike Post or Comment](#dislike-post-or-comment)
    + [Undo Like or Dislike Post or Comment](#undo-like-or-dislike-post-or-comment)
    + [Delete Post or Comment](#delete-post-or-comment)
    + [Remove Post or Comment](#remove-post-or-comment)
    + [Undo Delete or Remove](#undo-delete-or-remove)
    + [Add Mod](#add-mod)
    + [Remove Mod](#remove-mod)
    + [Block User](#block-user)
    + [Undo Block User](#undo-block-user)
  * [User to User](#user-to-user)
    + [Create or Update Private message](#create-or-update-private-message)
    + [Delete Private Message](#delete-private-message)
    + [Undo Delete Private Message](#undo-delete-private-message)

<!-- tocstop -->

## Konteks

```json
{{#include ../../../include/crates/apub/assets/lemmy/context.json}}
```

Konteks identik untuk semua aktivitas dan objek.

## Aktor

### Komunitas

Aktor terotomatisasi. Pengguna bisa mengirim pos atau komentar ke ini, yang mana komunitas meneruskannya ke pengikutnya dalam bentuk `Announce`.

Mengirim aktivitas ke pengguna: `Accept/Follow`, `Announce`.

Menerima aktivitas dari pengguna: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (hanya admin/moderator), `Delete`  (hanya pembuat), Undo (hanya untuk tindakan sendiri)

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/group.json}}
```

| Nama Bidang | Deskripsi |
|---|---|
| `preferredUsername` | Nama aktor |
| `name` | Judul komunitas |
| `sensitive` | True menunjukkan bahwa semua pos di komunitas adalah NSFW |
| `attributedTo` | Pertama, pembuat komunitas, kemudian moderator lainnya |
| `content` | Teks untuk bilah samping komunitas, biasanya memuat deskripsi dan peraturan |
| `icon` | Ikon, ditampilkan di sebelah nama komunitas |
| `image` | Gambar spanduk, ditampilkan di bagian atas halaman komunitas |
| `inbox` | URL kotak masuk ActivityPub |
| `outbox` | URL kotak keluar ActivityPub, hanya mengandung 20 pos terakhir, tidak ada komentar, pilihan suara, atau aktivitas lainnya |
| `followers` | URL koleksi pengikut, hanya mengandung jumlah pengikut, tidak ada penunjuk terhadap pengikut individual |
| `endpoints` | URL kotak masuk bersama |
| `published` | Tanggal waktu komunitas dibuat |
| `updated` | Tanggal waktu komunitas terakhir diubah |
| `publicKey` | Kunci publik yang digunakan untuk memverifikasi tanda tangan dari aktor ini |

### Pengguna

Orang, yang berinteraksi secara umum dengan komunitas, di mana ia mengirim dan menerima pos dan/atau komentar. Bisa juga membuat dan memoderasi komunitas dan mengirim pesan pribadi ke pengguna lain.

Mengirim aktivitas ke komunitas: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (hanya admin/moderator), `Delete`  (hanya pembuat), `Undo` (hanya untuk tindakan sendiri).

Menerima aktivitas dari komunitas: `Accept/Follow`, `Announce`

Menerima dan mengirim aktivitas dari/ke pengguna lain: `Create/Note`, `Update/Note`, `Delete/Note`, `Undo/Delete/Note` (semua itu terkait dengan pesan pribadi)

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/person.json}}
```

| Nama Bidang | Deskripsi |
|---|---|
| `preferredUsername` | Nama aktor |
| `name` | Nama tampilan pengguna |
| `content` | Bio pengguna |
| `icon` | Avatar pengguna, ditampilkan di sebelah nama pengguna |
| `image` | Spanduk pengguna, ditampilkan di bagian atas profil pengguna |
| `inbox` | URL kotak masuk ActivityPub |
| `endpoints` | URL kotak masuk bersama |
| `published` | Tanggal waktu pengguna mendaftar |
| `updated` | Tanggal waktu profil pengguna terakhir diubah |
| `publicKey` | Kunci publik yang digunakan untuk memverifikasi tanda tangan dari aktor ini |

Kotak masuk pengguna sebenarnya belum diimplementasikan dan hanya sebagai papan nama untuk implementasi ActivityPub yang membutuhkannya.

## Objek

### Pos

Halaman dengan judul, dan opsional ada URL dan konten teks. URL biasanya merujuk ke gambar, yang mana kelukunya disertakan. Setiap pos dimiliki oleh hanya satu komunitas.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/page.json}}
```

| Nama Bidang | Deskripsi |
|---|---|
| `attributedTo` | ID dari pengguna yang membuat pos tersebut |
| `to` | ID dari komunitas di mana pos tersebut dipos |
| `name` | Judul pos |
| `content` | Badan/Konten pos |
| `url` | Tautan apa pun untuk dibagian |
| `image` | Keluku untuk `url`, hanya ada jika tautannya adalah tautan gambar |
| `commentsEnabled` | False menunjukkan bahwa pos tersebut dikunci dan tidak ada komentar lagi yang bisa ditambahkan |
| `sensitive` | True menandai pos tersebut sebagai NSFW, mengaburkan kelukunya, dan menyembunyikannya dari pengguna dari pengguna yang pengaturan NSFW-nya dimatikan |
| `stickied` | True menunjukkan bahwa pos tersebut ditampilkan di bagian atas komunitas |
| `published` | Tanggal waktu pos dibuat |
| `updated` | Tanggal waktu pos disunting (tidak ada jika tidak pernah disunting) |

### Komentar

Balasan kepada pos, atau balasan ke komentar lain. Hanya mengandung teks (termasuk referensi ke pengguna atau komunitas lain). Lemmy menampilkan komentar dalam struktur pohon.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/note.json}}
```

| Nama Bidang | Deskripsi |
|---|---|
| `attributedTo` | ID dari pengguna yang membuat pos |
| `to` | Komunitas di mana komentar tersebut dibuat |
| `content` | Teks komentar |
| `inReplyTo` | ID pos di mana komentar tersebut dibuat, dan komentar induk (jika ada). Jika komentar ini adalah komentar induk, bidang ini hanya berisi ID pos saja |
| `published` | Tanggal waktu komentar dibuat |
| `updated` | Tanggal waktu komentar disunting (tidak ada jika tidak pernah disunting) |

### Pesan Pribadi

Pesan langsung dari satu pengguna ke pengguna lain. Tidak bisa ada pengguna ketiga yang bergabung. Pengutasan belum diimplementasikan, jadi bidang `inReplyTo` tidak ada.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/chat_message.json}}
```

| Nama Bidang | Deskripsi |
|---|---|
| `attributedTo` | ID pengguna yang membuat pesan pribadi |
| `to` | ID penerima |
| `content` | Teks pesan pribadi |
| `published` | Tanggal waktu pesan dibuat |
| `updated` | Tanggal waktu pesan disunting (tidak ada jika tidak pernah disunting) |

## Koleksi

### Kotak Keluar Komunitas

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_outbox.json}}
```

Saat ini, kotak keluar hanya mengandung aktivitas `Create/Post`.

### Pengikut Komunitas

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_followers.json}}
```

Koleksi/Statistik pengikut hanya digunakan untuk menampilkan jumlah pengikut komunitas. ID aktor tidak diikutkan untuk melindungi privasi pengguna.

### Moderator Komunitas

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_moderators.json}}
```

### Kotak Keluar Pengguna

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/person_outbox.json}}
```

## Aktivitas

### Pengguna ke Komunitas

#### Ikuti

Ketika pengguna mengklik "Langgan" di komunitas, aktivitas `Follow`  dikirim. Secara otomatis komunitas membalas dengan `Accept/Follow`.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/follow.json}}
```

#### Batal Ikuti

Ketika pengguna mengklik "Berhenti Berlangganan" di komunitas, aktivitas `Undo/Follow` dikirim. Setelah menerima aktivitas tersebut, komunitas menghapus pengguna tersebut dari daftar pengikutnya.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/undo_follow.json}}
```


#### Lapor Pos atau Komentar

Melaporkan pos atau komentar sebagai pelanggaran peraturan, supaya admin/moderator bisa meninjaunya.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/report_page.json}}
```

### Komunitas ke Pengguna

#### Menerima Ikuti

Secara otomatis dikirim oleh komunitas sebagai balasan untuk aktivitas `Follow`. Saat yang bersamaan, komunitas menambahkan pengguna tersebut ke daftar pengikutnya.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/accept.json}}
```

#### Mengumumkan

Ketika komunitas menerima aktivitas pos atau komentar, itu kemudian dibungkus menjadi aktivitas `Announce` dan mengirimkannya ke seluruh pengikutnya.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/announce_create_page.json}}
```

### Bisa Diumumkan

Semua aktivitas di bawah ini dikirim dari pengguna ke komunitas. Komunitas kemudian membungkusnya sebagai aktivitas `Announce` dan mengirimkannya ke pengikutnya.

#### Buat atau Perbarui Pos

Ketika pengguna membuat pos baru, itu dikirim ke komunitas terkait. Menyunting pos yang sudah dibuat sebelumnya akan mengirim aktivitas yang hampir identik, perbedaannya adalah `type` menjadi `Update`. Penyebutan di pos belum didukung.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_page.json}}
```

#### Buat atau Perbarui Komentar

Balasan kepada pos, atau komentar lain. Bisa mengandung penyebutan pengguna lain. Menyunting komentar yang sudah dibuat sebelumnya akan mengirim aktivitas yang hampir identik, perbedaannya adalah `type` menjadi `Update`.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_note.json}}
```

#### Sukai Pos atau Komentar

Pilih naik untuk pos atau komentar.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/like_note.json}}
```

#### Tidak Sukai Pos atau Komentar

Pilih turun untuk pos atau komentar.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/dislike_page.json}}
```

#### Urung Sukai atau Tidak Sukai Pos atau Komentar

Hapus suara (pilih atas atau pilih turun) yang dilakukan oleh pengguna yang sama.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/undo_like_note.json}}
```

#### Hapus Pos atau Komentar

Hapus pos atau komentar. Ini hanya bisa dilakukan oleh pembuat pos atau komentar tersebut.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/delete_page.json}}
```

#### Bersihkan Pos atau Komentar

Bersihkan pos atau komentar. Ini hanya bisa dilakukan oleh moderator komunitas atau admin dari peladen di mana komunitas tersebut berada. Perbedaan dari penghapusan adalah aktivitas pembersihan mempunyai bidang ringkasan, yang mengandung alasan pembersihan, yang diberikan oleh moderator atau admin.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/remove_note.json}}
```

#### Urung Penghapusan atau Pembersihan

Urung tindakan oleh aktivitas di bidang objek. Dalam contoh di bawah, komentar yang dibersihkan dipulihkan.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/undo_remove_note.json}}
```

#### Tambah Moderator

Tambah moderator baru ke sebuah komunitas. Harus dikirim dari moderator komunitas tersebut, atau admin dari peladen di mana komunitas tersebut berada.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/add_mod.json}}
```

#### Keluarkan Moderator

Keluarkan moderator yang saat itu dari sebuah komunitas. Harus dikirim dari moderator komunitas tersebut, atau admin dari peladen di mana komunitas tersebut berada.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/remove_mod.json}}
```

#### Larang Pengguna

Larang pengguna dari sebuah komunitas, sehingga ia tidak bisa berpartisipasi di komunitas tersebut.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/block/block_user.json}}
```

#### Urung Larang Pengguna

Urung pelarangan pengguna.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/block/block_user.json}}
```

### Pengguna ke Pengguna

#### Buat atau Perbarui Pesan Pribadi

Buat pesan pribadi antar dua pengguna.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_private_message.json}}
```

#### Hapus Pesan Pribadi

Hapus pesan pribadi.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/delete_private_message.json}}
```

#### Urung Hapus Pesan Pribadi

Pulihkan pesan pribadi yang dihapus. `object` kembali dihasilkan dari awal, karena itu ID aktivitas dan bidang lainnya berbeda dengan yang sebelumnya.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/undo_delete_private_message.json}}
```
