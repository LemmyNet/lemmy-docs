# Pemasangan di AWS

> ⚠️ **Peringatan:** metode pemasangan ini tidak direkomendasikan oleh pengembang Lemmy. Jika Anda ada masalah, Anda harus menyelesaikannya sendiri atau tanya pembuat terkait. Jika Anda melihat ada galat di peladen yang dipasang menggunakan metode ini, harap sebutkan di laporan galat.

## CDK Lemmy AWS

Ini mengadung definisi infrastruktur yang diperlukan untuk memasang [Lemmy](https://github.com/LemmyNet/lemmy) ke AWS menggunakan [Kit Pengembangan Awan](https://docs.aws.amazon.com/cdk/latest/guide/home.html) mereka.

### Termasuk:

* Kluster fargate ECS
  * Lemmy-UI
  * Lemmy
  * Pictrs
* CDN CloudFront
* Penyimpanan EFS untuk pengunggahan gambar
* Basis Data Postgres Aurora Tanpa Peladen
* Hos VPC Bastion
* Penyeimbang beban untuk Lemmy
* Rekaman DNS untuk situs Anda

## Mulai cepat

Klon [Lemmy-CDK]( https://github.com/jetbridge/lemmy-cdk). 

Klon [Lemmy](https://github.com/LemmyNet/lemmy) dan [Lemmy-UI](https://github.com/LemmyNet/lemmy-ui) ke direktori di atas ini.

```shell
cp example.env.local .env.local
# sunting .env.local
```

Anda harus menyunting .env.local dengan pengaturan situs Anda.

```shell
npm install -g aws-cdk
npm install
cdk bootstrap
cdk deploy
```

## Harga
Ini *bukan* cara termurah untuk menjalankan Lemmy. Basis Data Aurora Tanpa Peladen bisa membebani Anda ~$90/bulan jika tidak pergi tidur.

## Perintah CDK yang Berguna

* `npm run build`   susun typescript ke js
* `npm run watch`   lacak perubahan dan susun
* `npm run test`    laksanakan uji unit jest
* `cdk deploy`      jalankan tumpukan (stack) ini ke akun/wilayah AWS baku Anda
* `cdk diff`        bandingkan tumpukan yang jalan dengan kondisi saat ini
* `cdk synth`       memancarkan templat CloudFormation yang disintesis
