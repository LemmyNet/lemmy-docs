# Установка Docker

Убедитесь в наличии установленных docker и docker-compose (>=`1.24.0`) . В Ubunu, просто запустите `apt install docker-compose docker.io`. Далее, 

```bash
# создайте папку для файлов lemmy. путь не имеет значения, размещайте файлы где угодно
mkdir /lemmy
cd /lemmy

# загрузите кнфигурацию по умолчанию
wget https://raw.githubusercontent.com/LemmyNet/lemmy/release/v0.16/docker/prod/docker-compose.yml
wget https://raw.githubusercontent.com/LemmyNet/lemmy/release/v0.16/docker/prod/lemmy.hjson

# Установите корректные разрешения для каталога pictrs
mkdir -p volumes/pictrs
sudo chown -R 991:991 volumes/pictrs
```

Откройте `docker-compose.yml`, и убедитесь в наличии `LEMMY_EXTERNAL_HOST` для `lemmy-ui` это позволит установить корректный host.

```
- LEMMY_INTERNAL_HOST=lemmy:8536
- LEMMY_EXTERNAL_HOST=your-domain.com
- LEMMY_HTTPS=false
```

Если хотите установить другой пароль для БД, вы также должны изменить его в `docker-compose.yml` **перед** первым запуском.

После этого, загляните [Кофигурационный файл](configuration.md) под названием `lemmy.hjson`, и настройте его, в частности hostname, и возможно пароль БД. Затем запустите:

`docker-compose up -d`

Вы можете войти в lemmy-ui через `http://localhost:1235`

Для того чтобы сделать Lemmy доступным в сети, вам необходимо настроить reverse proxy, например Nginx. [Пример конфигурации nginx](https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf), could be setup with:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/ansible/templates/nginx.conf
# Replace the {{ vars }}
# The default lemmy_port is 8536
# The default lemmy_ui_port is 1235
sudo mv nginx.conf /etc/nginx/sites-enabled/lemmy.conf
```

Вам также необходимо настроить TLS, например с [Let's Encrypt](https://letsencrypt.org/). После этого перезапустите Nginx для подгрузки конфигурации.

## Обновление

Для обновления до новой версии, вы можете изменить версию вручнуюy в `docker-compose.yml`. Как альтернатива, получите последнюю версию из нашего репозитария git:

```bash
wget https://raw.githubusercontent.com/LemmyNet/lemmy/main/docker/prod/docker-compose.yml
docker-compose up -d
```
