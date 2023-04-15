# Guía para Temas

Lemmy usa [Bootstrap v4](https://getbootstrap.com/), y algunas clases css customizadas por lo que cualquier tema compatible con bootstrap v4 debería de funcionar.

## Creación

- Usa una herramienta, por ejemplo [bootstrap.build](https://bootstrap.build/) para crear tú tema de bootstrap v4. Exporta el archivo `bootstrap.min.css` una vez terminado el tema, y conserva támbién el archivo generado `_variables.scss`.

## Prueba

- Para probar el tema, puedes también usar las herramientas del navegador web, o un plugin como _stylus_ para copiar/pegar un tema, y verlo en Lemmy.

## Subir / Publicar

1. Haz un _fork_ de [lemmy-ui](https://github.com/LemmyNet/lemmy-ui).
1. Copia el archivo `{nombre-de-mi-tema}.min.css` a la carpeta `src/assets/css/themes`. (Aquí puedes copiar el archivo `_variables.scss` si lo deseas).
1. Abre el archivo `src/shared/utils.ts` y agregas `{nombre-de-mi-tema}` a la lista de temas.
1. Pruebalo localmente
1. Haz _pull request_ con los cambios que hiciste.
