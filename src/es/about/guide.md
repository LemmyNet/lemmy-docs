# Guía de Lemmy

**¿Eres nuevo aquí?** Esta sección es la indicada para que los nuevos (y no tan nuevos 😙) usuarios puedan sacar provecho de todo lo que Lemmy ofrece.

## Vídeo Explicativo (en inglés)

<iframe id='ivplayer' width='640' height='360' src='https://invidious.xyz/embed/5axSUJj0bBY' style='border:none;'></iframe>

## Comandos Útiles
Empieza tecleando...

- `@nombre_usuario` para obtener una lista de nombres de usuario.
- `!nombre_comunidad` para obtener una lista de comunidades.
- `:emoji` para obtener una lista de emojis.

## Clasificación

*Se aplica tanto a las publicaciones como a los comentarios.*

Tipo | Descripción
--- | ---
Activo | Tendencias ordenadas en base a la puntuación, y la hora del comentario mas reciente.
Popular | Tendencias ordenadas en base a la puntuación, y la hora de creación de la publicación.
Nuevo | Las publicaciones más nuevas.
Más comentados | Las publicaciones con más comentarios.
Nuevos comentarios | Las publicaciones con los comentarios más recientes, es decir un ordenamiento tipo foro.
Top | Las publicaciones con mayor puntuación en el periodo de dado.

Para más detalles, revisa el [Apartado de la Clasificación de las publicaciones y  los comentarios](ranking.md).

## Moderación / Administración

Todas las acciones de los moderadores y administradores sobre los usuarios se realizan en los comentarios o entradas, haciendo clic en el icono de 3 puntos "Más".

Esto incluye:

- Agregar / Eliminar mods y admins.
- Eliminar / Restaurar comentarios.
- Banear / Desbanear usuarios.

Todas las acciones de los administradores en las comunidades se realizan en la barra lateral de la comunidad. Esto actualmente sólo incluye la eliminación/restauración de comunidades.

## Guía de Markdown

Enriquece todas tus publicaciones / comentarios aplicando el formato Markdown para que el texto no se vea tan aburrido.

Tipo | O | … para obtener 
--- | --- | ---
\*Italica\* | \_Italica\_  | _Italica_ 
\*\*Negrita\*\* | \_\_Negrita\_\_ | **Negrita** 
\# Titulo 1 | Titulo 1 <br> ========= | <h4>Titulo 1</h4>
\## Titulo 2 | Titulo 2 <br>--------- | <h5>Titulo 2</h5>
\[enlace\](http://a.com) | \[enlace\]\[1\]<br>⋮ <br>\[1\]: http://b.org | [enlace](https://commonmark.org/) 
!\[Imagen\](http://url/a.png) | !\[Imagen\]\[1\]<br>⋮ <br>\[1\]: http://url/b.jpg | ![Markdown](https://commonmark.org/help/images/favicon.png) 
\> Cita en bloque | | <blockquote>Cita en bloque</blockquote>
\* Lista <br>\* Lista <br>\* Lista | \- Lista <br>\- Lista <br>\- Lista <br> | *   Lista <br>*   Lista <br>*   Lista <br>
1\. Uno <br>2\. Dos <br>3\. Tres | 1) Uno<br>2) Dos<br>3) Tres | 1.  Uno<br>2.  Dos<br>3.  Tres
Línea Horizontal <br>\--- | Línea Horizontal<br>\*\*\* | Línea Horizontal  <br><hr>
\`Código en línea\` con acento grave | |`Código en línea` con acento grave 
\`\`\`<br>\# Bloque de código <br>print '3 acentos graves o'<br>print 'indentar 4 espacios' <br>\`\`\` | ····\# Bloque de código<br>····print '3 acentos graves o'<br>····print 'indentar 4 espacios' | \# Bloque de código <br>print '3 acentos graves o'<br>print 'indentar 4 espacios'
::: spoiler o nsfw oculto <br>*mucho spoiler aquí*<br>::: | | <details><summary> spoiler o nsfw oculto </summary><p><em>mucho spoiler aquí</em></p></details>
Texto de ~subíndice~ | | Texto de <sub>subíndice</sub>
Texto de ^superíndice^ | | Texto de <sup>superíndice</sup>

[Tutorial de CommonMark](https://commonmark.org/help/tutorial/)

