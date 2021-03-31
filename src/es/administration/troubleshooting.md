# Solución de Problemas

Se muestran diferentes problemas que pueden ocurrir en una nueva instancia, y cómo resolverlos.

Muchas características de Lemmy dependen de una correcta configuración del proxy inverso. Asegúrate de que tu configuración es equivalente a nuestra [configuración de nginx](https://github.com/LemmyNet/lemmy/blob/main/ansible/templates/nginx.conf).

## Generalidades

### Registros

Para los problemas del frontend, revisa la [consola del navegador](https://webmasters.stackexchange.com/a/77337) para ver si hay mensajes de error.

Para los registros del servidor, ejecuta `docker-compose logs -f lemmy` en tu carpeta de instalación. También puedes hacer `docker-compose logs -f lemmy lemmy-ui pictrs` para obtener los registros de los diferentes servicios.

Si eso no da suficiente información, intenta cambiar la línea `RUST_LOG=error` en `docker-compose.yml` a `RUST_LOG=info` o `RUST_LOG=verbose`, y luego hacer `docker-compose restart lemmy`.

### La creación del usuario administrador no funciona

Asegúrate de que el websocket está funcionando correctamente, revisa la consola del navegador en busca de errores. En nginx, las siguientes cabeceras son importantes para esto:

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Error de limite de velocidad cuando muchos usuarios acceden al sitio

Revisa que las cabeceras `X-Real-IP` y `X-Forwarded-For` son enviadas a Lemmy por el proxy inverso. De lo contrario, se contarán todas las acciones hacia el limite de velocidad de la IP del proxy inverso. En nginx debería verse así:

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Federación

### Otras instancias no pueden obtener objetos locales (comunidad, publicaciones, etc)

Tu proxy reverso (ejemplo nginx) necesita reenviar las solicitudes con la cabecera `Accept: application/activity+json` al backend. Esto es manejado por las siguientes líneas: 
```
set $proxpass "http://0.0.0.0:{{ lemmy_ui_port }}";
if ($http_accept = "application/activity+json") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
proxy_pass $proxpass;
```

Puedes probar que funciona correctamente ejecutando los siguientes comandos, todos ellos deberían devolver JSON válido:
```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # the id of a local post
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # the id of a local comment
```
### La obtención de objetos remotos funciona, pero publicar/comentar en comunidades remotas falla

Comprueba que la [federación está permitida en ambas instancias](../federation/administration.md#instance-allowlist-and-blocklist).

Asegúrate también de que la hora está ajustada con precisión en tu servidor. Las actividades están firmadas con una marca de tiempo, y serán descartadas si se desvía más de 10 segundos.
