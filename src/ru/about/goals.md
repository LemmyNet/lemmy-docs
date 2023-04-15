# Цели

- Придумать имя / кодовое назание.
- Иметь сообщества.
- Должны иметь цепочки комментариев.
- Должна быть федерируемой: ссылаться и следовать за сообществами из/на других инстансах.
- Постоянно обновляться: иметь панель для новых комментариев справа и основную панель для полного просмотра с развёртыванием.
  - Использовать веб-сокеты для публикации / создавать собственный инстанс.

# Вопросы

- Как должно работать голосование? Должны ли мы вернуться к старому способу отображения подсчёта голосов вверх или вниз? Или просто счёт?
- Определитесь с технологией, которая будет использоваться
  - Бэкэнд: Actix, Diesel.
  - Фронтэнд: inferno, typescript или bootstrap как сейчас.
- Должен ли быть разрешены боты?
- Должны быть комментарии / статистика голосований, или в духе чата, например как в [flowchat?](https://flow-chat.com).
  - Двухпанельная модель - Правая панель для комментариев в реальном времени, левая часть для просмотра актуальной древовидной структуры.
  - Просмотр с мобильных устройств, разрешить переключаться между ними. По умолчанию?

# Источники / Потенциальные библиотеки

- [Diesel в Postgres типов даты (анг.язык)](https://kotiri.com/2018/01/31/postgresql-diesel-rust-types.html)
- [Примеры в diesel (анг.язык)](http://siciarz.net/24-days-rust-diesel/)
- [Рекурсивный запрос списка смежности для вложенных комментариев (анг.язык)](https://stackoverflow.com/questions/192220/what-is-the-most-efficient-elegant-way-to-parse-a-flat-table-into-a-tree/192462#192462)
- https://github.com/sparksuite/simplemde-markdown-editor
- [Markdown-it (анг.язык)](https://github.com/markdown-it/markdown-it)
- [Sticky Sidebar (анг.язык)](https://stackoverflow.com/questions/38382043/how-to-use-css-position-sticky-to-keep-a-sidebar-visible-with-bootstrap-4/49111934)
- [RXJS вебсокет(анг.язык)](https://stackoverflow.com/questions/44060315/reconnecting-a-websocket-in-angular-and-rxjs/44067972#44067972)
- [Rust JWT (анг.язык)](https://github.com/Keats/jsonwebtoken)
- [Hierarchical tree building javascript (анг.язык)](https://stackoverflow.com/a/40732240/1655478)
- [Hot sorting discussion (анг.язык)](https://meta.stackexchange.com/questions/11602/what-formula-should-be-used-to-determine-hot-questions) [2](https://medium.com/hacking-and-gonzo/how-reddit-ranking-algorithms-work-ef111e33d0d9)
- [Classification types. (анг.язык)](https://www.reddit.com/r/ModeratorDuck/wiki/subreddit_classification)
- [RES expando - Possibly make this into a switching react component. (анг.язык)](https://github.com/honestbleeps/Reddit-Enhancement-Suite/tree/d21f55c21e734f47d8ed03fe0ebce5b16653b0bd/lib/modules/hosts)
- [Temp Icon (анг.язык)](https://www.flaticon.com/free-icon/mouse_194242)
- [Rust docker build (анг.язык)](https://shaneutt.com/blog/rust-fast-small-docker-image-builds/)
- [Zurb mentions (анг.язык)](https://github.com/zurb/tribute)
- [TippyJS (анг.язык)](https://github.com/atomiks/tippyjs)
- [SQL function indexes (анг.язык)](https://sorentwo.com/2013/12/30/let-postgres-do-the-work.html)
