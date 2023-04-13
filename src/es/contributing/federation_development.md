# Desarrollo de la Federación

## Ejecutando localmente

Instala las dependencias necesarias como esta descrito en el documento [Desarrollo con Docker](docker_development.md). Enseguida ejecuta lo siguiente:

```bash
cd docker/federation
./start-local-instances.bash
```

Las pruebas de federación establecen 5 instancias:

| Instancia     | Nombre de usuario | Localización                            | Notas                                                |
| ------------- | ----------------- | --------------------------------------- | ---------------------------------------------------- |
| lemmy-alpha   | lemmy_alpha       | [127.0.0.1:8540](http://127.0.0.1:8540) | federada con todas las demás instancias              |
| lemmy-beta    | lemmy_beta        | [127.0.0.1:8550](http://127.0.0.1:8550) | federada con todas las demás instancias              |
| lemmy-gamma   | lemmy_gamma       | [127.0.0.1:8560](http://127.0.0.1:8560) | federada con todas las demás instancias              |
| lemmy-delta   | lemmy_delta       | [127.0.0.1:8570](http://127.0.0.1:8570) | solo permite federación con lemmy-beta               |
| lemmy-epsilon | lemmy_epsilon     | [127.0.0.1:8580](http://127.0.0.1:8580) | usa la lista de bloqueo, tiene lemmy-alpha bloqueada |

Puedes registrarte en cada una usando el nombre de la instancia, y `lemmy` como la contraseña, ejemplo: (`lemmy_alpha`, `lemmy`).

Para iniciar la federación entre instancias, visita una de ellas y busca un
usuario, comunidad o publicación, como en este ejemplo. Nota que el backend de Lemmy se ejecuta en un puerto diferente al del frontend, por lo que tienes que incrementar en uno el número de puerto de la barra de URL.

- `!main@lemmy-alpha:8541`
- `http://lemmy-beta:8551/post/3`
- `@lemmy-gamma@lemmy-gamma:8561`

Los contenedores de Firefox son una buena forma de probar su interacción.

## Ejecutando en un servidor

Ten en cuenta que la federación está actualmente en fase alfa. **Únicamente utilícela para pruebas**, no en un servidor de producción, y sé cuidadoso, que activar la federación puede romper tu instancia.

Sigue las instrucciones normales de instalación, ya sea con [Ansible](../administration/install_ansible.md) o
[manualmente con Docker](../administration/install_docker.md). Luego reemplaza la linea `image: dessalines/lemmy:v0.x.x` en
`/lemmy/docker-compose.yml` con `image: dessalines/lemmy:federation`. También añade lo siguiente en `/lemmy/lemmy.hjson`:

```
    federation: {
        enabled: true
        tls_enabled: true,
        allowed_instances: example.com,
    }
```

Después, y siempre que quieras actualizar a la última versión, ejecuta estos comandos en el servidor:

```
cd /lemmy/
sudo docker-compose pull
sudo docker-compose up -d
```

## Modelo de seguridad

- Verificación de la firma HTTP: Garantiza que la actividad proviene realmente de la actividad que afirma
- check_is_apub_valid : Asegura que está en nuestra lista de instancias permitidas
- Comprobaciones de nivel inferior: Para asegurarse de que el usuario que crea/actualiza/elimina una publicación está realmente en la misma instancia que esa publicación

Para el último punto, ten en cuenta que _no_ estamos comprobando si el actor que envía la actividad de creación para una publicación es realmente idéntico al creador de la publicación, o si el usuario que elimina una entrada es un mod/admin. Estas cosas se comprueban por el código de la API, y es responsabilidad de cada instancia comprobar los permisos de los usuarios. Esto no deja ningún vector de ataque, ya que un usuario normal de la instancia no puede realizar acciones que violen las reglas de la API. El único que podría hacerlo es el administrador (y el software desplegado por el administrador). Pero el administrador puede hacer cualquier cosa en la instancia, incluso enviar actividades desde otras cuentas de usuario. Así que en realidad no ganaríamos nada de seguridad comprobando los permisos de los mods o similares.
