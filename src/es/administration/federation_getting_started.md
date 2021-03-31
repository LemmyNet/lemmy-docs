# Federación

Lemmy utiliza el protocolo ActivityPub (un estándar del W3C) para permitir la federación entre diferentes servidores (a menudo llamados instancias). Esto es muy parecido al funcionamiento del correo electrónico. Por ejemplo, si utilizas gmail.com, no sólo puedes enviar correos a otros usuarios de gmail.com, sino también a yahoo.com, yandex.ru, etc. El correo electrónico utiliza el protocolo SMTP para lograr esto, así que puedes pensar en ActivityPub como "SMTP para las redes sociales". La cantidad de acciones posibles en las redes sociales (publicar, comentar, gustar, compartir, etc.) hace que ActivityPub sea mucho más complicado que SMTP.

Al igual que con el correo electrónico, la federación de ActivityPub sólo se produce entre servidores. Así, si estás registrado en `enterprise.lemmy.ml`, sólo te conectas a la API de `enterprise.lemmy.ml`, mientras que el servidor se encarga de enviar y recibir datos de otras instancias (por ejemplo, `voyager.lemmy.ml`). La gran ventaja de este enfoque es que el usuario medio no tiene que hacer nada para utilizar la federación. De hecho, si está utilizando Lemmy, es probable que ya lo estés haciendo. Una forma de confirmarlo es ir a una comunidad o perfil de usuario. Si estás en `enterprise.lemmy.ml` y ves un usuario como `@nutomic@voyager.lemmy.ml`, o una comunidad como `!main@ds9.lemmy.ml`, entonces están federados, lo que significa que utilizan una instancia diferente a la tuya.

Una forma de aprovechar la federación es abrir una instancia diferente, como `ds9.lemmy.ml`, y navegar por ella. Si ves una comunidad, una publicación o un usuario interesante con el que quieres interactuar, sólo tienes que copiar su URL y pegarla en el campo de búsqueda de tu propia instancia (parte superior de página). Tu instancia se conectará a la otra (suponiendo que la lista de permitidos/bloqueados lo permita), y te mostrará directamente el contenido remoto, para que puedas seguir una comunidad o comentar un publicación. Estos son algunos ejemplos de búsquedas que funcionan:

- `!main@lemmy.ml` (Comunidad)
- `@nutomic@lemmy.ml` (Usuario)
- `https://lemmy.ml/c/programming` (Comunidad)
- `https://lemmy.ml/u/nutomic` (Usuario)
- `https://lemmy.ml/post/123` (Publicación)
- `https://lemmy.ml/comment/321` (Comentario)

Puedes ver la lista de instancias vinculadas siguiendo el enlace "Instancias" en la parte inferior de cualquier página de Lemmy.

## Búsqueda de comunidades

Si buscas una comunidad por primera vez, inicialmente se obtienen 20 publicaciones. Sólo si al menos un usuario de tu instancia se suscribe a la comunidad remota, ésta enviará actualizaciones a tu instancia. Las actualizaciones incluyen:

- Nuevas publicaciones / comentarios
- Votos
- Publicación, ediciones y supresiones de comentarios
- Acciones de los modeladores

Puedes copiar la URL de la comunidad desde la barra de direcciones de tu navegador e insertarla en el campo de búsqueda. Espera unos segundos y la publicación aparecerá a continuación. Por el momento no hay un indicador de carga para la búsqueda, así que espera unos segundos si muestra "sin resultados".

## Búsqueda de publicaciones

Pega la URL de una publicación en el campo de búsqueda de tu instancia de Lemmy. Espera unos segundos hasta que aparezca la publicación. Esto también recuperará el perfil de la comunidad y el perfil del creador de la publicación.

## Búsqueda de comentarios

Si encuentras un comentario interesante bajo una publicación en otra instancia, puedes encontrar debajo del comentario en el menú de 3 puntos el símbolo del enlace. Copia este enlace. Se parece a `https://lemmy.ml/post/56382/comment/40796`. Elimina la parte `post/XXX` y ponlo en tu barra de búsqueda. Para este ejemplo, busqua `https://lemmy.ml/comment/40796`. Este comentario, todos los comentarios padre, usuarios, la comunidad y la publicación correspondiente se obtienen de la instancia remota, si no se conocen localmente.
 
Los comentarios hermanos no se obtienen. Si quieres más comentarios de publicaciones anteriores, tienes que buscar cada uno de ellos como se ha descrito anteriormente.
