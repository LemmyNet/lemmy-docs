# Membuat Antarmuka Kustom

Bagian belakang dan antarmuka terpisah dan berjalan di kontainer Docker mandiri. Mereka hanya berkomunikasi lewat [API Lemmy](api_reference.md), yang membuat mudah untuk menulis antarmuka alternatif.

Ini membuka banyak potensi untuk antarmuka kustom, yang bisa mengubah banyak desain dan pengalaman pengguna Lemmy. Contoh, mungkin bisa untuk membuat sebuah antarmuka dalam gaya forum tradisional seperti [phpBB](https://www.phpbb.com/) atau gaya tanya-jawab seperti [stackoverflow](https://stackoverflow.com/), dll. Semuanya tanpa harus memikirkan tentang kueri basis data, autentikasi, atau ActivityPub, yang semua bisa Anda dapatkan secara gratis.

## Pengembangan

Anda bisa menggunakan bahasa apa pun untuk membuat antarmuka kustom. Pilihan termudah adalah dengan _fork_ [antarmuka resmi](https://github.com/LemmyNet/lemmy-ui), [lemmy-lite](https://github.com/IronOxidizer/lemmy-lite), atau [lemmy-frontend-example](https://github.com/LemmyNet/lemmy-front-end-example). Apa pun itu, prinsipnya sama: _bind_ ke `LEMMY_EXTERNAL_HOST` (baku: `localhost:8536`) dan mengelola permintaan menggunakan API Lemmy di `LEMMY_INTERNAL_HOST` (baku: `lemmy:8536`). Gunakan juga `LEMMY_HTTPS` untuk membuat tautan dengan protokol yang benar.

Langkah selanjutnya adalah membangun _image_ Docker dari antarmuka Anda. Jika Anda _fork_ proyek yang sudah ada sebelumnya, seharusnya ada `Dockerfile` di sana dan instruksi untuk membangunnya. Kalau tidak, coba cari dalam bahasa Anda di [dockerhub](https://hub.docker.com/), _image_ resmi biasanya mempunyai instruksi membangun di README mereka. Buat sebuah _image_ Docker dengan tanda, kemudian cari bagian berikut di `docker/dev/docker-compose.yml`:

```
  lemmy-ui:
    image: dessalines/lemmy-ui:v0.8.10
    ports:
      - "1235:1234"
    restart: always
    environment:
      - LEMMY_INTERNAL_HOST=lemmy:8536
      - LEMMY_EXTERNAL_HOST=localhost:8536
      - LEMMY_HTTPS=false
    depends_on:
      - lemmy
```

Yang hanya harus Anda lakukan adalah mengganti nilai untuk `image` dengan tanda dari _image_ Docker Anda (dan kalau bisa variabel lingkungannya, jika Anda membutuhkan yang berbeda). Kemudian jalankan `./docker_update.sh`, dan setelah penyusunan, antarmuka Anda akan tersedia di `http://localhost:1235`. Anda juga bisa membuat perubahan yang sama ke `docker/federation/docker-compose.yml` dan jalankan `./start-local-instances.bash` untuk menguji federasi dengan antarmuka Anda.

## Pasang dengan Docker

Setelah membangun _image_ Docker, Anda perlu memasukkannya ke sebuah registri Docker (seperti [dockerhub](https://hub.docker.com/)). Kemudian perbarui `docker-compose.yml` di peladen Anda, mengganti `image` untuk `lemmy-ui`, seperti yang dijelaskan di atas. Jalankan `docker-compose.yml`, kemudian setelah beberapa saat peladen Anda akan menggunakan antarmuka yang baru.

Perlu dicatat, jika peladen Anda dipasang menggunakan Ansible, ini akan menimpa `docker-compose.yml` di setiap pemulaian, mengembalikannya ke antarmuka baku. Jika begitu, Anda harus menyalin folder `ansible/` dari proyek ini ke repositori Anda, dan atur `docker-compose.yml` langsung di repo.

Mungkin juga untuk menggunakan berbagai antarmuka untuk satu peladen yang sama, antara menggunakan subdomain atau subfolder. Untuk itu, jangan sunting bagian `lemmy-ui` di `docker-compose.yml`, tapi gandakan itu, atur nama, _image_, dan porta sehingga satu sama lain berbeda. Kemudian sunting konfigurasi nginx untuk meneruskan permintaan ke antarmuka yang sesuai, tergantung subdomain atau jalurnya.

## Terjemahan

Anda bisa menambahkan repositori [lemmy-translations](https://github.com/LemmyNet/lemmy-translations) ke proyek Anda sebagai [git submodule](https://git-scm.com/book/id/v2/Git-Tools-Submodules). Dengan begitu, Anda bisa memanfaatkan terjemahan yang sama dengan yang digunakan di antarmuka resmi dan juga akan bisa menerima terjemahan baru yang dikontribusikan lewat Weblate.

## Pembatasan

Lemmy melakukan pembatasan untuk banyak tindakan berdasarkan IP klien. Tetapi, jika Anda melakukan panggilan API di sisi peladen (cth. seperti _rendering_ sisi peladen, atau pra-_rendering_ javascript), Lemmy akan mengambil IP dari kontainer Docker. Artinya semua permintaan datang dari IP yang sama, dan akan dibatasi lebih cepat. Untuk menghindari permasalahan ini, Anda perlu meneruskan tajuk `X-REAL-IP` dan `X-FORWARDED-FOR` ke Lemmy (tajuk diatur oleh konfigurasi nginx kami).

Berikut adalah contoh potongan untuk NodeJS:

```javascript
function setForwardedHeaders(headers: IncomingHttpHeaders): {
  [key: string]: string,
} {
  let out = {
    host: headers.host,
  };
  if (headers["x-real-ip"]) {
    out["x-real-ip"] = headers["x-real-ip"];
  }
  if (headers["x-forwarded-for"]) {
    out["x-forwarded-for"] = headers["x-forwarded-for"];
  }

  return out;
}

let headers = setForwardedHeaders(req.headers);
let client = new LemmyHttp(httpUri, headers);
```
