# Dépannage

Différents problèmes qui peuvent survenir sur une nouvelle instance, et comment les résoudre.

De nombreuses fonctionnalités de Lemmy dépendent d'une configuration correcte du reverse proxy. Assurez-vous que la vôtre est équivalente à notre [configuration nginx](https://github.com/LemmyNet/lemmy/blob/main/ansible/templates/nginx.conf).

## Général

### Logs

Pour les problèmes frontaux, vérifiez la [console du navigateur](https://webmasters.stackexchange.com/a/77337) pour tout message d'erreur.

Pour les logs du serveur, exécutez `docker-compose logs -f lemmy` dans votre dossier d'installation. Vous pouvez aussi faire `docker-compose logs -f lemmy lemmy-ui pictrs` pour obtenir les logs de différents services.

Si cela ne donne pas assez d'informations, essayez de changer la ligne `RUST_LOG=error` dans `docker-compose.yml` en `RUST_LOG=info` ou `RUST_LOG=verbose`, puis faites `docker-compose restart lemmy`.

### La création de l'utilisateur admin ne fonctionne pas

Assurez-vous que le websocket fonctionne correctement, en vérifiant les erreurs dans la console du navigateur. Dans nginx, les en-têtes suivants sont importants pour cela :

```
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

### Erreur de limite de débit lorsque de nombreux utilisateurs accèdent au site

Vérifiez que les en-têtes `X-Real-IP` et `X-Forwarded-For` sont envoyés à Lemmy par le reverse proxy. Sinon, il comptabilisera toutes les actions dans la limite de débit de l'IP du reverse proxy. Dans nginx, cela devrait ressembler à ceci :

```
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

## Fédération

### Les autres instances ne peuvent pas récupérer les objets locaux (communauté, post, etc)

Votre reverse proxy (par exemple nginx) doit transmettre les requêtes avec l'en-tête `Accept : application/activity+json` au backend. Ceci est géré par les lignes suivantes :

```
set $proxpass "http://0.0.0.0:{{ lemmy_ui_port }}";
if ($http_accept = "application/activity+json") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
if ($http_accept = "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\"") {
set $proxpass "http://0.0.0.0:{{ lemmy_port }}";
}
proxy_pass $proxpass;
```

Vous pouvez vérifier qu'il fonctionne correctement en exécutant les commandes suivantes, qui devraient toutes renvoyer un JSON valide :

```
curl -H "Accept: application/activity+json" https://your-instance.com/u/some-local-user
curl -H "Accept: application/activity+json" https://your-instance.com/c/some-local-community
curl -H "Accept: application/activity+json" https://your-instance.com/post/123 # the id of a local post
curl -H "Accept: application/activity+json" https://your-instance.com/comment/123 # the id of a local comment
```

### La récupération d'objets distants fonctionne, mais la publication/le commentaire dans les communautés distantes échoue.

Vérifiez que [la fédération est autorisée sur les deux instances](../federation/administration.md#instance-allowlist-and-blocklist).

Assurez-vous également que l'heure est correctement réglée sur votre serveur. Les activités sont signées avec un horodatage et seront rejetées si l'écart est supérieur à 10 secondes.
