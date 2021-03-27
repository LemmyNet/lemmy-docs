# Tendencia / Popular / Mejor algoritmo de clasificación

## Metas

- Durante el día, las nuevas publicaciones y comentarios deben estar cerca de la parte superior, para que puedan ser votados.
- Después de un día más o menos, el factor tiempo debería desaparecer.
- Utilizar una escala logarítmica, ya que los votos tienden a convertirse en una bola de nieve, por lo que los primeros 10 votos son tan importantes como los siguientes cien.

## Implementaciones

### Reddit

No tiene en cuenta la duración del hilo, [lo que da a los primeros comentarios una ventaja abrumadora sobre los posteriores,](https://minimaxir.com/2016/11/first-comment/) siendo el efecto aún peor en las comunidades pequeñas. Los nuevos comentarios se acumulan en la parte inferior del hilo, acabando con la discusión y convirtiendo cada hilo en una carrera por comentar antes. Esto reduce la calidad de la conversación y premia los comentarios repetitivos y el spam.

### Hacker News

Aunque es muy superior a la implementación de Reddit por su decaimiento de las puntuaciones en el tiempo, [el algoritmo de clasificación de Hacker News](https://medium.com/hacking-and-gonzo/how-hacker-news-ranking-algorithm-works-1d9b0cf2c08d) no utiliza una escala logarítmica para las puntuaciones.

### Lemmy

Contrarresta el efecto de bola de nieve de los votos a lo largo del tiempo con una escala logarítmica.  Anula la ventaja inherente de los primeros comentarios y garantiza que los votos sigan siendo importantes a largo plazo, sin perjudicar los comentarios populares más antiguos.

```
Rank = ScaleFactor * log(Max(1, 3 + Score)) / (Time + 2)^Gravity

Score = Upvotes - Downvotes
Time = time since submission (in hours)
Gravity = Decay gravity, 1.8 is default
```
- Lemmy utiliza el mismo algoritmo `Rank` anterior, en dos tipos: `Active` y `Hot`.
  - El algoritmo "activo" utiliza los votos de las publicaciones y el tiempo de los últimos comentarios (limitado a dos días).
  - `Hot` utiliza los votos de las publicaciones, y la hora de publicación de los mismos.
- Utiliza Max(1, score) para asegurarse de que todos los comentarios se ven afectados por el decaimiento del tiempo.
- Añade 3 a la puntuación, para que todo lo que tenga menos de 3 downvotes parezca nuevo. De lo contrario, todos los comentarios nuevos se quedarían en cero, cerca del fondo.
- El signo y los abs de la puntuación son necesarios para tratar el registro de las puntuaciones negativas.
- Un factor de escala de 10k obtiene el rango en forma de número entero.

Un gráfico del rango a lo largo de 24 horas, de puntuaciones de 1, 5, 10, 100, 1000, con un factor de escala de 10k.

![](rank_algorithm.png)

#### Conteo de usuarios activos

Lemmy también muestra el conteo de *usuarios activos* de tu sitio y sus comunidades. Estos se cuentan en el último día `day`, semana `week`, mes `month` y medio año `half year`, almacenándose en caché al iniciar Lemmy, cada hora.

Un usuario activo es alguien que ha publicado o comentado en nuestra instancia o comunidad en el último periodo de tiempo. Para el conteo de sitios, sólo se cuentan los usuarios locales. Para los conteos de la comunidad, se incluyen los usuarios federados.
