# Crear un Frontend Personalizado

El backend y el frontend están completamente desacoplados y se ejecutan en contenedores Docker independientes. Solo se comunican a través de la [API de Lemmy](api_reference.md), lo que hace que sea bastante fácil escribir interfaces alternativas.

Esto crea un gran potencial para las interfaces personalizadas, que podrían cambiar gran parte del diseño y la experiencia del usuario de Lemmy. Por ejemplo, sería posible crear un frontend al estilo de un foro tradicional como [phpBB](https://www.phpbb.com/), o un sitio de preguntas y respuestas como [stackoverflow](https://stackoverflow.com/). Todo ello sin tener que pensar en las consultas a la base de datos, en la autentificación o en el ActivityPub, que esencialmente se obtiene de forma gratuita.

## Desarrollo

Puedes utilizar cualquier lenguaje para crear un frontend personalizado. La opción más fácil sería hacer un fork de nuestro [frontend oficial](https://github.com/LemmyNet/lemmy-ui), [lemmy-lite](https://github.com/IronOxidizer/lemmy-lite), o el [lemmy-frontend-example](https://github.com/LemmyNet/lemmy-front-end-example). En cualquier caso, el principio es el mismo: enlazar con `LEMMY_EXTERNAL_HOST` (por defecto: `localhost:8536`) y gestionar las peticiones utilizando la API de Lemmy en `LEMMY_INTERNAL_HOST` (por defecto: `lemmy:8536`). Utilice también `LEMMY_HTTPS` para generar enlaces con el protocolo correcto.

El siguiente paso es construir una imagen Docker desde tu frontend. Si has bifurcado (fork) un proyecto existente, debería incluir un archivo Docker y las instrucciones para construirlo. Si no, intenta buscar para tu lenguaje en [dockerhub](https://hub.docker.com/), las imágenes oficiales suelen tener instrucciones para construir en su readme. Construye una imagen Docker con una etiqueta, luego busca la siguiente sección en `docker/dev/docker-compose.yml`:

```
  lemmy-ui:
    image: dessalines/lemmy-ui:v0.8.10
    ports:
      - "1235:1234"
    restart: always
    environment:
      - LEMMY_INTERNAL_HOST=lemmy:8536
      - LEMMY_EXTERNAL_HOST=localhost:8536
      - LEMMY_HTTPS=false
    depends_on: 
      - lemmy
```

Todo lo que tienes que hacer es sustituir el valor de `image` por la etiqueta de tu propia imagen Docker (y posiblemente las variables de entorno si necesitas otras diferentes). A continuación, ejecuta `./docker_update.sh`, y después de la compilación, tu frontend estará disponible en `http://localhost:1235`. También puedes hacer el mismo cambio en `docker/federation/docker-compose.yml` y ejecutar `./start-local-instances.bash` para probar la federación con tu frontend.

## Desplegar con Docker

Después de construir la imagen Docker, necesitas empujarla (hacer push) a un registro Docker (como [dockerhub](https://hub.docker.com/)). A continuación, actualiza el `docker-compose.yml` en tu servidor, sustituyendo la `image` por `lemmy-ui`, tal y como se ha descrito anteriormente. Ejecuta `docker-compose.yml` y, tras una breve espera, tu instancia utilizará el nuevo frontend.

Toma en cuenta que si tu instancia se despliega con Ansible, éste anulará (sobreescribirá) `docker-compose.yml` con cada ejecución, volviendo al frontend por defecto. En ese caso debes copiar la carpeta `ansible/` de este proyecto a tu propio repositorio, y ajustar `docker-compose.yml` directamente en el repo.

También es posible utilizar varios frontends para la misma instancia de Lemmy, ya sea utilizando subdominios o subcarpetas. Para ello, no edites la sección `lemmy-ui` en `docker-compose.yml`, sino duplícala, ajustando el nombre, la imagen y el puerto para que sean distintos para cada uno. Luego edita tu configuración de nginx para pasar las peticiones al frontend apropiado, dependiendo del subdominio o la ruta.

## Traducciones

Puedes añadir el repositorio [lemmy-translations](https://github.com/LemmyNet/lemmy-translations) a tu proyecto como un [submódulo git](https://git-scm.com/book/en/v2/Git-Tools-Submodules). De este modo, podrás aprovechar las mismas traducciones que se utilizan en el frontend oficial, y también recibirás las nuevas traducciones aportadas a través de [weblate](https://weblate.org/es/).

## Limitación de la tasa

Lemmy limita la tasa de muchas acciones en función de la IP del cliente. Pero si haces alguna llamada a la API en el lado del servidor (por ejemplo, en el caso de la renderización del lado del servidor, o la pre-renderización de javascript), Lemmy tomará la IP del contenedor Docker. Lo que significa que todas las peticiones provienen de la misma IP, y obtienen la tasa limitada mucho antes. Para evitar este problema, es necesario pasar las cabeceras `X-REAL-IP` y `X-FORWARDED-FOR` a Lemmy (las cabeceras son establecidas por nuestra configuración de nginx).

Aquí hay un ejemplo recortado para NodeJS:

```javascript
function setForwardedHeaders(
  headers: IncomingHttpHeaders
): { [key: string]: string } {
  let out = {
    host: headers.host,
  };
  if (headers['x-real-ip']) {
    out['x-real-ip'] = headers['x-real-ip'];
  }
  if (headers['x-forwarded-for']) {
    out['x-forwarded-for'] = headers['x-forwarded-for'];
  }

  return out;
}

let headers = setForwardedHeaders(req.headers);
let client = new LemmyHttp(httpUri, headers);
```
