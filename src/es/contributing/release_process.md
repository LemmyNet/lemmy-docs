# Bifurcaciones y Liberaciones

## Bifurcaciones

En general, nuestro manejo de las ramas es el descrito en [Un modelo de bifurcación de líneal principal estable para Git](https://www.bitsnbites.eu/a-stable-mainline-branching-model-for-git/). Una diferencia es que evitamos el rebase `rebase`, y en su lugar fusionamos `merge` la rama base en la rama de trabajo actual. Esto ayuda a evitar empujes `push` forzados y conflictos.

## Liberaciones

- Para una versión mayo `major release`: crea una nueva rama `release/v0.x`
- Para una versión menor `minor release`: selecciona los cambios deseados en la rama `release/v0.x`
- Hacer una versión beta `beta` o candidata `release candidate` con `docker/prod/deploy.sh`
- Hacer lo mismo para `lemmy-ui`: `./deploy.sh 0.x.0-rc-x`
- Despliega en las instancias de prueba de la federación
  - Mantener una instancia en la última versión estable para probar la compatibilidad de la federación (automatizar esto con ansible)
  - `ansible-playbook -i federation playbooks/site.yml --vault-password-file vault_pass -e rc_version=0.x.0-rc.x`
- Prueba que todo funciona como se espera, haz nuevas versiones beta/rc si es necesario
- Despliega en lemmy.ml, para descubrir los problemas restantes
- Si todo ha ido bien, haz la versión oficial `0.x.0` con `docker/prod/deploy.sh`
- Anuncia el lanzamiento en Lemmy, Matrix, Mastodon
