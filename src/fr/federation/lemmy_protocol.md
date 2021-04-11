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
  * [De l'utilisateur à la communauté](#utilisateur-à-la-communauté)
    + [Suivre](#suivre)
    + [Ne pas suivre](#ne-pas-suivre)
    + [Créer ou mettre à jour un poste](#créer-ou-mettre-à-jour-un-message)
    + [Créer ou mettre à jour un commentaire](#créer-ou-mettre-à-jour-un-commentaire)
    + [Aimer le message ou le commentaire](#jaime-un-message-ou-un-commentaire)
    + [Ne pas aimer le message ou le commentaire](#naime-pas-le-message-ou-le-commentaire)
    + [Supprimer un message ou un commentaire](#supprimer-un-message-ou-un-commentaire)
    + [Retirer un message ou le commentaire](#retirer-un-message-ou-le-commentaire)
    + [Défaire](#defaire)
    + [Ajouter un modérateur](#ajouter-un-mod)
    + [Supprimer un modérateur](#supprimer-un-mod)
  * [De la communauté à l'utilisateur](#communauté-à-lutilisateur)
    + [Accepter Suivre](#accepter-un-suivi)
    + [Annoncer](#annoncer)
    + [Retirer ou supprimer une communauté](#retirer-ou-supprimer-une-communauté)
    + [Restaurer une communauté retiré ou effacée](#rétablir-la-communauté-supprimée-ou-retirée)
  * [D'utilisateur à utilisateur](#utilisateur-à-utilisateur)
    + [Créer ou mettre à jour un message privé](#créer-ou-mettre-à-jour-un-message-privé)
    + [Supprimer un message privé](#supprimer-un-message-privé)
    + [Défaire Supprimer un message privé](#annuler-la-suppression-dun-message-privé)⏎

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `attributedTo` | oui | ID de l'utilisateur qui a créé le commentaire |
| `to` | oui | Communauté où le commentaire a été fait |
| `content` | oui | Le texte du commentaire |
| `inReplyTo` | oui | IDs du message où ce commentaire a été fait, et du commentaire parent. S'il s'agit d'un commentaire de haut niveau, `inReplyTo` ne contient que l'article. |
| `published` | non | La date de création du commentaire. |
| `updated` | non | Date à laquelle le commentaire a été modifié (non présent s'il n'a jamais été modifié) |

### Message privé

Un message direct d'un utilisateur à un autre. Il ne peut pas inclure d'autres utilisateurs. Le threading n'est pas encore implémenté, donc le champ `inReplyTo` est manquant.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `attributedTo` | ID de l'utilisateur qui a créé ce message privé |
| `to` | ID du destinataire |
| `content` | oui | Le texte du message privé |
| `published` | non | Date à laquelle le message a été créé |
| `updated` | non | Date à laquelle le message a été modifié (non présent s'il n'a jamais été modifié) |

## Activités

### Utilisateur à la communauté

#### Suivre

Lorsque l'utilisateur clique sur "Subscribe" dans une communauté, un `Follow` est envoyé. La communauté répond automatiquement par un `Accept/Follow`.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `actor` | oui | L'utilisateur qui envoie la demande de suivi.
| `object` | oui | La communauté à suivre |

#### Ne pas suivre

Cliquer sur le bouton de désabonnement d'une communauté provoque l'envoi d'un `Undo/Follow`. La communauté supprime l'utilisateur de sa liste de followers après l'avoir reçu.

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

#### Créer ou mettre à jour un message

Lorsqu'un utilisateur crée un nouveau message, celui-ci est envoyé à la communauté concernée. La modification d'un message précédemment créé envoie une activité presque identique, sauf que le type `type` est Mise à jour `Update`. Nous ne supportons pas encore les mentions dans les messages.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `type` | oui | soit `Create`, soit `Update` |...
| `cc` | oui | Communauté où le message est créé |
| `object` | oui | Le message en cours de création |

#### Créer ou mettre à jour un commentaire

Une réponse à un article ou à un autre commentaire. Peut contenir des mentions d'autres utilisateurs. La modification d'un message précédemment créé envoie une activité presque identique, sauf que le type `type` est Mise à jour `Update`.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `tag` | non | Liste des utilisateurs mentionnés dans le commentaire (comme `@utilisateur@exemple.com`) |
| `cc`| oui | La liste des utilisateurs mentionnés dans le commentaire (par exemple, `@`).
| `object` | oui | Le commentaire en cours de création |

#### J'aime un message ou un commentaire

Un vote positif pour un message ou un commentaire.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `cc` | oui | L'ID de la communauté où se trouve le message/commentaire. |
| `object` | oui | Le message ou le commentaire en cours de validation |

#### N'aime pas le message ou le commentaire

Un vote négatif pour un message ou un commentaire.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `cc` | oui | L'ID de la communauté où se trouve le message/commentaire. |
| `object` | oui | Le message ou le commentaire en cours de validation |

#### Supprimer un message ou un commentaire

Supprime un message ou un commentaire précédemment créé. Ceci ne peut être fait que par le créateur original de ce message ou commentaire.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `cc` | oui | L'ID de la communauté où se trouve le message/commentaire. |
| `object` | oui | ID du message ou du commentaire à supprimer |

#### Supprimer un message ou un commentaire

Supprime un message ou un commentaire. Cela ne peut être fait que par un mod de la communauté, ou par un administrateur sur l'instance où la communauté est hébergée.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `cc` | oui | L'ID de la communauté où se trouve le message/commentaire. |
| `object` | oui | ID du message ou du commentaire à supprimer |

#### Défaire

Défait une activité précédente, ne peut être fait que par l'acteur `actor` de l'objet`object`. Dans le cas d'un "J'aime" `Like` ou "Je n'aime pas" `Dislike`, le nombre de votes est modifié. Dans le cas d'un Supprimer `Delete` ou Retirer `Remove`, le message/commentaire est restauré. L'objet est régénéré à partir de zéro, l'ID de l'activité et les autres champs sont donc différents.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `object` | oui | Toute activité `Like`, `Dislike`, `Delete` ou `Remove` comme décrit ci-dessus |

#### Ajouter un mod

Ajoute un nouveau mod (enregistré sur `ds9.lemmy.ml`) à la communauté `!main@enterprise.lemmy.ml`. Doit être envoyé par un mod existant de la communauté.

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

#### Supprimer un mod

Supprime un mod existant de la communauté. Doit être envoyé par un mod existant de la communauté.

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
### Communauté à l'utilisateur

#### Accepter un suivi

Envoyé automatiquement par la communauté en réponse à un `Follow`. En même temps, la communauté ajoute cet utilisateur à sa liste de followers.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `actor` | oui | La même communauté que celle de l'activité `Follow` |
| `to` | non | L'ID de l'utilisateur qui a envoyé le `Follow` |
| `object` | oui | L'activité `Follow` précédemment envoyée |

#### Annoncer

Lorsque la communauté reçoit une activité de post ou de commentaire, elle l'intègre dans une `Announce` et l'envoie à tous les followers.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `object` | oui | Toute activité de type `Create`, `Update`, `Like`, `Dislike`, `Delete` `Remove` ou `Undo` décrite dans la section [User to Community](#user-to-community) |

#### Retirer ou supprimer une communauté

Un administrateur d'instance peut supprimer la communauté, ou un mod peut la supprimer. 

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `type` | oui | Soit `Remove` soit `Delete` |

#### Rétablir la communauté supprimée ou retirée

Rétablit le retrait ou la suppression.

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
| Nom du champ | Obligatoire | Description |
|---|---|---|
| `object.type` | oui | Soit `Remove` ou `Delete` |

### Utilisateur à Utilisateur

#### Créer ou mettre à jour un message privé 

Crée un nouveau message privé entre deux utilisateurs.

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

| Nom du champ | Obligatoire | Description |
|---|---|---|
| `type` | oui | Soit `Create`, soit `Update` |...
| `object` | oui | A [Private Message](#private-message) |

#### Supprimer un message privé

Supprime un message privé précédent.

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

#### Annuler la suppression d'un message privé

Restaure un message privé précédemment supprimé. L'objet est régénéré à partir de zéro, l'ID d'activité et les autres champs sont donc différents.

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
