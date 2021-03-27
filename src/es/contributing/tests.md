### Tests

#### Rust

After installing [local development dependencies](local_development.md), run the
following commands:

```bash
psql -U lemmy -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
./test.sh
```

### Federation

Install the [Local development dependencies](local_development.md), and add the following lines to `/etc/hosts`:

```
127.0.0.1       lemmy-alpha
127.0.0.1       lemmy-beta
127.0.0.1       lemmy-gamma
127.0.0.1       lemmy-delta
127.0.0.1       lemmy-epsilon
```

Then use the following script to run the tests:
```
cd api_tests
./run-federation-test.bash
```
