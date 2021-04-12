# Objectifs

*Cette section contient des idées et des ressources de l'équipe qui développe Lemmy*. Similaire à un bloc-notes

- Trouver un nom / nom de code.
- Doit avoir des communautés.
- Doit avoir des commentaires en fil de discussion.
- Doit être fédéré : aimer et suivre les communautés à travers les instances.
- Doit être actualisé en temps réel : avoir un panneau de droite pour les nouveaux commentaires, et un panneau principal pour la vue complète du fil de discussion.
  - Utiliser des websockets pour envoyer et recevoir des messages dans votre propre instance.

# Questions

- Comment fonctionne le vote ? Devrions-nous revenir à l'ancienne méthode qui consistait à compter les votes positifs et négatifs ? Ou juste un score ?
- Décider de la technologie à utiliser
  - Backend : Actix, Diesel.
  - Front-end : inferno, typescript et bootstrap pour le moment.
- Doit-on autoriser les robots ?
- Les commentaires / votes doivent-ils être statiques, ou ressembler à un chat, comme [flowchat ?] (https://flow-chat.com).
  - Modèle à deux volets - le volet de droite contient les commentaires en direct, le volet de gauche est l'arborescence en direct.
  - Sur mobile, permettre de passer de l'un à l'autre. Par défaut ?

# Ressources / Bibliothèques potentielles

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
