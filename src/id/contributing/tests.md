### Pengujian

#### Rust

Setelah memasang [dependensi pengembangan lokal](local_development.md), jalankan perintah berikut: 

```bash
psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./test.sh
```

### Federasi

Pasang [dependensi pengembangan lokal](local_development.md) dan tambahkan baris berikut ke `/etc/hosts`: 

```
127.0.0.1       lemmy-alpha
127.0.0.1       lemmy-beta
127.0.0.1       lemmy-gamma
127.0.0.1       lemmy-delta
127.0.0.1       lemmy-epsilon
```

Kemudian gunakan skrip berikut untuk menjalankan pengujian:
```
cd api_tests
./run-federation-test.bash
```
