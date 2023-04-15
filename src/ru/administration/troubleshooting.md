# Решения проблем

Различные проблемы, которые могут возникнуть на новом инстансе и способы их решения.

Многие функции Lemmy зависят от правильной конфигурации reverse proxy. Убедитесь, что ваш, эквивалентен нашему конфигурационному файлу [nginx](https://github.com/LemmyNet/lemmy/blob/main/ansible/templates/nginx.conf).

## Главное

### Журналы

При возникновении проблем с интерфейсом проверьте [браузерную консоль](https://webmasters.stackexchange.com/a/77337) для любых сообщениях об ошибки.

Для журналов сервера запустите `docker-compose logs -f lemmy` в вашей инсталяционной папке. Вы также можете запустить `docker-compose logs -f lemmy lemmy-ui pictrs` для получения журнала от различных сервисов.

Если этого недостаточно, попробуйте изменить строку `RUST_LOG=error` в `docker-compose.yml` на `RUST_LOG=info` или `RUST_LOG=verbose`, затем сделайте `docker-compose restart lemmy`.

### Создание пользователя с правами администратора не работает

Убедитесь, что websocket работает правильно, проверив консоль браузера на наличие ошибок. В nginx для этого важны следующие заголовки:

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Ошибка ограничения скорости, когда на сайт заходят множество пользователей

Убедитесь, что заголовки `X-Real-IP` и `X-Forwarded-For` отправляются в Lemmy посредством reverse proxy. В противном случае он будет считать все действия в соответствии с ограничением скорости IP-адреса обратного прокси-сервера. В nginx это должно выглядеть так:

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Федерация

### Другие инстансы не могут получать локальные объекты (сообщество, пост и т.д.)

Ваш reverse proxy (например nginx) должен пересылать запросы с заголовком `Accept: application/activity+json` в бэкэнд. Это обрабатывается следующими строками:

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

Вы можете проверить, что он работает правильно, выполнив следующие команды, все они должны возвращать действительный JSON:

```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # the id of a local post
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # the id of a local comment
```

### Получение удаленных объектов работает, но публикации/комментирование в удаленных сообществах не успешны.

Проверьте это [федерация разрешена в обоих случаях](../federation/administration.md#instance-allowlist-and-blocklist).

Также убедитесь, что на вашем сервере установлено точное время. Действия подписываются меткой времени и будут отброшены, если она отключена более чем на 10 секунд.
