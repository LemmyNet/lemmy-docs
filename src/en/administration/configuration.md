# Configuration

The configuration is based on the file [config.hjson](https://github.com/lemmynet/lemmy/blob/main/config/config.hjson). This file also contains documentation for all the available options. The install instructions tell you how to override the defaults.

The `config.hjson` file is located at `config/config.hjson`. To change the default location, you can set the environment variable `LEMMY_CONFIG_LOCATION`.

An additional environment variable `LEMMY_DATABASE_URL` is available, which can be used with a PostgreSQL connection string like `postgres://lemmy:password@lemmy_db:5432/lemmy`, passing all connection details at once.

If the Docker container is not used, manually create the database specified above by running the following commands:

```bash
cd server
./db-init.sh
```
