# Visión General de la Federación

Este documento es para cualquiera que quiera saber como funciona la federación en Lemmy, sin ser demasiado técnico. Se pretende proporcionar una visión general de alto nivel de la federación ActivityPub en Lemmy. Si estás implementando ActivityPub por ti mismo y quieres ser compatible con Lemmy, lee nuestro
[esquema de la API de ActivityPub](contributing_apub_api_outline.md).

## Convenciones de la documentación

Para mantener las cosas simples, a veces verás cosas formateadas como Crear/Nota `Create/Note` o Eliminar/Evento `Delete/Event` o Deshacer/Seguir `Undo/Follow`. La cosa antes de la barra es la Actividad, y la cosa después de la barra es el Objeto dentro de la Actividad, una propiedad del objeto `objet`. Así que estos deben ser leídos como sigue:

* `Create/Note`: una actividad `Create` que contiene una `Note` en el campo del `object`
* `Delete/Event`: una actividad `Delete` que contiene un `Event` en el campo del `object`
* `Undo/Follow`: una actividad `Undo` que contiene un `Follow` en el campo del `object`

En Lemmy utilizamos algunos términos específicos para referirnos a los elementos de ActivityPub. Son esencialmente nuestras implementaciones específicas de conceptos conocidos de ActivityPub:

- Comunidad (community): Grupo `Group`
- Usuario (user): Persona `Person`
- Publicación (post): Página `Page`
- Comentario (comment): Nota `Note`

Este documento tiene tres secciones principales:

* __Filosofía de la federación:__ expone el modelo general de cómo se debe federar.
* __Actividades del usuario:__ describen las acciones que un usuario puede realizar para interactuar.
* __Actividades de la comunidad:__ describen lo que hace la comunidad en respuesta a determinadas acciones de los usuarios.

## Filosofía de la federación

El actor principal de Lemmy es la Comunidad. Cada comunidad reside en una única instancia, y consiste en una lista de Publicaciones y una lista de seguidores. La interacción principal es la de un usuario que envía una actividad relacionada con una Publicación o un Comentario a la bandeja de entrada de la Comunidad, que la anuncia a todos sus seguidores.

Cada Comunidad tiene un Usuario creador específico, que es responsable de establecer las reglas, nombrar moderadores y eliminar el contenido que viola las reglas.

Además de la moderación a nivel de comunidad, cada instancia tiene un conjunto de Usuarios administradores, que tienen el poder de realizar eliminaciones y baneos en todo el sitio.

Los Usuarios siguen a las comunidades que les interesan para recibir Publicaciones y Comentarios. También votan las Publicaciones y los Comentarios, además de crear otros nuevos. Los Comentarios se organizan en una estructura de árbol y suelen ordenarse por número de votos. Los mensajes directos entre Usuarios también son compatibles.

Los Usuarios no pueden seguirse unos a otros, y las Comunidades tampoco pueden seguir nada.

Nuestra implementación de la federación ya está completa, pero hasta ahora no nos hemos centrado en absoluto en el cumplimiento de la especificación ActivityPub. Como tal, Lemmy probablemente no es compatible con las implementaciones que esperan enviar y recibir actividades válidas. Esto es algo que planeamos arreglar en un futuro próximo. Consulta el tema [#698](https://github.com/LemmyNet/lemmy/issues/698) para ver un resumen de nuestras desviaciones.

## Actividades del usuario

### Seguir a una Comunidad

Cada página de la Comunidad tiene un botón "Seguir". Al hacer clic en él, el usuario envía una actividad de Seguir `Follow` a la bandeja de entrada de la Comunidad. La Comunidad responderá automáticamente con una actividad de Aceptar/Seguir `Accept/Follow` a la bandeja de entrada del usuario. También añadirá al usuario a su lista de seguidores y le enviará cualquier actividad sobre las publicaciones/comentarios de la comunidad.

### Dejar de seguir una Comunidad

Después de seguir una Comunidad, el botón "Seguir" se sustituye por "Dejar de seguir". Al hacer clic en él, se envía una actividad de Deshacer/Seguir `Undo/Follow` a la bandeja de entrada de la Comunidad. La Comunidad elimina al usuario de su lista de seguidores y ya no le envía ninguna actividad.

### Crear una Publicación

Cuando un usuario crea una nueva publicación en una Comunidad determinada, se envía como Crear/Página `Create/Page` a la bandeja de entrada de la Comunidad.

### Crear un Comentario

Cuando se crea un nuevo Comentario para una Publicación, tanto el ID de la Publicación como el ID del Comentario principal (si existe) se escriben en el campo `in_reply_to`. Esto permite asignarlo a la Publicación correcta y construir el árbol de Comentarios. A continuación, se envía a la bandeja de entrada de la Comunidad como Crear/Note `Create/Note`.

La instancia de origen también escanea el Comentario en busca de cualquier mención de Usuario, y envía el Crear/Nota`Create/Note` a esos Usuarios también.

### Editar una Publicación

Cambia el contenido de una Publicación existente. Sólo puede hacerlo el usuario que lo crea.

### Editar un Comentario

Cambia el contenido de un Comentario existente. Sólo puede hacerlo el usuario que lo crea.

### Me Gusta y No Me Gusta

Los usuarios pueden poner Me gustar o No me gusta de cualquier Publicación o Comentario. Estos se envían como Me gusta / Página `like/Page`, No me gusta / Nota `Dislike/Note`, etc. a la bandeja de entrada de la Comunidad.

### Eliminaciones

El creador de una Publicación, Comentario o Comunidad puede eliminarla. Entonces se envía a los seguidores de la Comunidad. El elemento queda entonces oculto para todos los usuarios.

### Remociones

Los mods pueden remover Publicaciones y Comentarios de sus Comunidades. Los administradores pueden remover cualquier Publicación o Comentario en todo el sitio. Las Comunidades también pueden ser removidas por los administradores. El elemento se oculta para todos los usuarios.

Las remociones se envían a todos los seguidores de la Comunidad, por lo que también tienen efecto allí. La excepción es si un administrador elimina un elemento de una Comunidad que está alojada en una instancia diferente. En este caso, la eliminación sólo tiene efecto a nivel local.

### Revertir una acción anterior 

**No eliminamos nada de nuestra base de datos, sólo lo ocultamos a los usuarios**. Las Comunidades/Publicaciones/Comentarios removidos o eliminados tienen un botón de "restauración". Este botón genera una actividad de Deshacer `Undo` que establece la actividad original de eliminar/remover como objeto, como Deshacer/Remover/Publicación `Undo/Remove/Post` o Deshacer/Eliminar/Comunidad `Undo/Delete/Community`.

Al hacer clic en el botón de "Voto positivo" (upvote) de una publicación/comentario ya votado (o en el botón de "Voto negativo" (downvote) de una publicación/comentario ya votado) también se genera un Deshacer `Undo`. En este caso Deshacer/Me gusta/Publicación `Undo/Like/Post` o Deshacer/No me gusta/Comentario `Undo/Dislike/Comment`.

### Crear un mensaje privado

Los perfiles de los usuarios tienen un botón "Enviar mensaje", que abre un diálogo que permite enviar un mensaje privado a este usuario. Se envía como un Crear/Nota `Create/Note` a la bandeja de entrada del usuario. Los mensajes privados sólo pueden dirigirse a un único usuario.

### Editar mensaje privado

Actualizar/Nota `Update/Note` cambia el texto de un mensaje enviado previamente.

### Eliminar mensaje privado

Eliminar/Nota `Delete/Note` borra un mensaje privado.

### Restaurar mensaje privado

Deshacer/Eliminar/Nota `Undo/Delete/Note` Revierte la eliminación de un mensaje privado.

## Actividades de la Comunidad

La Comunidad es esencialmente un bot, que sólo hará algo en reacción a las acciones de los Usuarios. El usuario que creó la Comunidad por primera vez se convierte en el primer moderador, y puede añadir moderadores adicionales. En general, cada vez que la Comunidad recibe una actividad válida en su bandeja de entrada, esa actividad se reenvía a todos sus seguidores.

### Aceptar seguir

Si la Comunidad recibe una actividad de Seguir `Follow`, responde automáticamente con Aceptar/Seguir `Accept/Follow`. También añade al Usuario a su lista de seguidores.

### Dejar de seguir

Al recibir un Deshacer/Seguir `Undo/Follow`, la Comunidad elimina al Usuario de su lista de seguidores.
 
### Anunciar

Si la Comunidad recibe cualquier actividad relacionada con una publicación o comentario (Crear, Actualizar, Me gusta, No me gusta, Eliminar, Borrar, Deshacer), lo anunciará a sus seguidores. Para ello, se crea un Anuncio con la Comunidad como actor, y la actividad recibida como objeto. De este modo, las instancias seguidoras se mantienen actualizadas sobre cualquier acción en las Comunidades que siguen.

### Eliminar Comunidad

Si el creador o un administrador elimina la Comunidad, envía un Anuncio de Eliminar/Grupo `Delete/Group` a todos sus seguidores.
