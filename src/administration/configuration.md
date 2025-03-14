# Configuration

The configuration is based on the file config.hjson, which is located by default at `config/config.hjson`, or `lemmy.hjson` when using Docker. You can set a different path with the environment variable `LEMMY_CONFIG_LOCATION`.

## Full config with default values

```hjson
{{#include ../../include/config/defaults.hjson}}
```

## Lemmy-UI configuration

Lemmy-UI can be configured using environment variables, detailed in its [README](https://github.com/LemmyNet/lemmy-ui#readme).
