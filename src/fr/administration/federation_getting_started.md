# Fédération

Lemmy utilise le protocole ActivityPub (un standard du W3C) pour permettre la fédération entre différents serveurs (souvent appelés instances). Ceci est très similaire à la façon dont le courrier électronique fonctionne. Par exemple, si vous utilisez gmail.com, vous pouvez non seulement envoyer des e-mails à d'autres utilisateurs de gmail.com, mais aussi à yahoo.com, yandex.ru, etc. Le courrier électronique utilise le protocole SMTP pour y parvenir. Vous pouvez donc considérer ActivityPub comme un "SMTP pour les médias sociaux". La quantité d'actions différentes possibles sur les médias sociaux (poster, commenter, aimer, partager, etc.) signifie que ActivityPub est beaucoup plus compliqué que SMTP.

Comme pour le courrier électronique, la fédération ActivityPub se fait uniquement entre serveurs. Ainsi, si vous êtes enregistré sur `enterprise.lemmy.ml`, vous ne vous connectez qu'à l'API de `enterprise.lemmy.ml`, tandis que le serveur se charge d'envoyer et de recevoir des données d'autres instances (par exemple `voyager.lemmy.ml`). Le grand avantage de cette approche est que l'utilisateur moyen n'a rien à faire pour utiliser la fédération. En fait, si vous utilisez Lemmy, vous l'utilisez probablement déjà. Une façon de le confirmer est d'aller dans une communauté ou un profil d'utilisateur. Si vous êtes sur `enterprise.lemmy.ml` et que vous voyez un utilisateur comme `@nutomic@voyager.lemmy.ml`, ou une communauté comme `!main@ds9.lemmy.ml`, alors ceux-ci sont fédérés, ce qui signifie qu'ils utilisent une instance différente de la vôtre.

Une façon de profiter de la fédération est d'ouvrir une instance différente, comme `ds9.lemmy.ml`, et de la parcourir. Si vous voyez une communauté, un message ou un utilisateur intéressant avec lequel vous voulez interagir, copiez simplement son URL et collez-la dans la recherche de votre propre instance. Votre instance se connectera à l'autre (en supposant que la liste d'autorisation/de blocage le permette), et vous affichera directement le contenu distant, afin que vous puissiez suivre une communauté ou commenter un message. Voici quelques exemples de recherches qui fonctionnent :

- `!main@lemmy.ml` (Communauté)
- `@nutomic@lemmy.ml` (Utilisateur)
- `https://lemmy.ml/c/programming` (Communauté)
- `https://lemmy.ml/u/nutomic` (Utilisateur)
- `https://lemmy.ml/post/123` (Publication)
- `https://lemmy.ml/comment/321` (Commentaire)

Vous pouvez voir la liste des instances liées en suivant le lien "Instances" au bas de n'importe quelle page de Lemmy.

## Recherche de communautés

Si vous recherchez une communauté pour la première fois, 20 messages sont récupérés initialement. Ce n'est que si au moins un utilisateur de votre instance s'inscrit à la communauté distante que celle-ci enverra des mises à jour à votre instance. Les mises à jour incluent :

- Nouveaux messages, commentaires
- Votes
- Modifications et suppressions de messages et de commentaires
- Actions des modérateurs

Vous pouvez copier l'URL de la communauté depuis la barre d'adresse de votre navigateur et l'insérer dans votre champ de recherche. Attendez quelques secondes, le message apparaîtra ci-dessous. Pour l'instant, il n'y a pas d'indicateur de chargement pour la recherche, donc attendez quelques secondes si elle n'affiche "aucun résultat".

## Récupération des messages

Collez l'URL d'un message dans le champ de recherche de votre instance Lemmy. Attendez quelques secondes jusqu'à ce que le message apparaisse. Cette opération permet également de récupérer le profil de la communauté et celui de l'auteur du message.

## Récupération des commentaires

Si vous trouvez un commentaire intéressant sous un post sur une autre instance, vous pouvez trouver le symbole d'un lien sous le commentaire dans le menu à 3 points. Copiez ce lien. Il ressemble à `https://lemmy.ml/post/56382/comment/40796`. Enlevez la partie `post/XXX` et mettez-le dans votre barre de recherche. Pour cet exemple, recherchez `https://lemmy.ml/comment/40796`. Ce commentaire, tous les commentaires parents, les utilisateurs, la communauté et le message correspondant sont récupérés depuis l'instance distante, s'ils ne sont pas connus localement.

Les commentaires parents ne sont pas récupérés ! Si vous voulez plus de commentaires sur des articles plus anciens, vous devez rechercher chacun d'entre eux comme décrit ci-dessus.
