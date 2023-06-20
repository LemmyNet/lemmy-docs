# Configuration

The configuration is based on the file config.hjson, which is located by default at `config/config.hjson`. To change the default location, you can set the environment variable `LEMMY_CONFIG_LOCATION`.

Additional environment variable are available:
 - `LEMMY_DATABASE_URL`, which can be used with a PostgreSQL connection string like `postgres://lemmy:password@lemmy_db:5432/lemmy`, passing all connection details at once,  
 - `LEMMY_SMTP_PASSWORD`, which can be used to set the password to authenticate with the SMTP server.

Those environment variables will override values if specified in the config file.

If the Docker container is not used, manually create the database specified above by running the following commands:

```bash
cd server
./db-init.sh
```

## Full config with default values

```hjson
{{#include ../../../include/config/defaults.hjson}}
```

## Lemmy-UI configuration

Lemmy-UI can be configured using environment variables, detailed in its [README](https://github.com/LemmyNet/lemmy-ui#readme).
