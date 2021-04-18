### Тесты

#### Rust

После установки [local development dependencies](local_development.md), запустите следующую команду:

```bash
psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./test.sh
```

### Федерация

Установите [Local development dependencies](local_development.md), и добавьте следующую строку `/etc/hosts`:

```
127.0.0.1       lemmy-alpha
127.0.0.1       lemmy-beta
127.0.0.1       lemmy-gamma
127.0.0.1       lemmy-delta
127.0.0.1       lemmy-epsilon
```

Затем используйте следующий скрипт для запуска тестов:
```
cd api_tests
./run-federation-test.bash
```
