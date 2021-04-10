# Protocole de la Fédération Lemmy

Le protocole Lemmy (ou protocole de la fédération Lemmy) est un sous-ensemble strict du [protocole ActivityPub](https://www.w3.org/TR/activitypub/). Toute déviation du protocole ActivityPub est un bug dans Lemmy ou dans cette documentation (ou les deux).

Ce document s'adresse aux développeurs qui sont familiers avec les protocoles ActivityPub et ActivityStreams. Il donne un aperçu détaillé des acteurs, objets et activités utilisés par Lemmy.

Avant de lire ce document, jetez un coup d'œil à notre [Aperçu de la fédération](contributing_federation_overview.md) pour avoir une idée du fonctionnement de la fédération Lemmy à un haut niveau.

Lemmy ne suit pas encore la spécification ActivityPub à tous égards. Par exemple, nous ne définissons pas un contexte valide en indiquant nos champs de contexte. Nous ignorons également les champs comme `inbox`, `outbox` ou `endpoints` pour les acteurs distants, et supposons que tout est Lemmy. Pour un aperçu des déviations, lisez [#698](https://github.com/LemmyNet/lemmy/issues/698). Elles seront corrigées dans un futur proche.

Lemmy est également très peu flexible en ce qui concerne les activités et les objets entrants. Ils doivent être exactement identiques aux exemples ci-dessous. Des choses comme avoir un tableau au lieu d'une valeur unique, ou un ID d'objet au lieu de l'objet complet entraîneront une erreur.

Dans les tableaux suivants, le terme "obligatoire" indique si Lemmy accepte ou non une activité entrante sans ce champ. Lemmy lui-même inclura toujours tous les champs non vides.

<!-- toc -->

- [Contexte](#contexte)
- [Acteurs](#acteurs)
  * [Communauté](#communauté)
    + [Boîte de sortie communautaire](#boîte-de-sortie-communautaire)
    + [Suiveurs de la communauté](#suiveurs-de-la-communauté)
    + [Modérateurs de la communauté](#modérateurs-de-la-communauté)
  * [Utilisateur](#utilisateur)
    + [Boîte de sortie de l'utilisateur](#boîte-de-sortie-de-lutilisateur)
- [Objets](#objets)
  * [Publication](#publication)
  * [Commentaire](#commentaire)
  * [Message privé](#message-privé)
- [Activités](#activités)
  * [De l'utilisateur à la communauté](#de-lutilisateur-à-la-communauté)
    + [Suivre](#suivre)
    + [Ne pas suivre](#ne-pas-suivre)
    + [Créer ou mettre à jour un poste](#creer-ou-mettre-a-jour-un-poste)
    + [Créer ou mettre à jour un commentaire](#creer-ou-mettre-a-jour-un-commentaire)
    + [Aimer le message ou le commentaire](#aimer-le-message-ou-le-commentaire)
    + [Ne pas aimer le message ou le commentaire](#ne-pas-aimer-le-message-ou-le-commentaire)
    + [Supprimer un message ou un commentaire](#supprimer-un-message-ou-un-commenataire)
    + [Retirer un message ou le commentaire](#retirer-un-message-ou-le-commentaire)
    + [Défaire](#defaire)
  * [De la communauté à l'utilisateur](#de-la-communaute-a-lutilisateur)
    + [Accepter Suivre](#accepter-suivre)
    + [Annoncer](#annoncer)
    + [Retirer ou supprimer la communauté](#retirer-ou-supprimer-la-communaute)
    + [Restaurer une communauté retiré ou effacée](#restaurer-une-communaute-retirer-ou-efface)
  * [D'utilisateur à utilisateur](#dutilisateur-a-utilisateur)
    + [Créer ou mettre à jour un message privé](#creer-ou-mettre-a-jour-un-message-prive)
    + [Supprimer un message privé](#supprimer-un-message-prive)
    + [Défaire Supprimer un message privé](#defaire-supprimer-une-message-prive)⏎

<!-- tocstop -->

## Contexte

```json
{
    "@context": [
        "https://www.w3.org/ns/activitystreams",
        {
            "moderators": "as:moderators",
            "sc": "http://schema.org#",
            "stickied": "as:stickied",
            "sensitive": "as:sensitive",
            "pt": "https://join.lemmy.ml#",
            "comments_enabled": {
                "type": "sc:Boolean",
                "id": "pt:commentsEnabled"
            }
        },
        "https://w3id.org/security/v1"
    ]
}
```

Le contexte est identique pour toutes les activités et tous les objets.

## Acteurs

### Communauté

Un acteur automatisé. Les utilisateurs peuvent lui envoyer des messages ou des commentaires, que la communauté transmet à ses adeptes sous la forme d'un `Announce`.

Envoie des activités à l'utilisateur : `Accept/Follow`, `Announce`.

Reçoit des activités de l'utilisateur : `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (seulement admin/mod), `Delete` (seul créateur), `Undo` (uniquement pour ses propres actions).

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/c/main",
    "type": "Group",
    "preferredUsername": "main",
    "name": "The Main Community",
    "sensitive": false,
    "content": "Welcome to the default community!",
    "mediaType": "text/html",
    "source": {
        "content": "Welcome to the default community!",
        "mediaType": "text/markdown"
    },
    "icon": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/Z8pFFb21cl.png"
    },
    "image": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/Wt8zoMcCmE.jpg"
    },
    "inbox": "https://enterprise.lemmy.ml/c/main/inbox",
    "outbox": "https://enterprise.lemmy.ml/c/main/outbox",
    "followers": "https://enterprise.lemmy.ml/c/main/followers",
    "moderators": "https://enterprise.lemmy.ml/c/main/moderators",
    "endpoints": {
        "sharedInbox": "https://enterprise.lemmy.ml/inbox"
    },
    "published": "2020-10-06T17:27:43.282386+00:00",
    "updated": "2020-10-08T11:57:50.545821+00:00",
    "publicKey": {
        "id": "https://enterprise.lemmy.ml/c/main#main-key",
        "owner": "https://enterprise.lemmy.ml/c/main",
        "publicKeyPem": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA9JJ7Ybp/H7iXeLkWFepg\ny4PHyIXY1TO9rK3lIBmAjNnkNywyGXMgUiiVhGyN9yU7Km8aWayQsNHOkPL7wMZK\nnY2Q+CTQv49kprEdcDVPGABi6EbCSOcRFVaUjjvRHf9Olod2QP/9OtX0oIFKN2KN\nPIUjeKK5tw4EWB8N1i5HOuOjuTcl2BXSemCQLAlXerLjT8xCarGi21xHPaQvAuns\nHt8ye7fUZKPRT10kwDMapjQ9Tsd+9HeBvNa4SDjJX1ONskNh2j4bqHHs2WUymLpX\n1cgf2jmaXAsz6jD9u0wfrLPelPJog8RSuvOzDPrtwX6uyQOl5NK00RlBZwj7bMDx\nzwIDAQAB\n-----END PUBLIC KEY-----\n"
    }
}
```

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `preferredUsername` | oui | Nom de l'acteur |
| `name` | oui | Titre de la communauté |
| `sensitive` | oui | True indique que tous les messages dans la communauté sont nsfw |
| `attributedTo` | oui | D'abord le créateur de la communauté, puis tous les autres modérateurs. |
| `content` | non | Texte pour la barre latérale de la communauté, contenant généralement une description et des règles. |
| `icon` | non | Icône, affichée à côté du nom de la communauté |
| `image` | non | Image de bannière, affichée en haut de la page de la communauté |
| `inbox` | non | URL de la boîte de réception ActivityPub |
| `outbox` | non | ActivityPub URL de la boîte de sortie, contient uniquement les 20 derniers messages, sans commentaires, votes ou autres activités. |
| `followers` | non | URL de la collection de suiveurs, contenant uniquement le nombre de suiveurs, sans référence à des suiveurs individuels. |
| `endpoints` | non | Contient l'URL de la boîte de réception partagée |
| `published` | non | Date à laquelle la communauté a été créée pour la première fois |
| `updated` | non | Date à laquelle la communauté a été modifiée pour la dernière fois |
| `publicKey` | oui | La clé publique utilisée pour vérifier les signatures de cet acteur. |
   
#### Boîte de sortie communautaire

```json
{
    "@context": ...,
    "items": [
      ...
    ],
    "totalItems": 3,
    "id": "https://enterprise.lemmy.ml/c/main/outbox",
    "type": "OrderedCollection"
}
```

La boîte d'envoi ne contient pour l'instant que les activités Créer/Poster `Create/Post`.

#### Suiveurs de la communauté

```json
{
  "totalItems": 2,
  "@context": ...,
  "id": "https://enterprise.lemmy.ml/c/main/followers",
  "type": "Collection"
}
```

La collection de followers est uniquement utilisée pour exposer le nombre de followers. Les identifiants des acteurs ne sont pas inclus, afin de protéger la vie privée des utilisateurs.

#### Modérateurs de la communauté

```json
{
    "items": [
        "https://enterprise.lemmy.ml/u/picard",
        "https://enterprise.lemmy.ml/u/riker"
    ],
    "totalItems": 2,
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/c/main/moderators",
    "type": "OrderedCollection"
}
```

### Utilisateur

Une personne, interagit principalement avec la communauté où elle envoie et reçoit des messages/commentaires. Peut également créer et modérer des communautés, et envoyer des messages privés à d'autres utilisateurs.

Envoie des activités à la communauté : Suivre `Follow`, Annuler/Suivre `Undo/Follow`, Créer `Create`, Mettre à jour `Update`, Aimer `Like`, Ne pas aimer `Dislike`, Retirer `Remove` (seulement admin/mod), Supprimer `Delete` (seulement créateur), Défaire `Undo` (seulement pour ses propres actions).

Reçoit des activités de la communauté : Accepter/Suivre `Accept/Follow`, Annoncer `Announce`.

Envoie et reçoit des activités de/vers d'autres utilisateurs : Créer/Note `Create/Note`, Mettre à jour/Note `Update/Note`, Supprimer/Note `Delete/Note`, Défaire/Supprimer/Note `Undo/Delete/Note` (toutes celles relatives aux messages privés)

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/u/picard",
    "type": "Person",
    "preferredUsername": "picard",
    "name": "Jean-Luc Picard",
    "content": "The user bio",
    "mediaType": "text/html",
    "source": {
        "content": "The user bio",
        "mediaType": "text/markdown"
    },
    "icon": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/DS3q0colRA.jpg"
    },
    "image": {
        "type": "Image",
        "url": "https://enterprise.lemmy.ml/pictrs/image/XenaYI5hTn.png"
    },
    "inbox": "https://enterprise.lemmy.ml/u/picard/inbox",
    "endpoints": {
        "sharedInbox": "https://enterprise.lemmy.ml/inbox"
    },
    "published": "2020-10-06T17:27:43.234391+00:00",
    "updated": "2020-10-08T11:27:17.905625+00:00",
    "publicKey": {
        "id": "https://enterprise.lemmy.ml/u/picard#main-key",
        "owner": "https://enterprise.lemmy.ml/u/picard",
        "publicKeyPem": "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyH9iH83+idw/T4QpuRSY\n5YgQ/T5pJCNxvQWb6qcCu3gEVigfbreqZKJpOih4YT36wu4GjPfoIkbWJXcfcEzq\nMEQoYbPStuwnklpN2zj3lRIPfGLht9CAlENLWikTUoW5kZLyU6UQtOGdT2b1hDuK\nsUEn67In6qYx6pal8fUbO6X3O2BKzGeofnXgHCu7QNIuH4RPzkWsLhvwqEJYP0zG\nodao2j+qmhKFsI4oNOUCGkdJejO7q+9gdoNxAtNNKilIOwUFBYXeZJb+XGlzo0X+\n70jdJ/xQCPlPlItU4pD/0FwPLtuReoOpMzLi20oDsPXJBvn+/NJaxqDINuywcN5p\n4wIDAQAB\n-----END PUBLIC KEY-----\n"
    }
}
```

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `preferredUsername` | oui | Nom de l'acteur |
| `name` | non | Nom d'affichage de l'utilisateur |
| `content` | non | Biographie de l'utilisateur |
| `icon` | non | L'avatar de l'utilisateur, affiché à côté de son nom d'utilisateur |
| `image` | non | La bannière de l'utilisateur, affichée en haut du profil |
| `inbox` | non | URL de la boîte de réception d'ActivityPub |
| `endpoints` | non | Contient l'URL de la boîte de réception partagée |
| `published` | non | La date de l'inscription de l'utilisateur. 
| `updated` | non | Date à laquelle le profil de l'utilisateur a été modifié en dernier lieu |
| `publicKey` | oui | La clé publique utilisée pour vérifier les signatures de cet acteur |

#### Boîte de sortie de l'utilisateur

```json
{
    "items": [],
    "totalItems": 0,
    "@context": ...,
    "id": "http://lemmy-alpha:8541/u/lemmy_alpha/outbox",
    "type": "OrderedCollection"
}
```

La boîte de réception de l'utilisateur n'a pas encore été implémentée et n'est qu'un substitut pour les implémentations de ActivityPub qui en ont besoin.

## Objets

### Publication

Une page avec un titre, une URL facultative et un contenu textuel. L'URL mène souvent à une image, auquel cas une vignette est incluse. Chaque message appartient à une seule communauté.

```json
{
    "@context": ...,
    "id": "https://voyager.lemmy.ml/post/29",
    "type": "Page",
    "attributedTo": "https://voyager.lemmy.ml/u/picard",
    "to": [
      "https://voyager.lemmy.ml/c/main",
      "https://www.w3.org/ns/activitystreams#Public"
    ],
    "name": "Test thumbnail 2",
    "content": "blub blub",
    "mediaType": "text/html",
    "source": {
        "content": "blub blub",
        "mediaType": "text/markdown"
    },
    "url": "https://voyager.lemmy.ml:/pictrs/image/fzGwCsq7BJ.jpg",
    "image": {
        "type": "Image",
        "url": "https://voyager.lemmy.ml/pictrs/image/UejwBqrJM2.jpg"
    },
    "commentsEnabled": true,
    "sensitive": false,
    "stickied": false,
    "published": "2020-09-24T17:42:50.396237+00:00",
    "updated": "2020-09-24T18:31:14.158618+00:00"
}
```

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `attributedTo` | oui | ID de l'utilisateur qui a créé ce message |
| `to` | oui | ID de la communauté où il a été posté |
| `name` | oui | Titre du message |
| `content` | non | Corps du message |
| `url` | non | Un lien arbitraire à partager |
| `image` | non | Miniature pour `url`, seulement présent si c'est un lien d'image |
| `commentsEnabled` | oui | False indique que le message est verrouillé, et qu'aucun commentaire ne peut être ajouté |
| `sensitive` | oui | True marque le message comme NSFW, brouille la vignette et la cache aux utilisateurs dont le paramètre NSFW est désactivé |
| `stickied` | oui | Le message est affiché en haut de la page de la communauté. |
| `published` | non | La date et l'heure de création de l'article. |
| `updated` | non | La date à laquelle le message a été édité (non présent s'il n'a jamais été édité). |

### Commentaire

Une réponse à un message, ou une réponse à un autre commentaire. Ne contient que du texte (y compris des références à d'autres utilisateurs ou communautés). Lemmy affiche les commentaires sous forme d'arborescence.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/comment/95",
    "type": "Note",
    "attributedTo": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "content": "mmmk",
    "mediaType": "text/html",
    "source": {
        "content": "mmmk",
        "mediaType": "text/markdown"
    },
    "inReplyTo": [
        "https://enterprise.lemmy.ml/post/38",
        "https://voyager.lemmy.ml/comment/73"
    ],
    "published": "2020-10-06T17:53:22.174836+00:00",
    "updated": "2020-10-06T17:53:22.174836+00:00"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `attributedTo` | yes | ID of the user who created the comment |
| `to` | yes | Community where the comment was made |
| `content` | yes | The comment text |
| `inReplyTo` | yes | IDs of the post where this comment was made, and the parent comment. If this is a top-level comment, `inReplyTo` only contains the post |
| `published` | no | Datetime when the comment was created |
| `updated` | no | Datetime when the comment was edited (not present if it was never edited) |

### Private Message

A direct message from one user to another. Can not include additional users. Threading is not implemented yet, so the `inReplyTo` field is missing.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/private_message/34",
    "type": "Note",
    "attributedTo": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://voyager.lemmy.ml/u/janeway",
    "content": "test",
    "source": {
        "content": "test",
        "mediaType": "text/markdown"
    },
    "mediaType": "text/markdown",
    "published": "2020-10-08T19:10:46.542820+00:00",
    "updated": "2020-10-08T20:13:52.547156+00:00"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `attributedTo` | ID of the user who created this private message |
| `to` | ID of the recipient |
| `content` | yes | The text of the private message |
| `published` | no | Datetime when the message was created |
| `updated` | no | Datetime when the message was edited (not present if it was never edited) |

## Activities

### User to Community

#### Follow

When the user clicks "Subscribe" in a community, a `Follow` is sent. The community automatically responds with an `Accept/Follow`.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/follow/2e4784b7-4edf-4fa1-a352-674d5d5f8891",
    "type": "Follow",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "to": "https://ds9.lemmy.ml/c/main",
    "object": "https://ds9.lemmy.ml/c/main"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `actor` | yes | The user that is sending the follow request |
| `object` | yes | The community to be followed |

#### Unfollow

Clicking on the unsubscribe button in a community causes an `Undo/Follow` to be sent. The community removes the user from its follower list after receiving it.

```json
{
    "@context": ...,
    "id": "http://lemmy-alpha:8541/activities/undo/2c624a77-a003-4ed7-91cb-d502eb01b8e8",
    "type": "Undo",
    "actor": "http://lemmy-alpha:8541/u/lemmy_alpha",
    "to": "http://lemmy-beta:8551/c/main",
    "object": {
        "@context": ...,
        "id": "http://lemmy-alpha:8541/activities/follow/f0d732e7-b1e7-4857-a5e0-9dc83c3f7ee8",
        "type": "Follow",
        "actor": "http://lemmy-alpha:8541/u/lemmy_alpha",
        "object": "http://lemmy-beta:8551/c/main"
    }
}
```

#### Create or Update Post

When a user creates a new post, it is sent to the respective community. Editing a previously created post sends an almost identical activity, except the `type` being `Update`. We don't support mentions in posts yet.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/create/6e11174f-501a-4531-ac03-818739bfd07d",
    "type": "Create",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "https://ds9.lemmy.ml/c/main/"
    ],
    "object": ...
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `type` | yes | either `Create` or `Update` |
| `cc` | yes | Community where the post is being made |
| `object` | yes | The post being created |

#### Create or Update Comment

A reply to a post, or to another comment. Can contain mentions of other users. Editing a previously created post sends an almost identical activity, except the `type` being `Update`.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/create/6f52d685-489d-4989-a988-4faedaed1a70",
    "type": "Create",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "tag": [{
        "type": "Mention",
        "name": "@sisko@ds9.lemmy.ml",
        "href": "https://ds9.lemmy.ml/u/sisko"
    }],
    "cc": [
        "https://ds9.lemmy.ml/c/main/",
        "https://ds9.lemmy.ml/u/sisko"
    ],
    "object": ...
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `tag` | no | List of users which are mentioned in the comment (like `@user@example.com`) |
| `cc` | yes | Community where the post is being made, the user being replied to (creator of the parent post/comment), as well as any mentioned users |
| `object` | yes | The comment being created |

#### Like Post or Comment

An upvote for a post or comment.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/like/8f3f48dd-587d-4624-af3d-59605b7abad3",
    "type": "Like",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/p/123"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `cc` | yes | ID of the community where the post/comment is |
| `object` | yes | The post or comment being upvoted |

#### Dislike Post or Comment

A downvote for a post or comment.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/dislike/fd2b8e1d-719d-4269-bf6b-2cadeebba849",
    "type": "Dislike",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/p/123"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `cc` | yes | ID of the community where the post/comment is |
| `object` | yes | The post or comment being upvoted |

#### Delete Post or Comment

Deletes a previously created post or comment. This can only be done by the original creator of that post/comment.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/delete/f1b5d57c-80f8-4e03-a615-688d552e946c",
    "type": "Delete",
    "actor": "https://enterprise.lemmy.ml/u/riker",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://enterprise.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/post/32"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `cc` | yes | ID of the community where the post/comment is |
| `object` | yes | ID of the post or comment being deleted |

#### Remove Post or Comment

Removes a post or comment. This can only be done by a community mod, or by an admin on the instance where the community is hosted.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/remove/aab93b8e-3688-4ea3-8212-d00d29519218",
    "type": "Remove",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": "https://enterprise.lemmy.ml/comment/32"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `cc` | yes | ID of the community where the post/comment is |
| `object` | yes | ID of the post or comment being removed |

#### Undo

Reverts a previous activity, can only be done by the `actor` of `object`. In case of a `Like` or `Dislike`, the vote count is changed back. In case of a `Delete` or `Remove`, the post/comment is restored. The `object` is regenerated from scratch, as such the activity ID and other fields are different.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/undo/70ca5fb2-e280-4fd0-a593-334b7f8a5916",
    "type": "Undo",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
        "https://ds9.lemmy.ml/c/main/"
    ],
    "object": ...
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `object` | yes | Any `Like`, `Dislike`, `Delete` or `Remove` activity as described above |

#### Add Mod

Add a new mod (registered on `ds9.lemmy.ml`) to the community `!main@enterprise.lemmy.ml`. Has to be sent by an existing community mod.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/add/531471b1-3601-4053-b834-d26718da2a06",
    "type": "Add",
    "cc": [
        "https://enterprise.lemmy.ml/c/main"
    ],
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "object": "https://ds9.lemmy.ml/u/sisko",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "target": "https://enterprise.lemmy.ml/c/main/moderators"
}
```

#### Remove Mod

Remove an existing mod from the community. Has to be sent by an existing community mod.

```json
{
    "@context": ...,
    "id": "https://enterprise.lemmy.ml/activities/remove/63b9a5b2-d3f8-4371-a7eb-711c7928b3c0",
    "type": "Remove",
    "object": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "actor": "https://enterprise.lemmy.ml/u/picard",
    "cc": [
        "https://enterprise.lemmy.ml/c/main"
    ],
    "target": "https://enterprise.lemmy.ml/c/main/moderators"
}
```
### Community to User

#### Accept Follow

Automatically sent by the community in response to a `Follow`. At the same time, the community adds this user to its followers list.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/accept/5314bf7c-dab8-4b01-baf2-9be11a6a812e",
    "type": "Accept",
    "actor": "https://ds9.lemmy.ml/c/main",
    "to": "https://enterprise.lemmy.ml/u/picard",
    "object": {
        "@context": ...,
        "id": "https://enterprise.lemmy.ml/activities/follow/2e4784b7-4edf-4fa1-a352-674d5d5f8891",
        "type": "Follow",
        "object": "https://ds9.lemmy.ml/c/main",
        "actor": "https://enterprise.lemmy.ml/u/picard"
    }
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `actor` | yes | The same community as in the `Follow` activity |
| `to` | no | ID of the user which sent the `Follow` |
| `object` | yes | The previously sent `Follow` activity |

#### Announce

When the community receives a post or comment activity, it wraps that into an `Announce` and sends it to all followers.

```json
{
  "@context": ...,
  "id": "https://ds9.lemmy.ml/activities/announce/b98382e8-6cb1-469e-aa1f-65c5d2c31cc4",
  "type": "Announce",
  "actor": "https://ds9.lemmy.ml/c/main",
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "cc": [
    "https://ds9.lemmy.ml/c/main/followers"
  ],
  "object": ...
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `object` | yes | Any of the `Create`, `Update`, `Like`, `Dislike`, `Delete` `Remove` or `Undo` activity described in the [User to Community](#user-to-community) section |

#### Remove or Delete Community

An instance admin can remove the community, or a mod can delete it. 

```json
{
  "@context": ...,
  "id": "http://ds9.lemmy.ml/activities/remove/e4ca7688-af9d-48b7-864f-765e7f9f3591",
  "type": "Remove",
  "actor": "http://ds9.lemmy.ml/c/some_community",
  "cc": [
    "http://ds9.lemmy.ml/c/some_community/followers"
  ],
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "object": "http://ds9.lemmy.ml/c/some_community"
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `type` | yes | Either `Remove` or `Delete` |

#### Restore Removed or Deleted Community

Reverts the removal or deletion.

```json
{
  "@context": ...,
  "id": "http://ds9.lemmy.ml/activities/like/0703668c-8b09-4a85-aa7a-f93621936901",
  "type": "Undo",
  "actor": "http://ds9.lemmy.ml/c/some_community",
  "to": "https://www.w3.org/ns/activitystreams#Public",
  "cc": [
    "http://ds9.lemmy.ml/c/testcom/followers"
  ],
  "object": {
    "@context": ...,
    "id": "http://ds9.lemmy.ml/activities/remove/1062b5e0-07e8-44fc-868c-854209935bdd",
    "type": "Remove",
    "actor": "http://ds9.lemmy.ml/c/some_community",
    "object": "http://ds9.lemmy.ml/c/testcom",
    "to": "https://www.w3.org/ns/activitystreams#Public",
    "cc": [
      "http://ds9.lemmy.ml/c/testcom/followers"
    ]
  }
}

```
| Field Name | Mandatory | Description |
|---|---|---|
| `object.type` | yes | Either `Remove` or `Delete` |

### User to User

#### Create or Update Private message 

Creates a new private message between two users.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/create/202daf0a-1489-45df-8d2e-c8a3173fed36",
    "type": "Create",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": ...
}
```

| Field Name | Mandatory | Description |
|---|---|---|
| `type` | yes | Either `Create` or `Update` |
| `object` | yes | A [Private Message](#private-message) |

#### Delete Private Message

Deletes a previous private message.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/delete/2de5a5f3-bf26-4949-a7f5-bf52edfca909",
    "type": "Delete",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": "https://ds9.lemmy.ml/private_message/341"
}
```

#### Undo Delete Private Message

Restores a previously deleted private message. The `object` is regenerated from scratch, as such the activity ID and other fields are different.

```json
{
    "@context": ...,
    "id": "https://ds9.lemmy.ml/activities/undo/b24bc56d-5db1-41dd-be06-3f1db8757842",
    "type": "Undo",
    "actor": "https://ds9.lemmy.ml/u/sisko",
    "to": "https://enterprise.lemmy.ml/u/riker/inbox",
    "object": ...
}
```
