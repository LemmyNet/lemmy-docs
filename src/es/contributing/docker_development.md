# Desarrollo con Docker

## Dependencias

### Distro basada en Debian

```bash
sudo apt install git docker-compose
sudo systemctl start docker
git clone https://github.com/LemmyNet/lemmy
```

### Distro basada en Arch

```bash
sudo -S git docker-compose
sudo systemctl start docker
git clone https://github.com/LemmyNet/lemmy
```

## Ejecución

```bash
cd docker/dev
./docker_update.sh
```

Finalmente abre la siguiente dirección en tu navegador: `http://localhost:1235`.

**Nota:** muchas características (como docs e imagenes) no funcionarán sin usar un perfil de nginx como en `ansible/templates/nginx.conf`.

Para acelerar la compilación de Docker, añade el siguiente código a `/etc/docker/daemon.json` y reinicia Docker.

```
{
  "features": {
    "buildkit": true
  }
}
```

Si la compilación sigue siendo muy lenta, tendrás que usar un [desarrollo local](local_development.md) en su lugar.
