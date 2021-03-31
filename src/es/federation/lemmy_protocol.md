# Protocolo de la Federación Lemmy 

El protocolo de Lemmy (o Protocolo de la Federación Lemmy) es un subconjunto estricto del [Protocolo ActivityPub](https://www.w3.org/TR/activitypub/). Cualquier desviación del protocolo ActivityPub es un error (bug) en Lemmy o en esta documentación (o ambos).

Este documento está dirigido a desarrolladores que están familiarizados con los protocolos ActivityPub y ActivityStreams. Ofrece un esquema detallado de los actores, objetos y actividades utilizados por Lemmy.

Antes de leerlo, echa un vistazo a nuestra [Visión General de la Federación](overview.md) para hacerte una idea de cómo funciona la federación de Lemmy a alto nivel.

Lemmy todavía no sigue la especificación ActivityPub en todos los aspectos. Por ejemplo, no establecemos un contexto válido indicando nuestros campos de contexto. También ignoramos campos como la bandeja de entrada `inbox`, la bandeja de salida `outbox` o los puntos finales `endpoints` de los actores remotos, y asumimos que todo es Lemmy. Para una visión general de las desviaciones, lea el tema [#698](https://github.com/LemmyNet/lemmy/issues/698). Serán corregidas en un futuro próximo.

Lemmy también es realmente inflexible cuando se trata de actividades y objetos entrantes. Tienen que ser exactamente idénticos a los ejemplos de abajo. Cosas como tener un array en lugar de un solo valor, o un ID de objeto en lugar del objeto completo resultará en un error.

En las siguientes tablas, "obligatorio" se refiere a si Lemmy aceptará o no una actividad entrante sin este campo. El propio Lemmy siempre incluirá todos los campos no vacíos.

<!-- toc -->

- [Contexto](#context)
- [Actores](#actors)
  * [Comunidad](#community)
    + [Bandeja de salida de la Comunidad](#community-outbox)
    + [Seguidores de la Comunidad](#community-followers)
    + [Moderadores de la Comunidad](#community-moderators)
  * [Usuario](#user)
    + [Bandeja de salida del Usuario](#user-outbox)
- [Objectos](#objects)
  * [Publicación](#post)
  * [Comentario](#comment)
  * [Mensaje privado](#private-message)
- [Actividades](#activities)
  * [Usuario a Comunidad](#user-to-community)
    + [Seguir](#follow)
    + [Dejar de seguir](#unfollow)
    + [Crear o Actualizar Publicación](#create-or-update-post)
    + [Crear o Actualizar Comentario](#create-or-update-comment)
    + [Me gusta Publicación o Comentario](#like-post-or-comment)
    + [No me gusta Publicación o Comentario](#dislike-post-or-comment)
    + [Eliminar Publicación o Comentario](#delete-post-or-comment)
    + [Remover Publicación o Comentario](#remove-post-or-comment)
    + [Deshacer](#undo)
  * [Comunidad a Usuario](#community-to-user)
    + [Aceptar Seguir](#accept-follow)
    + [Anunciar](#announce)
    + [Remover o Eliminar Comunidad](#remove-or-delete-community)
    + [Restaurar Comunidad Removida o Eliminada](#restore-removed-or-deleted-community)
  * [Usuario a Usuario](#user-to-user)
    + [Crear o Actualizar Mensaje Privado](#create-or-update-private-message)
    + [Eliminar Mensaje Privado](#delete-private-message)
    + [Deshacer la Eliminación del Mensaje Privado](#undo-delete-private-message)⏎

<!-- tocstop -->

## Contexto

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

El contexto es identico para todas las actividades y objetos.

## Actores

### Comunidad

Un actor automatizado. Los usuarios pueden enviarle mensajes o comentarios, que la comunidad reenvía a sus seguidores en forma de Anuncio `Announce`.

Envía actividades al usuario: Aceptar/Seguir `Accept/Follow`, Anunciar `Announce`.

Recibe actividades del usuario: Seguir `Follow`, Deshacer/Seguir `Undo/Follow`, Crear `Create`, Actualizar `Update`, Me gusta `Like`, No me gusta `Dislike`, Remover `Remove` (sólo admin/mod), Eliminar `Delete` (sólo creador), Deshacer `Undo` (sólo para acciones propias).

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `preferredUsername` | si | Nombre del actor |
| `name` | si | Titulo de la comunidad |
| `sensitive` | si | True indica que todas las publicaciones en la comunidad son nsfw |
| `attributedTo` | si | Primero el creador de la comunidad, luego el resto de los moderadores |
| `content` | no | Texto para la barra lateral de lac comunidad, que suele contener una descripción y normas |
| `icon` | no | Icono que aparece junto al nombre de la comunidad |
| `image` | no | Imagen de banner, mostrada en la parte superior de la página de la comunidad |
| `inbox` | no | URL de la bandeja de entrada de ActivityPub |
| `outbox` | no | URL de la bandeja de salida de ActivityPub, sólo contiene las últimas 20 publicaciones sin comentarios, votos u otras actividades |
| `followers` | no | URL de la colección de seguidores, sólo contiene el número de seguidores, sin referencias a seguidores individuales |
| `endpoints` | no | Contiene la URL de la bandeja de entrada compartida |
| `published` | no | Fecha de creación de la comunidad |
| `updated` | no | Fecha de la última modificación de la comunidad |
| `publicKey` | si | La clave pública utilizada para verificar las firmas de este actor |
   
#### Bandeja de Salida de la Comunidad

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

La bandeja de salida sólo contiene las actividades Crear/Publicación `Create/Post` por ahora.

#### Seguidores de la Comunidad

```json
{
  "totalItems": 2,
  "@context": ...,
  "id": "https://enterprise.lemmy.ml/c/main/followers",
  "type": "Collection"
}
```

La colección de seguidores sólo se utiliza para exponer el número de seguidores. Los ID de los actores no se incluyen, para proteger la privacidad de los usuarios.

#### Moderadores de la Comunidad

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

### Usuario

Una persona, interactúa principalmente con la comunidad en la que envía y recibe publicaciones/comentarios. También puede crear y moderar comunidades, y enviar mensajes privados a otros usuarios.

Envía actividades a la Comunidad: Seguir `Follow`, Deshacer/Seguir `Undo/Follow`, Crear `Create`, Actualizar `Update`, Me gusta `Like`, No me gusta `Dislike`, Remover `Remove` (sólo admin/mod), Eliminar `Delete` (sólo creador), Deshacer `Undo` (sólo para acciones propias)

Recibe actividades de la Comunidad: Aceptar/Seguir `Accept/Follow`, Anunciar `Announce`.

Envía y recibe actividades de/para otros usuarios: Crear/Nota `Create/Note`, Actualizar/Nota `Update/Note`, Eliminar/Nota `Delete/Note`, Deshacer/Eliminar/Nota `Undo/Delete/Note` (todas las relacionadas con mensajes privados).

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `preferredUsername` | si | Nombre del actor |
| `name` | no | El nombre para mostrar del usuario |
| `content` | no | La biografía del usuario |
| `icon` | no | El avatar del usuario, que aparece junto al nombre del usuario |
| `image` | no | Banner del usuario, mostrada en la parte superior del perfil |
| `inbox` | no | URL de la bandeja de entrada de ActivityPub |
| `endpoints` | no | Contiene la URL de la bandeja de entrada compartida |
| `published` | no | Fecha de registro del usuario |
| `updated` | no | Fecha de la última actualización del perfil del usuario |
| `publicKey` | si | La clave pública utilizada para verificar las firmas de este actor |

#### Bandeja de salida del Usuario

```json
{
    "items": [],
    "totalItems": 0,
    "@context": ...,
    "id": "http://lemmy-alpha:8541/u/lemmy_alpha/outbox",
    "type": "OrderedCollection"
}
```

La bandeja de salida del usuario no está implementada todavía, y es sólo un marcador de posición para las implementaciones de ActivityPub que lo requieren.

## Objetos

### Publicación

Una página con título, y contenido opcional de URL y texto. La URL suele llevar a una imagen, en cuyo caso se incluye una miniatura. Cada entrada pertenece exactamente a una comunidad.

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

| Nombre del Campo | Obligatorio | Description |
|---|---|---|
| `attributedTo` | si | ID del usuario que creó esta publicación |
| `to` | si | ID de la comunidad en la que se publicó |
| `name` | si | Título de la publicación |
| `content` | no | Cuerpo de la publicación |
| `url` | no | Un enlace arbitrario para compartir |
| `image` | no | Miniatura para la `url`, sólo aparece si es un enlace de imagen |
| `commentsEnabled` | si | False indica que la publicación está bloqueada, y no se pueden añadir comentarios |
| `sensitive` | si | True marca la publicación como NSFW,difumina la miniatura y la oculta a los usuarios con la configuración NSFW desactivada |
| `stickied` | si | True significa que se muestra en la parte superior de la comunidad |
| `published` | no | Fecha de creación de la publicación |
| `updated` | no | Fecha en la que se editó la publicación (no está presente si nunca se editó) |

### Comentario

Una respuesta a una publicación, o una respuesta a otro comentario. Contiene sólo texto (incluyendo referencias a otros usuarios o comunidades). Lemmy muestra los comentarios en una estructura de árbol.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `attributedTo` | si | ID del usuario que creó el comentario |
| `to` | si | Comunidad donde se hizo el comentario |
| `content` | si | El texto del comentario |
| `inReplyTo` | si | ID de la publicación donde se hizo el comentario, y el comentario padre. Si este es un comentario de nivel superior, `inReplyTo` sólo contiene la publicación |
| `published` | no | Fecha de creación del comentario |
| `updated` | no | Fecha en la que se editó la publicación (no está presente si nunca se editó) |

### Mensaje Privado

Un mensaje directo de un usuario a otro. No puede incluir usuarios adicionales. Todavía no se ha implementado el hilo, por lo que falta el campo `inReplyTo`.

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
<!-- Fix table in english version --->

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `attributedTo` | | ID del usuario que creo este mensaje |
| `to` | | ID del destinatario |
| `content` | si | El texto del mensaje privado |
| `published` | no | Fecha de creación del mensaje |
| `updated` | no |  Fecha en la que se editó la publicación (no está presente si nunca se editó) |

## Actividades

### Usuario a Comunidad

#### Seguir

Cuando el usuario hace clic en "Suscribirse" en una comunidad, se envía un `Follow`. La comunidad responde automáticamente con un `Accept/Follow`.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `actor` | si | El usuario que envía la solicitud de seguimiento `Follow` |
| `object` | si | La comunidad a seguir |

#### Dejar de Seguir

Al pulsar el botón de "dar de baja"  en una comunidad se envía un `Undo/Follow`. La comunidad retira al usuario de su lista de seguidores tras recibirlo.

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

#### Crear o Actualizar Publicación

Cuando un usuario crea una nueva publicación, ésta se envía a la comunidad correspondiente. La edición de una publicación previamente creada envía una actividad casi idéntica, excepto que el tipo `type` es Actualizar `Update`. Todavía no admitimos las menciones en las publicaciones.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `type` | si | Crear `Create` o Actualizar `Update` |
| `cc` | si | Comunidad donde se hizo la publicación |
| `object` | si | La publicación que se crea |

#### Crear o Actulizar Comentario

Una respuesta a una publicación, o a otro comentario. Puede contener menciones a otros usuarios. La edición de una publicación previamente creada envía una actividad casi idéntica, excepto que el tipo `type` es Actualizar `Update`.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `tag` | no | Lista de los usuarios que se mencionan en el comentario (como `@usuario@ejemplo.com`) |
| `cc` | si | Comunidad en la que se hace la publicación, el usuario al que se responde (creador de la publicación/comentario principal), así como los usuarios mencionados |
| `object` | si | El comentario que se crea |

#### Me gusta Publicación o Comentario

Un voto positivo para una publicación o un comentario

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

| Nombre del Campo | Obligatorio | Descripción|
|---|---|---|
| `cc` | si | ID de la comunidad en la que se encuentra la publicación/comentario |
| `object` | si | La publicación o comentario que se ha votado |

#### No me gusta Publicación o Comentario

Un voto negativo para una publicación o un comentario

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

| Nombre del Campo | Obligatorio | Descripción|
|---|---|---|
| `cc` | si | ID de la comunidad en la que se encuentra la publicación/comentario |
| `object` | si | La publicación o comentario que se ha votado |

#### Eliminar Publicación o Comentario

Elimina una publicación o comentario creado anteriormente. Esto sólo lo puede hacer el creador original de esa publicación/comentario.

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

| Nombre del Campo | Obligatorio | Descripción|
|---|---|---|
| `cc` | si | ID de la comunidad en la que se encuentra la publicación/comentario |
| `object` | si | La publicación o comentario que se está eliminando |

#### Remover Publicación o Comentario 

Remover una publicación o un comentario. Esto sólo puede hacerlo un mod de la comunidad, o un administrador en la instancia donde se aloja la comunidad.

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

| Nombre del Campo | Obligatorio | Descripción|
|---|---|---|
| `cc` | si | ID de la comunidad en la que se encuentra la publicación/comentario |
| `object` | si | La publicación o comentario que se está removiendo |

#### Deshacer

Revierte una actividad anterior, sólo puede hacerlo el actor `actor` del objeto `object`. En caso de un `Like` o `Dislike`, se vuelve a cambiar el conteo de votos. En el caso de un `Delete`o `Remove`, se restablece la publicación/comentario. El objeto se regenera desde cero, por lo que el ID de la actividad y otros campos son diferentes.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `object` | si | Cualquier actividad `Like`, `Dislike`, `Delete` o `Remove` tal como se ha descrito anteriormente |

#### Agregar Moderador

Añade un nuevo mod (registrado en `ds9.lemmy.ml`) a la comunidad `!main@enterprise.lemmy.ml`. Tiene que ser enviado por un mod de la comunidad existente.

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

#### Remover Moderador

Remueve un mod existente de la comunidad. Tiene que ser enviado por un mod de la comunidad existente.

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

### Comunidad a Usuario

#### Aceptar Seguir

Enviado automáticamente por la comunidad en respuesta a un `Follow`. Al mismo tiempo, la comunidad añade a este usuario a su lista de seguidores.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `actor` | si | La misma comunidad que en la actividad `Follow` |
| `to` | no | ID del usuario que envió el `Follow` |
| `object` | si | La actividad de `Follow` enviada anteriormente |

#### Anuncio

Cuando la comunidad recibe una actividad publicación o comentario, lo envuelve en un anuncio `Announce` y lo envía a todos los seguidores.

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

| Nombre del Campo | Obligatorio | Descripción |
|---|---|---|
| `object` | si | Cualquier actividad `Create`, `Update`, `Like`, `Dislike`, `Delete`, `Remove` o `Undo` tal como se ha descrito en la sección [Usuario a Comunidad](#user-to-community) |

#### Remover o Eliminar Comunidad

Un administrador de instancia puede remover la comunidad, o un mod puede eliminarla. 

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

| Nombre del Campo| Obligatorio | Descripción |
|---|---|---|
| `type` | si | Remover `Remove` o Eliminar `Delete` |

#### Restaurar Comunidad Removida o Eliminada

Revierte la remoción o eliminación

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
| Nombre del Campo | Obligatorio | Descripción|
|---|---|---|
| `object.type` | si | Remover `Remove` o Eliminar `Delete` |

### Usuario a Usuario

#### Crear o Actualizar Mensaje Privado

Crea un nuevo mensaje privado entre dos usuarios.

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

| Nombre del Campo | Obligatorio| Descripción |
|---|---|---|
| `type` | si | Crear `Create` o Actualizar `Update` |
| `object` | si | Un [Mensaje Privado](#private-message) |

#### Eliminar Mensaje Privado

Elimina un mensaje privado previo

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

#### Deshacer la Eliminación del Mensaje Privado

Restaura un mensaje privado previamente eliminado. El objeto `object` se regenera desde cero, por lo que el ID de actividad y otros campos son diferentes.

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
