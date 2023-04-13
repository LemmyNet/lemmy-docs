# Instalar desde Cero

> ⚠️ **Descargo de responsabilidad:** este método de instalación no está recomendado por los desarrolladores de Lemmy. Si tienes algún problema, debes resolverlo tú mismo o preguntar a los respectivos autores. Si observas algún fallo de Lemmy en una instancia instalada de este modo, por favor, menciónalo en el informe de fallos.

## Instalando Lemmy desde el código fuente

Instrucciones para instalar Lemmy de forma Nativa, sin depender de docker. Originalmente fue publicado en [Some resources on setting Lemmy up from source - Lemmy dot C.A.](https://lemmy.ca/post/1066) **La transcripción actual se ha adaptado para mejorar su legibilidad**.

### Importante

> Las referencias de los paquetes de software a continuación **son todas basadas en Gentoo** - Hay información en los archivos de docker sobre lo que se requiere en los sistemas tipo debian, y para cualquier otra cosa probablemente podrás ajustar fácilmente como sea necesario.

Ten en cuenta que la construcción de Lemmy requiere de una gran cantidad de recursos de hardware. Si quieres ejecutar Lemmy en un pequeño VPS con una memoria RAM muy limitada (que parece una forma perfectamente aceptable para ejecutar una instancia de producción), es mejor seguir con la imagen docker, o usar un sistema que tenga más RAM. El uso de RAM es enorme con las builds de Rust.

Las versiones de etiqueta/lanzamiento incluidas en esta nota provienen de lemmy/docker/prod/docker-compose.yml y estaban actualizadas en el momento en que se creó este documento. **Definitivamente ajustar a las versiones apropiadas como sea necesario**.

Tuve que cambiar de usar `sudo` a `su` en algunos lugares ya que el usuario estaba haciendo algo raro/incompleto con el env de sudo para pictrs

## Configuración

| Dependencias |                                           |
| ------------ | ----------------------------------------- |
| app-admin    | sudo                                      |
| dev-vcs      | [git](https://git-scm.com/)               |
| dev-lang     | [rust](https://www.rust-lang.org/)        |
| dev-db       | [postgresql](https://www.postgresql.org/) |
| www-servers  | [nginx](https://nginx.org/en/)            |
| sys-apps     | [yarn](https://yarnpkg.com/)              |
| app-shells   | bash-completion                           |
|              |                                           |

### Poner en marcha el postgresql

```bash
emerge --config dev-db/postgresql
rc-service postgresql-12 start
useradd -m -s /bin/bash lemmy
cd ~lemmy
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy.git
cd lemmy
```

### Lista las etiquetas(tags)/lanzamientos(releases) disponibles

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.11.0
```

### Build para producción? (Remover --release para dev)

```bash
sudo -Hu lemmy cargo build --release
cd ..
sudo -Hu lemmy git clone https://github.com/LemmyNet/lemmy-ui.git
cd lemmy-ui
```

### Lista las etiquetas(tags)/lanzamientos(releases) disponibles

```bash
sudo -Hu lemmy git tag -l
sudo -Hu lemmy git checkout tags/v0.8.10
sudo -Hu lemmy git submodule init
sudo -Hu lemmy git submodule update --remote
```

### Construir el frontend

#### Esto es para desarrollo

```bash
sudo -Hu lemmy yarn
```

#### Esto es para producción

```bash
sudo -Hu lemmy yarn install --pure-lockfile
sudo -Hu lemmy yarn build:prod
```

**Esto es solo para correr un entorno de desarrollo, pero creo que es preferible para producción - usar el script de inicio**

```bash
sudo -Hu lemmy yarn dev
```

Para producción, usaremos el [script de inicio](#initlemmy), pero el comando para producción es:

```bash
sudo -Hu node dist/js/server.js
```

### Configurar la base de datos

#### Ajustar la contraseña:

```bash
sudo -u postgres psql -c "create user lemmy with password 'password' superuser;" -U postgres
sudo -u postgres psql -c 'create database lemmy with owner lemmy;' -U postgres
```

### Instalar iFramely

Son requeridos git y nodejs, pero nodejs debe ser instalado como dependencia de yarn.

#### En caso de que iFramely sea instalado en otro sistema

```bash
useradd -m -s /bin/bash iframely

cd ~iframely
sudo -Hu iframely git clone https://github.com/itteco/iframely.git
cd iframely
sudo -Hu iframely git tag -l
sudo -Hu iframely git checkout tags/v1.5.0
sudo -Hu iframely npm install
```

**Opcional** Remplazar puerto 80 por 8061; también remplazar o desabilitar el almacenamiento del cache por ahora (CACHE_ENGINE: 'no-cache')

```bash
sudo -Hu iframely cp ~lemmy/lemmy/docker/iframely.config.local.js ~lemmy/iframely/config.local.js
```

Iniciar el servidor iframely o, usar un [script de inicio](#initiframely) en su lugar, el cual es la mejor opción que correr esto manualmente.

```bash
sudo -Hu iframely node server
```

### Instalar pict-rs

```bash
useradd -m -s /bin/bash pictrs
cp target/release/pict-rs .
```

Añadido **hdri** ya que **magick_rust** falla al compilar si no está. Mencionado en [error[E0425]: cannot find value QuantumRange in module bindings](https://github.com/nlfiedler/magick-rust/issues/40)

```bash
echo "media-gfx/imagemagick hdri jpeg lzma png webp" >> /etc/portage/package.use
echo "*/* -llvm_targets_NVPTX -llvm_targets_AMDGPU" >> /etc/portage/package.use

```

Instalar paquetes extra requeridos para pict-rs:

| Paquetes    |                                                  |
| ----------- | ------------------------------------------------ |
| media-libs  | [gexiv2](https://gitlab.gnome.org/GNOME/gexiv2)  |
| media-gfx   | [imagemagick](https://imagemagick.org/index.php) |
| media-video | [ffmpeg](https://ffmpeg.org/)                    |
| sys-devel   | [clang](https://clang.llvm.org/)                 |

Paquetes requeridos para pict-rs (en caso de un sistema separado):

| Paquetes |                                    |
| -------- | ---------------------------------- |
| dev-lang | [rust](https://www.rust-lang.org/) |

**Opcional** Hacer un script o ejecutarlo manualmente como usuario.

```bash
su - pictrs
git clone https://git.asonix.dog/asonix/pict-rs.git
cd pict-rs
git tag -l
git checkout tags/v0.2.5-r0

cargo build --release
cp target/release/pict-rs .
cd ~pictrs
mkdir pictrs-data
```

**Falta algo en el README de pict-rs - creó y utilaza una carpeta pict-rs in /tmp**

Si haces algo raro como yo (cambiar el usuario con el que se ejecuta pict-rs) y terminas con problemas de permisos (que los registros no te dicen _Qué_ está teniendo un problema de permisos), este podría ser tu problema. Además, el tiempo dirá si esta carpeta se limpia adecuadamente o no.

Ejecutar pictrs de acuerdo a la siguiente línea:

```bash
pict-rs/pict-rs -a 127.0.0.1:9000 -p ~pictrs/pictrs-data/
```

Pero sólo usaremos el script init.

En este punto, corre todo a través de los [scripts de inicio](#scripts-de-inicio-init-scripts). Configura los scripts de inicio para que se ejecuten en el tiempo de arranque. Presumiblemente has configurado nginx y puedes llegar a tu instancia.

---

## Actualizando

```bash
su - lemmy
cd lemmy
```

Haz BACKUP [config/config.hjson](#configuración-1) en algún lugar.

```bash
git fetch
git tag -l
git checkout tags/WHATEVER

cargo build --release

cd ~/lemmy-ui
```

### Lista las etiquetas(tags)/lanzamientos(releases) disponibles

```bash
git fetch
git tag -l
git checkout tags/WHATEVER
git submodule update --remote
```

### Construir el frontend

#### Esto es para producción

```bash
yarn install --pure-lockfile   # Is this step really needed?
#yarn upgrade --pure-lockfile  # ?? Did I get it?
#yarn   # Is this step really needed?  One of these steps is for sure. (Should be unnecessary)
yarn build:prod
```

Reiniciar lemmy-ui

### Actualizar iFramely

```bash
su - iframely
cd iframely
git fetch
git tag -l
git checkout tags/v1.6.0  # Or whatever the current appropriate release is
npm install
```

Reinicia iframely

### Actualizar pict-rs

```bash
su - pictrs
cd pict-rs
git fetch
git tag -l
git checkout tags/v0.2.5-r0  # (or whatever is currently mentioned in the lemmy docker file)

cargo build --release
cp target/release/pict-rs .
```

Reinicia pictrs

---

## Índice

### configuración

ejemplo de config/config.hjson

```json
{
  database: {
    user: "lemmy"
    password: "whatever"
    host: "localhost"
    port: 5432
    database: "lemmy"
    pool_size: 5
  }
  hostname: "lemmy.ca"
  bind: "127.0.0.1"
  port: 8536
  docs_dir: "/home/lemmy/lemmy/docs/book"
  pictrs_url: "http://localhost:9000"
  iframely_url: "http://localhost:8061"
  federation: {
    enabled: true
    allowed_instances: ""
    blocked_instances: ""
  }
  email: {
    smtp_server: "localhost:25"
    smtp_from_address: "lemmy@lemmy.ca"
    use_tls: false
  }
}
```

### Scripts de inicio (init scripts)

##### init/iframely

```bash
#!/sbin/openrc-run

name="Iframely Daemon"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Iframely"
        start-stop-daemon --start --background --make-pidfile --user iframely --group iframely --pidfile /home/iframely/iframely.pid --chdir /home/iframely/iframely -3 /usr/bin/logger -4 /usr/bin/logger --exec node -- server
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/iframely/iframely.pid
        eend $?
}
```

##### init/lemmy

```bash
#!/sbin/openrc-run

name="Lemmy Backend"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Lemmy"
        start-stop-daemon --start --background --make-pidfile --user lemmy --group lemmy --pidfile /home/lemmy/lemmy.pid --chdir /home/lemmy/lemmy -3 /usr/bin/logger -4 /usr/bin/logger --exec ~lemmy/lemmy/target/release/lemmy_server
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/lemmy/lemmy.pid
        eend $?
}
```

##### init/lemmy-ui

```bash
#!/sbin/openrc-run

name="Lemmy UI"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting Lemmy UI"
        start-stop-daemon --start --background --make-pidfile --user lemmy --group lemmy --pidfile /home/lemmy/lemmy-ui.pid --chdir /home/lemmy/lemmy-ui -3 /usr/bin/logger -4 /usr/bin/logger --exec node dist/js/server.js --env LEMMY_INTERNAL_HOST=127.0.0.1:8536 --env LEMMY_EXTERNAL_HOST=lemmy.ca --env LEMMY_HTTPS=true
        eend $?
}
```

##### init/pict-rs

```bash
#!/sbin/openrc-run

name="pict-rs Daemon"

depend() {
        need localmount
        need net
}

start() {
        ebegin "Starting pictrs"
        start-stop-daemon --start --background --make-pidfile --user pictrs --group pictrs --pidfile /home/pictrs/pictrs.pid --chdir /home/pictrs/pict-rs -3 /usr/bin/logger -4 /usr/bin/logger --exec /home/pictrs/pict-rs/pict-rs -- -a 127.0.0.1:9000 -p ~pictrs/pictrs-data
        eend $?
}

stop() {
        start-stop-daemon --stop --signal TERM --pidfile /home/pictrs/pictrs.pid
        eend $?
}
```
