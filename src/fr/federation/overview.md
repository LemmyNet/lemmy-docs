# Aperçu de la fédération


Ce document est destiné à tous ceux qui veulent savoir comment fonctionne la fédération Lemmy, sans être trop technique. Il est destiné à fournir un aperçu de haut niveau de la fédération ActivityPub dans Lemmy. Si vous implémentez ActivityPub vous-même et souhaitez être compatible avec Lemmy, lisez notre [ActivityPub API outline](contributing_apub_api_outline.md).

## Conventions de documentation

Pour garder les choses simples, vous verrez parfois des choses formatées comme `Create/Note`, `Delete/Event` ou `Undo/Follow`. La chose avant le slash est l'activité, et la chose après le slash est l'objet à l'intérieur de l'activité, dans une propriété `object`. Il faut donc les lire comme suit :

* `Create/Note` : une activité `Create` contenant une `Note` dans le champ `object`. 
* `Delete/Event` : une activité `Delete` contenant un `Event` dans le champ `object`.
* `Undo/Follow` : une activité `Undo` contenant un `Follow` dans le champ `object`.

Dans Lemmy, nous utilisons certains termes spécifiques pour désigner les éléments ActivityPub. Il s'agit essentiellement de nos implémentations spécifiques de concepts ActivityPub bien connus :

- Communauté (community) : `Group`
- Utilisateur (user) : `Person`
- Poste (post) : `Page`
- Commentaire (comment) : `Note`

Ce document comporte trois sections principales :

* __Philosophie de la fédération__ expose le modèle général de la manière dont le projet est censé se fédérer.
* __Les activités des utilisateurs__ décrivent les actions qu'un utilisateur peut entreprendre pour interagir.
* __Activités de la communauté__ décrit ce que la communauté fait en réponse à certaines actions de l'utilisateur.

## Federation philosophy

The primary Actor in Lemmy is the Community. Each community resides on a single instance, and consists of a list of Posts and a list of followers. The primary interaction is that of a User sending a Post or Comment related activity to the Community inbox, which then announces it to all its followers. 

Each Community has a specific creator User, who is responsible for setting rules, appointing moderators, and removing content that violates the rules.

Besides moderation on the community level, each instance has a set of administrator Users, who have the power to do site-wide removals and bans.

Users follow Communities that they are interested in, in order to receive Posts and Comments. They also vote on Posts and Comments, as well as creating new ones. Comments are organised in a tree structure and commonly sorted by number of votes. Direct messages between Users are also supported.

Users can not follow each other, and neither can Communities follow anything.

Our federation implementation is already feature complete, but so far we haven't focused at all on complying with the ActivityPub spec. As such, Lemmy is likely not compatible with implementations which expect to send and receive valid activities. This is something we plan to fix in the near future. Check out [#698](https://github.com/LemmyNet/lemmy/issues/698) for an overview of our deviations.

## Activités de l'utilisateur

## Philosophie de la Fédération

L'acteur principal de Lemmy est la communauté. Chaque communauté réside sur une seule instance, et se compose d'une liste de messages et d'une liste de followers. L'interaction principale est celle d'un utilisateur qui envoie une activité liée à un message ou à un commentaire à la boîte de réception de la communauté, qui l'annonce ensuite à tous ses suiveurs. 

Chaque communauté a un utilisateur créateur spécifique, qui est responsable de la définition des règles, de la nomination des modérateurs et de la suppression du contenu qui viole les règles.

Outre la modération au niveau de la communauté, chaque instance dispose d'un ensemble d'utilisateurs administrateurs, qui ont le pouvoir de supprimer et d'interdire des contenus sur l'ensemble du site.

Les utilisateurs suivent les communautés qui les intéressent, afin de recevoir des messages et des commentaires. Ils votent également sur les messages et les commentaires, et en créent de nouveaux. Les commentaires sont organisés en une structure arborescente et généralement triés par nombre de votes. Les messages directs entre utilisateurs sont également pris en charge.

Les utilisateurs ne peuvent pas se suivre les uns les autres, et les communautés ne peuvent pas non plus suivre quoi que ce soit.

Notre mise en œuvre de la fédération est déjà complète, mais jusqu'à présent nous ne nous sommes pas du tout concentrés sur la conformité à la spécification ActivityPub. En tant que tel, Lemmy n'est probablement pas compatible avec les implémentations qui s'attendent à envoyer et recevoir des activités valides. C'est un point que nous prévoyons de corriger dans un avenir proche. Consultez [#698](https://github.com/LemmyNet/lemmy/issues/698) pour un aperçu de nos déviations.

## Activités des utilisateurs

### Suivre une communauté

Chaque page de communauté a un bouton "Suivre". Cliquer sur ce bouton déclenche l'envoi d'une activité "Suivre" `Follow` de l'utilisateur vers la boîte de réception de la communauté. La communauté répondra automatiquement par une activité "Accepter/Suivre" `Accept/Follow` dans la boîte de réception de l'utilisateur. Elle ajoutera également l'utilisateur à sa liste de suiveurs et lui transmettra toutes les activités relatives aux messages et commentaires de la communauté.

### Annuler le suivi d'une communauté

Après avoir suivi une communauté, le bouton "Follow" est remplacé par "Unfollow". En cliquant sur ce bouton, vous envoyez une activité Annuler/Suivre `Undo/Follow` dans la boîte de réception de la communauté. La communauté supprime l'utilisateur de sa liste de followers et ne lui envoie plus d'activités.

### Créer un message

Quand un utilisateur crée un nouveau message dans une communauté donnée, il est envoyé comme Créer/Page `Create/Page` à la boîte de réception de la communauté.

### Créer un commentaire

Quand un nouveau commentaire est créé pour un message, l'ID du message et l'ID du commentaire parent (s'il existe)
sont écrits dans le champ `in_reply_to`. Cela permet de l'assigner au bon article, et de construire
l'arbre des commentaires. Il est ensuite envoyé dans la boîte de réception de la Communauté sous le nom de Créer/Noter `Create/Note`.

L'instance d'origine recherche également dans le commentaire toute mention d'utilisateur et envoie le `Create/Note` à ces utilisateurs.
à ces utilisateurs.

### Modifier un message

Modifie le contenu d'un message existant. Ne peut être fait que par l'utilisateur qui l'a créé.

### Modifier un commentaire

Modifie le contenu d'un commentaire existant. Ne peut être fait que par l'utilisateur qui l'a créé.

### J'aime et je n'aime pas

Les utilisateurs peuvent aimer ou ne pas aimer un message ou un commentaire. Ces commentaires sont envoyés sous forme de "J'aime/Page" `like/Page`, "Je n'aime pas/Note" `Dislike/Note`, etc. dans la boîte de réception de la communauté.

### Suppression

Le créateur d'un message, d'un commentaire ou d'une communauté peut le supprimer. La suppression est alors envoyée aux suiveurs de la communauté. L'élément est alors caché de tous les utilisateurs.

Les mods peuvent supprimer les messages et les commentaires de leurs communautés. Les administrateurs peuvent supprimer tout message ou commentaire sur l'ensemble du site. Les communautés peuvent également être supprimées par les administrateurs. L'élément est alors caché à tous les utilisateurs.

Les suppressions sont envoyées à tous les adeptes de la communauté, de sorte qu'elles y prennent également effet. L'exception est le cas où un administrateur supprime un élément d'une communauté qui est hébergée sur une instance différente. Dans ce cas, la suppression ne prend effet que localement.

### Revenir sur une action précédente

Nous ne supprimons rien de notre base de données, nous le cachons simplement aux utilisateurs. Les Communautés/Paroles/Commentaires supprimés ou retirés ont un bouton "restaurer". Ce bouton génère une activité `Undo` qui définit l'activité originale de suppression/suppression comme objet, comme `Undo/Remove/Post` ou `Undo/Delete/Community`.

Cliquer sur le bouton "+" d'un message ou d'un commentaire déjà noté (ou sur le bouton "-" d'un message ou d'un commentaire déjà noté) génère également un `Undo`. Dans ce cas, il s'agit d'un `Undo/Like/Post` ou d'un `Undo/Dislike/Comment`.

### Créer un message privé

Les profils d'utilisateurs ont un bouton "Envoyer un message", qui ouvre une boîte de dialogue permettant d'envoyer un message privé à cet utilisateur. Le message est envoyé sous la forme d'une `Create/Note` dans la boîte de réception de l'utilisateur. Les messages privés ne peuvent être adressés qu'à un seul utilisateur.

v## Modifier un message privé

`Update/Note` modifie le texte d'un message précédemment envoyé.

### Supprimer un message privé

`Delete/Note` supprime un message privé.

### Restaurer un message privé

`Undo/Delete/Note` rétablit la suppression d'un message privé.

## Activités de la Communauté

La communauté est essentiellement un robot, qui n'agit qu'en réaction aux actions des utilisateurs. L'utilisateur qui a créé la communauté devient le premier modérateur, et peut ajouter d'autres modérateurs. En général, lorsque la communauté reçoit une activité valide dans sa boîte de réception, cette activité est transmise à tous ses suiveurs.

### Accepter le suivi

Si la communauté reçoit une activité "Follow", elle répond automatiquement par "Accept/Follow". Elle ajoute également l'utilisateur à sa liste de suiveurs. 

### Unfollow

À la réception d'un `Undo/Follow`, la communauté supprime l'utilisateur de sa liste de followers.
 
#### Annoncer

Si la communauté reçoit une activité liée à un message ou à un commentaire (créer, mettre à jour, aimer, détester, retirer, supprimer, annuler), elle l'annoncera à ses membres. Pour cela, une Annonce est créée avec la Communauté comme acteur, et l'activité reçue comme objet. Les instances qui suivent restent ainsi informées de toutes les actions des communautés qu'elles suivent.

### Supprimer une communauté

Si le créateur ou un administrateur supprime la communauté, il envoie un `Delete/Group` à tous ses suiveurs.
