# Contribuir al Proyecto

Información sobre como contribuir a Lemmy, ya sea traduciendo, probando, diseñando o programando.

## Seguimiento de problemas (issues) / Repositorios

- [GitHub (para issues y pull requests)](https://github.com/LemmyNet/lemmy)
- [Gitea (solo para pull requests)](https://yerbamate.ml/LemmyNet/lemmy)
- [Codeberg](https://codeberg.org/LemmyNet/lemmy)

## Traduciendo

Mira el [Weblate de Lemmy](https://weblate.yerbamate.ml/projects/lemmy/) para las traducciones. Tú también puedes ayudar [traduciendo esta documentación](https://github.com/LemmyNet/lemmy-docs#adding-a-new-language).

## Arquitectura

### Front end

- El front end está escrito en `typescript`, usando un framework similar a React llamado [inferno](https://infernojs.org/). Todos los elementos de la interfaz de usuario (UI) son componentes `.tsx` reutilizables.
- El repositorio del front end es [lemmy-ui](https://github.com/LemmyNet/lemmy-ui).
- Las rutas están en `src/shared/routes.ts`.
- Los componentes están localizados en `src/shared/components`.

### Back end

- El back end está escrito en `rust`, usando `diesel`, y `actix`.
- El código fuente del servidor está divido en secciones _main_ in `src`. Estos incluyen:
  - `db` - Las acciones de bajo nivel de la base de datos.
    - Las adiciones a la base de datos se realizan mediante migraciones. Ejecuta `diesel migration generate xxxxx` para añadir cosas nuevas.
  - `api` - Las iteracciones de alto nivel del usuario (cosas como `CreateComment`)
  - `routes` - Los puntos finales (endpoints) del servidor.
  - `apub` - Las conversiones activitypub.
  - `websocket` - Crea el sevidor del websocket.

## Linting / Formateo

- Cada commit del front end y back end se formatea automáticamente y luego se hace un linting usando `husky`, y `lint-staged`.
- Rust con `cargo fmt` y `cargo clippy`.
- Typescript con `prettier` y `eslint`.
