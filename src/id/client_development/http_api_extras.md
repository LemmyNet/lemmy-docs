# Ekstra API HTTP Lemmy

Dokumen ini mengandung ekstra yang tidak ada di [dokumentasi API](/api).

<!-- toc -->

- [Contoh Curl](#contoh-curl)
- [Fitur khusus API HTTP](#fitur-khusus-api-http)
  * [Umpan RSS/Atom](#umpan-rssatom)
  * [Gambar](#gambar)
    + [Buat (permintaan)](#buat-permintaan)
    + [Buat (respons)](#buat-respons)
    + [Hapus](#hapus)

<!-- tocstop -->

## Contoh Curl

**Contoh GET**

```
curl "http://localhost:8536/api/v2/community/list?sort=Hot"`
```

**Contoh POST**

```
curl -i -H \
"Content-Type: application/json" \
-X POST \
-d '{
  "comment_id": 374,
  "score": 1,
  "auth": eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpZCI6MiwiaXNzIjoidGVzdC5sZW1teS5tbCJ9.P77RX_kpz1a_geY5eCp29sl_5mAm-k27Cwnk8JcIZJk
}' \
http://localhost:8536/api/v2/comment/like
```

## Fitur Khusus API HTTP

Fitur berikut tidak bisa diakses dari API WebSocket:

- [Umpan RSS/Atom](#umpan-rssatom)
- [Gambar](#gambar)

### Umpan RSS/Atom

- Semua - `/feeds/all.xml?sort=Hot`
- Komunitas - `/feeds/c/community-name.xml?sort=Hot`
- Pengguna - `/feeds/u/user-name.xml?sort=Hot`

### Gambar

Lemmy meneruskan permintaan gambar ke Pictrs yang berjalan di lokal.

`GET /pictrs/image/{filename}?format={webp, jpg, ...}&thumbnail={96}`

*Format dan keluku opsional.*

#### Buat (Permintaan)

Konten yang diunggah harus merupakan data format/multi-bagian dengan _array_ gambar yang terletak di dalam kunci images[].

`POST /pictrs/image` 

#### Buat (respons)

```
{
  "files": [
    {
      "delete_token": "{token}",
      "file": "{file}.jpg"
    }
  ],
  "msg": "ok"
}
```

#### Hapus

`GET /pictrs/image/delete/{delete_token}/{file}`
