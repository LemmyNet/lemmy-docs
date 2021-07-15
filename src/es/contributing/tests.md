### Pruebas

#### Rust

Después de instalar las [dependencias para el desarrollo local](local_development.md), ejecuta el siguiente comando:

```bash
psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./test.sh
```

### Federación

Instala las [dependencias para el desarrollo local](local_development.md), y agrega las siguientes a `/etc/hosts`:

```
127.0.0.1       lemmy-alpha
127.0.0.1       lemmy-beta
127.0.0.1       lemmy-gamma
127.0.0.1       lemmy-delta
127.0.0.1       lemmy-epsilon
```

Después usa el siguiente script para correr las pruebas:

```
cd api_tests
./run-federation-test.bash
```
