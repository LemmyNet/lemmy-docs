# Metas

_Esta sección contiene ideas y recursos del equipo que desarrolla Lemmy_. **Parecido a un bloc de notas**

- Piensa en un nombre / nombre clave.
- Debe tener comunidades.
- Debe tener comentarios hilados.
- Debe ser federado: enlazar y seguir comunidades en todas las instancias.
- Debe estar actualizado en vivo: tener un panel derecho para nuevos comentarios y un panel principal para la vista completa de los hilos.
  - Usar websockets para publicar (post) / obtener (gets) hacia tu propia instancia.

# Preguntas

- ¿Cómo funciona la votación? ¿Debemos volver a la antigua forma de mostrar y contar los votos negativos? ¿O sólo una puntuación?
- Decidir la tecnología que se utilizará
  - Backend: Actix, Diesel.
  - Frontend: inferno, typescript y bootstrap por ahora.
- ¿Deberia permitir bots?
- ¿Deberían los comentarios/votos ser estáticos, o sentirse como un chat, como [flowchat?](https://flow-chat.com).
  - Modelo de dos paneles - El panel derecho para comentarios en vivo, el panel izquierdo para la vista en árbol en vivo
  - En el móvil, permite cambiar entre ellos. ¿Por defecto?

# Recursos / Librerías potenciales

- [Diesel to Postgres data types](https://kotiri.com/2018/01/31/postgresql-diesel-rust-types.html)
- [helpful diesel examples](http://siciarz.net/24-days-rust-diesel/)
- [Recursive query for adjacency list for nested comments](https://stackoverflow.com/questions/192220/what-is-the-most-efficient-elegant-way-to-parse-a-flat-table-into-a-tree/192462#192462)
- https://github.com/sparksuite/simplemde-markdown-editor
- [Markdown-it](https://github.com/markdown-it/markdown-it)
- [Sticky Sidebar](https://stackoverflow.com/questions/38382043/how-to-use-css-position-sticky-to-keep-a-sidebar-visible-with-bootstrap-4/49111934)
- [RXJS websocket](https://stackoverflow.com/questions/44060315/reconnecting-a-websocket-in-angular-and-rxjs/44067972#44067972)
- [Rust JWT](https://github.com/Keats/jsonwebtoken)
- [Hierarchical tree building javascript](https://stackoverflow.com/a/40732240/1655478)
- [Hot sorting discussion](https://meta.stackexchange.com/questions/11602/what-formula-should-be-used-to-determine-hot-questions) [2](https://medium.com/hacking-and-gonzo/how-reddit-ranking-algorithms-work-ef111e33d0d9)
- [Classification types.](https://www.reddit.com/r/ModeratorDuck/wiki/subreddit_classification)
- [RES expando - Possibly make this into a switching react component.](https://github.com/honestbleeps/Reddit-Enhancement-Suite/tree/d21f55c21e734f47d8ed03fe0ebce5b16653b0bd/lib/modules/hosts)
- [Temp Icon](https://www.flaticon.com/free-icon/mouse_194242)
- [Rust docker build](https://shaneutt.com/blog/rust-fast-small-docker-image-builds/)
- [Zurb mentions](https://github.com/zurb/tribute)
- [TippyJS](https://github.com/atomiks/tippyjs)
- [SQL function indexes](https://sorentwo.com/2013/12/30/let-postgres-do-the-work.html)
