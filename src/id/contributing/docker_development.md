# Pengembangan Docker

## Dependensi
### Distro berbasis Debian

```bash
sudo apt install git docker-compose
sudo systemctl start docker
git clone https://github.com/LemmyNet/lemmy
```

### Distro berbasis Arch

```bash
sudo pacman -S git docker-compose
sudo systemctl start docker
git clone https://github.com/LemmyNet/lemmy
```

## Jalankan

```bash
cd docker/dev
./docker_update.sh
```

dan pergi ke http://localhost:1236

*Catatan: banyak fitur (seperti dokumen dan gambar) tidak akan berfungsi tanpa menggunakan profil nginx seperti itu di `ansible/templates/nginx.conf`.

Untuk mempercepat pengompilasian Docker, tambahkan yang di bawah ini ke `/etc/docker/daemon.json` dan mulai ulang Docker.
```
{
  "features": {
    "buildkit": true
  }
}
```

Jika penyusunan masih lambat, sebaiknya Anda gunakan [penyusunan lokal](local_development.md).
