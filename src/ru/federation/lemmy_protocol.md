# Протокол Федерации в Lemmy

Протокол Lemmy (или протокол Lemmy Federation) - это строгое подмножество [протокола ActivityPub](https://www.w3.org/TR/activitypub/). Любое отклонение от протокола ActivityPub является ошибкой в Lemmy или в этой документации (или в обоих). 

Этот документ предназначен для разработчиков, знакомых с протоколами ActivityPub и ActivityStreams. Он дает подробное описание моделей акторов, объектов и действий, используемых Lemmy.

Прежде чем читать это, взгляните на наш [Обзор федерации](Contributing_federation_overview.md), чтобы получить представление о том, как федерация Lemmy работает на высшем уровне. 

Lemmy еще не во всех отношениях следует спецификации ActivityPub. Например, мы не устанавливаем допустимый контекст, указывающий на наши поля контекста. Мы также игнорируем такие поля, как «inbox», «outbox» или «endpoints» для удалённых участников и предполагаем, что все принадлежит Lemmy. Для обзора девиаций прочтите  [#698](https://github.com/LemmyNet/lemmy/issues/698). Они будут исправлены в ближайшее время.

Lemmy также не очень гибкий, когда речь идет о входящих действиях и объектах. Они должны быть в точности идентичны приведенным ниже примерам. Такие вещи, как наличие массива вместо одного значения или идентификатора объекта вместо полного объекта, приведут к ошибке.

В следующих таблицах «обязательный» означает, будет ли Lemmy принимать входящие действия без этого поля. Сам Lemmy всегда будет включать все непустые поля. 

<!-- toc -->

- [Аннотация](#аннотация)
- [Акторы](#Акторы)
  * [Сообщество](#Сообщество)
    + [Исходящие Сообщения Сообщества](#Исходящие-Сообщения-Сообщества)
    + [Подписчики Сообщества](#Подписчики-Сообщества)
    + [Модераторы Сообщества](#Модераторы-Сообщества)
  * [Пользователь](#Пользователь)
    + [Входящие Пользователя](#Входящие-Пользователя)
- [Объект](#объект)
  * [Пост](#пост)
  * [Комментарий](#комментарий)
  * [Личное сообщение](#личное-сообщение)
- [Виды активности](#виды-активности)
  * [Пользователь в Сообществе](#пользователь-в-сообществе)
    + [Следовать](#следовать)
    + [Отписаться](#отписаться)
    + [Создать или Обновить Сообщение](#создать-или-обновить-сообщение)
    + [Создать или Обновить Комментарий](#создать-или-обновить-комментарий)
    + [Понравилось Сообщение или Комментарий](#понравилось-сообщение-или-комментарий)
    + [Сообщение или Комментарий не нравится](#сообщение-или-комментарий-не-нравится)
    + [Удалить Пост или Комментарий](#удалить-пост-или-комментарий)
    + [Убрать Пост или Комментарий](#remove-post-or-comment)
    + [Отмена](#отмена)
  * [Сообщество для Пользователя](#сообщество-для-пользователя)
    + [Принятие Подписки ](#принятие-подписки )
    + [Публикация](#публикация)
    + [Убрать или Удалить Сообщество](#убрать-или-удалить-сообщество)
    + [Восстановить Убранное или Удалённое Сообщество](#восстановить-убранное-или-удалённое-сообщество)
  * [От Пользователя к Пользователю](#от-пользователя-к-пользователю)
    + [Создать или Обновить личное сообщение](#создать-или-обновить-личное-сообщение)
    + [Удалить Личное Сообщение](#удалить-личное-сообщение)
    + [Отмена Удаления Личного Сообщения](#отмена-удаления-личного-сообщения)⏎

<!-- tocstop -->

## Аннотация

```json
{
    "@context": [
        "https://www.w3.org/ns/activitystreams",
        {
            "moderators": "as:moderators",
            "sc": "http://schema.org#",
            "stickied": "as:stickied",
            "sensitive": "as:sensitive",
            "pt": "https://join.lemmy.ml#",
            "comments_enabled": {
                "type": "sc:Boolean",
                "id": "pt:commentsEnabled"
            }
        },
        "https://w3id.org/security/v1"
    ]
}
```
 Аннотация одинакова для всех действий и объектов. 

## Акторы

### Сообщество

Автоматизированный актор. Пользователи могут отправлять сообщения или комментарии к нему, которые сообщество пересылает своим подписчикам в виде `Announce`.

Отправляет действия пользователю: `Accept/Follow`, `Announce`

:Получает действия от пользователя: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (только администратор/модератор), `Delete` (только создатель), `Undo` (только для собственных действий)

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/c/main",
    "type": "Group",
    "preferredUsername": "main",
    "name": "The Main Community",
    "sensitive": false,
    "content": "Welcome to the default community!",
    "mediaType": "text/html",
    "source": {
        "content": "Welcome to the default community!",
        "mediaType": "text/markdown"
    },
    "icon": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/Z8pFFb21cl.png"
    },
    "image": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/Wt8zoMcCmE.jpg"
    },
    "inbox": "https://enterprise.lemmy.ml/c/main/inbox",
    "outbox": "https://enterprise.lemmy.ml/c/main/outbox",
    "followers": "https://enterprise.lemmy.ml/c/main/followers",
    "moderators": "https://enterprise.lemmy.ml/c/main/moderators",
    "endpoints": {
        "sharedInbox": "https://enterprise.lemmy.ml/inbox"
    },
    "published": "2020-10-06T17:27:43.282386+00:00",
    "updated": "2020-10-08T11:57:50.545821+00:00",
    "publicKey": {
        "id": "https://enterprise.lemmy.ml/c/main#main-key",
        "owner": "https://enterprise.lemmy.ml/c/main",
        "publicKeyPem": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA9JJ7Ybp/H7iXeLkWFepg\ny4PHyIXY1TO9rK3lIBmAjNnkNywyGXMgUiiVhGyN9yU7Km8aWayQsNHOkPL7wMZK\nnY2Q+CTQv49kprEdcDVPGABi6EbCSOcRFVaUjjvRHf9Olod2QP/9OtX0oIFKN2KN\nPIUjeKK5tw4EWB8N1i5HOuOjuTcl2BXSemCQLAlXerLjT8xCarGi21xHPaQvAuns\nHt8ye7fUZKPRT10kwDMapjQ9Tsd+9HeBvNa4SDjJX1ONskNh2j4bqHHs2WUymLpX\n1cgf2jmaXAsz6jD9u0wfrLPelPJog8RSuvOzDPrtwX6uyQOl5NK00RlBZwj7bMDx\nzwIDAQAB\n-----END PUBLIC KEY-----\n"
    }
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `preferredUsername` | да | Имя актора | 
| `name` | да | Название сообщества |
| `sensitive` | да | Правда указывает на то, что все сообщения в сообществе NSFW |
| `attributedTo` | да | Сначала создатель сообщества, затем все остальные модераторы |
| `content` | нет | Текст для боковой панели сообщества, обычно содержащий описание и правила |
| `icon` | нет | Значок, отображаемый рядом с названием сообщества |
| `image` | нет | Изображение баннера, отображаемое вверху страницы сообщества |
| `inbox` | нет | URL-адрес папки входящих сообщений ActivityPub |
| `outbox` | нет | URL-адрес исходящего сообщения ActivityPub, содержит только до 20 последних сообщений, без комментариев, голосов или других действий |
| `followers` | нет | URL-адрес коллекции подписчиков, содержит только количество подписчиков, без ссылок на отдельных подписчиков |
| `endpoints` | нет | Содержит URL общего почтового ящика |
| `published` | нет | Дата и время, когда сообщество было впервые создано |
| `updated` | нет | Дата и время последнего изменения сообщества |
| `publicKey` | да | Открытый ключ, используемый для проверки подписей этого актора |
   
#### Исходящие Сообщения Сообщества 

```json
{
    "@context": ...,
    "items": [
      ...
    ],
    "totalItems": 3,
    "id": "https://enterprise.lemmy.ml/c/main/outbox",
    "type": "OrderedCollection"
}
```

Исходящие содержат только `Create/Post` мероприятия на данный момент.

#### Подписчики Сообщества

```json
{
  "totalItems": 2,
  "@context": ...,
  "id": "https://enterprise.lemmy.ml/c/main/followers",
  "type": "Collection"
}
```

Коллекция подписчиков используется только для отображения количества подписчиков. Идентификаторы участников не включены, чтобы защитить конфиденциальность пользователей.

#### Модераторы Сообщества

```json
{
    "items": [
        "https://enterprise.lemmy.ml/u/picard",
        "https://enterprise.lemmy.ml/u/riker"
    ],
    "totalItems": 2,
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/c/main/moderators",
    "type": "OrderedCollection"
}
```

### Пользователь

Человек взаимодействует в первую очередь с сообществом, в котором он отправляет и получает сообщения / комментарии. Также может создавать и модерировать сообщества, а также отправлять личные сообщения другим пользователям.

Отправляет действия в Сообщество: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (только администратор/модератор), `Delete` (только создатель), `Undo` (только для собственных действий)

Получает действия от сообщества: `Accept/Follow`, `Announce`

Отправляет и получает действия от/для других пользователей: `Create/Note`, `Update/Note`, `Delete/Note`, `Undo/Delete/Note` (все, что связано с личными сообщениями)

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/u/picard",
    "type": "Person",
    "preferredUsername": "picard",
    "name": "Jean-Luc Picard",
    "content": "The user bio",
    "mediaType": "text/html",
    "source": {
        "content": "The user bio",
        "mediaType": "text/markdown"
    },
    "icon": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/DS3q0colRA.jpg"
    },
    "image": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/XenaYI5hTn.png"
    },
    "inbox": "https://enterprise.lemmy.ml/u/picard/inbox",
    "endpoints": {
        "sharedInbox": "https://enterprise.lemmy.ml/inbox"
    },
    "published": "2020-10-06T17:27:43.234391+00:00",
    "updated": "2020-10-08T11:27:17.905625+00:00",
    "publicKey": {
        "id": "https://enterprise.lemmy.ml/u/picard#main-key",
        "owner": "https://enterprise.lemmy.ml/u/picard",
        "publicKeyPem": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyH9iH83+idw/T4QpuRSY\n5YgQ/T5pJCNxvQWb6qcCu3gEVigfbreqZKJpOih4YT36wu4GjPfoIkbWJXcfcEzq\nMEQoYbPStuwnklpN2zj3lRIPfGLht9CAlENLWikTUoW5kZLyU6UQtOGdT2b1hDuK\nsUEn67In6qYx6pal8fUbO6X3O2BKzGeofnXgHCu7QNIuH4RPzkWsLhvwqEJYP0zG\nodao2j+qmhKFsI4oNOUCGkdJejO7q+9gdoNxAtNNKilIOwUFBYXeZJb+XGlzo0X+\n70jdJ/xQCPlPlItU4pD/0FwPLtuReoOpMzLi20oDsPXJBvn+/NJaxqDINuywcN5p\n4wIDAQAB\n-----END PUBLIC KEY-----\n"
    }
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `preferredUsername` | да | Имя Актора |
| `name` | нет | Отображаемое имя пользователя |
| `content` | нет | БИО пользователя |
| `icon` | нет | Аватар пользователя, отображаемый рядом с именем пользователя |
| `image` | нет | Баннер пользователя, отображаемый в верхней части профиля |
| `inbox` | нет | URL-адрес папки входящих сообщений ActivityPub |
| `endpoints` | нет | Содержит URL общего почтового ящика |
| `published` | нет | Дата и время, когда пользователь зарегистрировался |
| `updated` | нет | Дата и время последнего изменения профиля пользователя |
| `publicKey` | да | Открытый ключ используется для проверки подписей из этого актора |

#### Входящие Пользователя 

```json
{
    "items": [],
    "totalItems": 0,
    "@context": ...,
    "id": "http://lemmy-alpha:8541/u/lemmy_alpha/outbox",
    "type": "OrderedCollection"
}
```

Папка для входящих сообщений пользователя еще не реализована и является лишь заполнителем для реализаций ActivityPub, которые в ней нуждаются. 

## Объект

### Пост

Страница с заголовком и необязательным URL-адресом и текстовым содержимым. URL-адрес часто ведет к изображению и в этом случае включается эскиз. Каждый пост принадлежит ровно одному сообществу.

```json
{
    "@context": ...,
    "id": "https://voyager.lemmy.ml/post/29",
    "type": "Page",
    "attributedTo": "https://voyager.lemmy.ml/u/picard",
    "to": [
      "https://voyager.lemmy.ml/c/main",
      "https://www.w3.org/ns/activitystreams#Public"
    ],
    "name": "Test thumbnail 2",
    "content": "blub blub",
    "mediaType": "text/html",
    "source": {
        "content": "blub blub",
        "mediaType": "text/markdown"
    },
    "url": "https://voyager.lemmy.ml:/pictrs/image/fzGwCsq7BJ.jpg",
    "image": {
        "type": "Image",
        "url": "https://voyager.lemmy.ml/pictrs/image/UejwBqrJM2.jpg"
    },
    "commentsEnabled": true,
    "sensitive": false,
    "stickied": false,
    "published": "2020-09-24T17:42:50.396237+00:00",
    "updated": "2020-09-24T18:31:14.158618+00:00"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `attributedTo` | да | Идентификатор пользователя, который создал этот пост |
| `to` | да | Идентификатор сообщества, в котором оно было опубликовано |
| `name` | да | Заголовок сообщения |
| `content` | нет | Тело сообщения |
| `url` | нет | Произвольная ссылка, которой нужно поделиться |
| `image` | нет | Миниатюра для `url`, присутствует только в том случае, если это ссылка на изображение |
| `commentsEnabled` | да | Значение false означает, что публикация заблокирована и комментарии к ней добавить нельзя |
| `sensitive` | да | True отмечает сообщение как NSFW, размывает миниатюру и скрывает ее от пользователей с отключенной настройкой NSFW |
| `stickied` | да | True означает, что оно отображается в верхней части сообщества |
| `published` | нет | Дата и время создания сообщения |
| `updated` | нет | Дата и время, когда сообщение было отредактировано (отсутствует, если оно никогда не редактировалось) |

### Комментарий

Ответ на сообщение или ответ на другой комментарий. Содержит только текст (включая ссылки на других пользователей или сообщества). Lemmy отображает комментарии в виде древовидной структуры.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/comment/95",
    "type": "Note",
    "attributedTo": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "content": "mmmk",
    "mediaType": "text/html",
    "source": {
        "content": "mmmk",
        "mediaType": "text/markdown"
    },
    "inReplyTo": [
        "https://enterprise.lemmy.ml/post/38",
        "https://voyager.lemmy.ml/comment/73"
    ],
    "published": "2020-10-06T17:53:22.174836+00:00",
    "updated": "2020-10-06T17:53:22.174836+00:00"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `attributedTo` | да | Идентификатор пользователя, создавшего комментарий |
| `to` | да | Сообщество, в котором был сделан комментарий |
| `content` | да | Текст комментария |
| `inReplyTo` | да | Идентификатор поста, в которой был сделан этот комментарий, и родительского комментария. Если это комментарий верхнего уровня,  `inReplyTo` содержит только сообщение |
| `published` | нет | Дата и время создания комментария |
| `updated` | нет | Дата и время, когда комментарий был отредактирован (отсутствует, если он никогда не редактировался) |

### Личное сообщение

Прямое сообщение от одного пользователя другому. Не могу включать дополнительных пользователей. Поток еще не реализован, поэтому поле `inReplyTo` отсутствует.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/private_message/34",
    "type": "Note",
    "attributedTo": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://voyager.lemmy.ml/u/janeway",
    "content": "test",
    "source": {
        "content": "test",
        "mediaType": "text/markdown"
    },
    "mediaType": "text/markdown",
    "published": "2020-10-08T19:10:46.542820+00:00",
    "updated": "2020-10-08T20:13:52.547156+00:00"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `attributedTo` | Идентификатор пользователя, создавшего это личное сообщение  |
| `to` | Идентификатор получателя |
| `content` | да | Текст личного сообщения |
| `published` | нет | Дата и время создания сообщения |
| `updated` | нет | Дата и время, когда сообщение было отредактировано (отсутствует, если оно никогда не редактировалось) |

## Виды активности

### Пользователь в Сообществе

#### Следовать

Когда пользователь нажимает "Подписаться" в сообществе,  `Follow` отправляется. Сообщество автоматически отвечает `Accept/Follow`.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/follow/2e4784b7-4edf-4fa1-a352-674d5d5f8891",
    "type": "Follow",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://ds9.lemmy.ml/c/main",
    "object": "https://ds9.lemmy.ml/c/main"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `actor` | да | Пользователь, отправляющий запрос на отслеживание |
| `object` | да | Сообщество, за которым нужно следить |

#### Отписаться

Нажатие на кнопку отказа от подписки в сообществе вызывает отправку сообщения `Undo/Follow`. Сообщество удаляет пользователя из списка подписчиков после его получения. 

```json
{
    "@context": ...,
    "id": "http://lemmy-alpha:8541/activities/undo/2c624a77-a003-4ed7-91cb-d502eb01b8e8",
    "type": "Undo",
    "actor": "http://lemmy-alpha:8541/u/lemmy_alpha",
    "to": "http://lemmy-beta:8551/c/main",
    "object": {
        "@context": ...,
        "id": "http://lemmy-alpha:8541/activities/follow/f0d732e7-b1e7-4857-a5e0-9dc83c3f7ee8",
        "type": "Follow",
        "actor": "http://lemmy-alpha:8541/u/lemmy_alpha",
        "object": "http://lemmy-beta:8551/c/main"
    }
}
```

#### Создать или Обновить Сообщение

Когда пользователь создает новый пост, он отправляется в соответствующее сообщество. Редактирование ранее созданного сообщения вызывает почти идентичную активность, за исключением `type` являющейся `Update`. Мы пока не поддерживаем упоминания в сообщениях.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/create/6e11174f-501a-4531-ac03-818739bfd07d",
    "type": "Create",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "https://ds9.lemmy.ml/c/main/"
    ],
    "object": ...
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `type` | да | либо `Create` или `Update` |
| `cc` | да | Сообщество, в котором пишется пост |
| `object` | да | Пост создается |

#### Создать или Обновить Комментарий

Ответ на сообщение или другой комментарий. Может содержать упоминания других пользователей. Редактирование ранее созданного сообщения вызывает почти идентичную активность, за исключением  `type` являющейся `Update`.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/create/6f52d685-489d-4989-a988-4faedaed1a70",
    "type": "Create",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "tag": [{
        "type": "Mention",
        "name": "@sisko@ds9.lemmy.ml",
        "href": "https://ds9.lemmy.ml/u/sisko"
    }],
    "cc": [
        "https://ds9.lemmy.ml/c/main/",
        "https://ds9.lemmy.ml/u/sisko"
    ],
    "object": ...
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `tag` | нет | Список пользователей, упомянутых в комментарии (например `@user@example.com`) |
| `cc` | да | Сообщество, в котором создается публикация, пользователь, которому отвечает (создатель родительской публикации / комментария), а также любые упомянутые пользователи |
| `object` | да | Создаваемый комментарий |

#### Понравилось Сообщение или Комментарий

Голосоывание за публикацию или комментарий.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/like/8f3f48dd-587d-4624-af3d-59605b7abad3",
    "type": "Like",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/p/123"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `cc` | да | Идентификатор сообщества, в котором размещён пост/комментарий  |
| `object` | да | За публикацию или комментарий проголосовали |

#### Сообщение или Комментарий не нравится

Голос против публикации или комментария.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/dislike/fd2b8e1d-719d-4269-bf6b-2cadeebba849",
    "type": "Dislike",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/p/123"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `cc` | да | Идентификатор сообщества, в котором размещён пост/комментарий  |
| `object` | да | За публикацию или комментарий проголосовали |

#### Удалить Пост или Комментарий

Удаляет ранее созданный пост или комментарий. Это может сделать только первоначальный создатель этого сообщения/комментария. 

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/delete/f1b5d57c-80f8-4e03-a615-688d552e946c",
    "type": "Delete",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://enterprise.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/post/32"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `cc` | да | Идентификатор сообщества, в котором размещён пост/комментарий |
| `object` | да | Идентификатор удаляемой записи или комментария |

#### Убрать Пост или Комментарий

Убирает пост или комментарий. Это может быть сделано только модератором сообщества или администратором инстанса, где размещено сообщество. 

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/remove/aab93b8e-3688-4ea3-8212-d00d29519218",
    "type": "Remove",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/comment/32"
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `cc` | да | Идентификатор сообщества, в котором размещён пост/комментарий |
| `object` | да | Идентификатор удаляемой записи или комментария |

#### Отмена

Отменяет предыдущее действие, может быть выполнено только `actor` `object`. В случае `Like` или `Dislike` подсчет голосов возвращается обратно. В случае `Delete` или `Remove` пост/комментарий восстанавливается. `object` создается заново, так как идентификатор действия и другие поля отличаются.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/undo/70ca5fb2-e280-4fd0-a593-334b7f8a5916",
    "type": "Undo",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": ...
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `object` | да | Любая `Like`, `Dislike`, `Delete` или `Remove` активности как описано выше |

#### Добавить Модератора

Добавление нового модератора (зарегистрированного на `ds9.lemmy.ml`) в сообществе `!main@enterprise.lemmy.ml`. Должно быть отправлено существующим модератором сообщества.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/add/531471b1-3601-4053-b834-d26718da2a06",
    "type": "Add",
    "cc": [
        "https://enterprise.lemmy.ml/c/main"
    ],
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "object": "https://ds9.lemmy.ml/u/sisko",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "target": "https://enterprise.lemmy.ml/c/main/moderators"
}
```

#### Убрать Модератора

Удаление существующего модератора из сообщества. Должено быть отправлено существующим модератором сообщества. 

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/remove/63b9a5b2-d3f8-4371-a7eb-711c7928b3c0",
    "type": "Remove",
    "object": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "cc": [
        "https://enterprise.lemmy.ml/c/main"
    ],
    "target": "https://enterprise.lemmy.ml/c/main/moderators"
}
```
### Сообщество для Пользователя

#### Принятие Подписки 

Автоматически отправляется сообществом в ответ на `Follow`. В то же время сообщество добавляет этого пользователя в свой список подписчиков.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/accept/5314bf7c-dab8-4b01-baf2-9be11a6a812e",
    "type": "Accept",
    "actor": "https://ds9.lemmy.ml/c/main",
    "to": "https://enterprise.lemmy.ml/u/picard",
    "object": {
        "@context": ...,
        "id": "https://enterprise.lemmy.ml/activities/follow/2e4784b7-4edf-4fa1-a352-674d5d5f8891",
        "type": "Follow",
        "object": "https://ds9.lemmy.ml/c/main",
        "actor": "https://enterprise.lemmy.ml/u/picard"
    }
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `actor` | да | То же сообщество, что и в `Follow` активность |
| `to` | нет | Идентификатор пользователя, отправившего  `Follow` |
| `object` | да | Ранее отправленные `Follow` активность |

#### Публикация

Когда сообщество получает сообщение или комментарий, оно помещает его в `Announce` и отправляет его всем подписчикам. 

```json
{
  "@context": ...,
  "id": "https://ds9.lemmy.ml/activities/announce/b98382e8-6cb1-469e-aa1f-65c5d2c31cc4",
  "type": "Announce",
  "actor": "https://ds9.lemmy.ml/c/main",
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "cc": [
    "https://ds9.lemmy.ml/c/main/followers"
  ],
  "object": ...
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `object` | да | Любая из `Create`, `Update`, `Like`, `Dislike`, `Delete` `Remove` или `Undo` активности описанная в [Пользователь в Сообществе](#пользователь-в-сообществе) секции |

#### Убрать или Удалить Сообщество

Администратор инстанса или модератор могут удалять сообщества. 

```json
{
  "@context": ...,
  "id": "http://ds9.lemmy.ml/activities/remove/e4ca7688-af9d-48b7-864f-765e7f9f3591",
  "type": "Remove",
  "actor": "http://ds9.lemmy.ml/c/some_community",
  "cc": [
    "http://ds9.lemmy.ml/c/some_community/followers"
  ],
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "object": "http://ds9.lemmy.ml/c/some_community"
}
```


| Имя в поле | Обязательно | Описание |
|---|---|---|
| `type` | да | Либо `Remove` или `Delete` |

#### Восстановить Убранное или Удалённое Сообщество

Отменяет убранное сообщество или удалённое. 

```json
{
  "@context": ...,
  "id": "http://ds9.lemmy.ml/activities/like/0703668c-8b09-4a85-aa7a-f93621936901",
  "type": "Undo",
  "actor": "http://ds9.lemmy.ml/c/some_community",
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "cc": [
    "http://ds9.lemmy.ml/c/testcom/followers"
  ],
  "object": {
    "@context": ...,
    "id": "http://ds9.lemmy.ml/activities/remove/1062b5e0-07e8-44fc-868c-854209935bdd",
    "type": "Remove",
    "actor": "http://ds9.lemmy.ml/c/some_community",
    "object": "http://ds9.lemmy.ml/c/testcom",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "http://ds9.lemmy.ml/c/testcom/followers"
    ]
  }
}

```
| Имя в поле | Обязательно | Описание |
|---|---|---|
| `object.type` | да | Либо `Remove` или `Delete` |

### От Пользователя к Пользователю

#### Создать или Обновить личное сообщение

Создание нового личного сообщения между двумя пользователями.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/create/202daf0a-1489-45df-8d2e-c8a3173fed36",
    "type": "Create",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": ...
}
```

| Имя в поле | Обязательно | Описание |
|---|---|---|
| `type` | да | Либо `Create` или `Update` |
| `object` | да | [Личное сообщение](#личное-сообщение) |

#### Удалить Личное Сообщение 

Удаляет предыдущее личное сообщение.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/delete/2de5a5f3-bf26-4949-a7f5-bf52edfca909",
    "type": "Delete",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": "https://ds9.lemmy.ml/private_message/341"
}
```

#### Отмена Удаления Личного Сообщения

Восстанавливает ранее удалённое личное сообщение. Объект создается заново, так как идентификатор действия и другие поля отличаются. 

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/undo/b24bc56d-5db1-41dd-be06-3f1db8757842",
    "type": "Undo",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": ...
}
```
