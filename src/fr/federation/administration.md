# Administration de la fédération

Note : La fédération ActivityPub est encore en cours de développement. Nous vous recommandons de ne l'activer que sur les instances de test pour le moment.

Pour activer la fédération, changez le paramètre `federation.enabled` en `true` dans `lemmy.hjson`, et redémarrez Lemmy.

La fédération ne démarre pas automatiquement, mais doit être déclenchée manuellement par la recherche. Pour ce faire, vous devez entrer une référence à un objet distant, tel que :

- `!main@lemmy.ml` (Communauté)
- `@nutomic@lemmy.ml` (Utilisateur)
- `https://lemmy.ml/c/programming` (Communauté)
- `https://lemmy.ml/u/nutomic` (Utilisateur)
- `https://lemmy.ml/post/123` (Publication)
- `https://lemmy.ml/comment/321` (Commentaire)

Pour un aperçu du fonctionnement technique de la fédération dans Lemmy, consultez notre [Aperçu de la fédération](contributing_federation_overview.md).

## Allowlist et blocklist de l'instance

La section fédération de la configuration de Lemmy a deux variables `allowed_instances` et `blocked_instances`. Celles-ci contrôlent avec quelles autres instances Lemmy va se fédérer. Les deux paramètres prennent une liste de domaines séparés par des virgules, par exemple `lemmy.ml,exemple.com`. Vous pouvez modifier ces paramètres soit via `/admin`, soit directement sur le système de fichiers du serveur.

Il est important de noter que ces paramètres n'affectent que l'envoi et la réception de données entre les instances. Si vous autorisez la fédération avec une certaine instance, puis la supprimez de la liste d'autorisation, cela n'affectera pas les données fédérées précédemment. Ces communautés, utilisateurs, messages et commentaires seront toujours affichés. Ils ne seront simplement plus mis à jour. Et même si une instance est bloquée, elle peut toujours récupérer et afficher les données publiques de votre instance.

Par défaut, les valeurs `allowed_instances` et `blocked_instances` sont vides, ce qui signifie que Lemmy se fédérera avec toute instance compatible. Nous ne recommandons pas cela, car les outils de modération ne sont pas encore prêts à traiter les instances malveillantes.

Ce que nous recommandons est de mettre une liste d'instances de confiance dans `allowed_instances`, et de ne se fédérer qu'avec celles-ci. Notez que les deux parties doivent s'ajouter mutuellement à leurs `allowed_instances` pour permettre une fédération bidirectionnelle.

Alternativement, vous pouvez aussi utiliser une fédération basée sur une liste de blocage. Dans ce cas, ajoutez les domaines des instances avec lesquelles vous ne voulez _pas_ vous fédérer. Vous ne pouvez définir que l'un des deux, `allowed_instances` et `blocked_instances`, car définir les deux n'a pas de sens.
