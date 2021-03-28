# Instalación con Docker

Asegúrate de tener instalados tanto docker como docker-compose(>=`1.24.0`). En Ubuntu, simplemente ejecuta `apt install docker-compose docker.io`. Siguiente, 

```bash
# crea una carpeta para los archivos de lemmy. La ubicación no importa, puede ser en cualquier sitio
mkdir /lemmy
cd /lemmy

# descarga los archivos de la configuración por defecto
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/lemmy.hjson
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/iframely.config.local.js

# Establece los permisos correctos para la carpeta pictrs
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

Abre tu `docker-compose.yml`, y asegúrate de que `LEMMY_EXTERNAL_HOST` para `lemmy-ui` esta configurado en el host correcto.

```
- LEMMY_INTERNAL_HOST=lemmy:8536
- LEMMY_EXTERNAL_HOST=your-domain.com
- LEMMY_HTTPS=false
```

Si quieres una contraseña de base de datos diferente, también debes cambiarla en el `docker-compose.yml` **antes** de tu primera ejecución.

Después de esto, echa un vistazo al [archivo de configuración](configuration.md) llamado `lemmy.hjson`, y ajústalo, en particular el nombre de host, y posiblemente la contraseña de la base de datos. Luego ejecute:

`docker-compose up -d`

puedes acceder a la interfaz de usuario de lemmy (lemmy-ui) en `http://localhost:1235`

Para hacer que Lemmy esté disponible fuera del servidor, necesitas configurar un proxy inverso, como Nginx. [Un ejemplo de configuración de ngix](https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf), podría ser establecido con:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf
# Remplaza los {{ valores }}
# El valor por defecto para lemmy_port es 8536
# El valor por defecto para lemmy_ui_port es 1235
sudo mv nginx.conf /etc/nginx/sites-enabled/lemmy.conf
```

También necesitarás configurar el TLS, por ejemplo con [Let's Encrypt](https://letsencrypt.org/). Después de esto necesitas reiniciar Nginx para recargar la configuración.

## Actualizar

Para actualizar a la versión más reciente, puedes cambiar manualmente la versión en `docker-compose.yml`. De manera alternativa puedes obtener la última versión de nuestro repositorio git:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
docker-compose up -d
```
