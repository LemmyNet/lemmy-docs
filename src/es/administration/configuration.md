# Configuración

La configuración está basada en el archivo [defaults.hjson](https://yerbamate.ml/LemmyNet/lemmy/src/branch/main/config/defaults.hjson). Este archivo también contiene la documentación de todas las opciones disponibles. Para anular los valores predeterminados, puedes copiar las opciones que deseas cambiar dentro de tu archivo local `config.hjson`.

Los archivos `defaults.hjson` y `config.hjson` se encuentran en `config/defaults.hjson` y `config/config.hjson`, respectivamente. Para cambiar estas localizaciones predeterminadas, puedes establecer las siguientes variables de entorno: 

- LEMMY_CONFIG_LOCATION # config.hjson
- LEMMY_CONFIG_DEFAULTS_LOCATION # defaults.hjson

Adicionalmente, puedes sobrescribir cualquier archivo de configuración con las variables de entorno. Éstas tienen el mismo nombre que las opciones de configuración, llevando el prefijo `LEMMY_`. Por ejemplo, puedes sobrescribir el `database.password` con `LEMMY_DATABASE__POOL_SIZE=10`.

Una opción adicional `LEMMY_DATABASE_URL` está disponible, la cual puede ser usada con una cadena de conexión PostgreSQL como `postgres://lemmy:password@lemmy_db:5432/lemmy`, pasando todos los detalles de la conexión a la vez.

Si no se utiliza el contenedor Docker, cree manualmente la base de datos especificada anteriormente ejecutando los siguientes comandos:

```bash
cd server
./db-init.sh
```
