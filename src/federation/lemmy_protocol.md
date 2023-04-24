# Lemmy Federation Protocol

The Lemmy Protocol (or Lemmy Federation Protocol) is a subset of the [ActivityPub Protocol](https://www.w3.org/TR/activitypub/), with some extensions.

This document is targeted at developers who are familiar with the ActivityPub and ActivityStreams protocols. It gives a detailed outline of the actors, objects and activities used by Lemmy.

Before reading this, have a look at our [Federation Overview](overview.md) to get an idea how Lemmy federation works on a high level.

<!-- toc -->

- [Context](#context)
- [Actors](#actors)
  - [Community](#community)
  - [User](#user)
  - [Instance](#instance)
- [Objects](#objects)
  - [Post](#post)
  - [Comment](#comment)
  - [Private Message](#private-message)
- [Collections](#collections)
  - [Community Outbox](#community-outbox)
  - [Community Followers](#community-followers)
  - [Community Moderators](#community-moderators)
  - [User Outbox](#user-outbox)
- [Activities](#activities)
  - [User to Community](#user-to-community)
    - [Follow](#follow)
    - [Unfollow](#unfollow)
    - [Report Post or Comment](#report-post-or-comment)
  - [Community to User](#community-to-user)
    - [Accept Follow](#accept-follow)
    - [Announce](#announce)
  - [Announcable](#announcable)
    - [Create or Update Post](#create-or-update-post)
    - [Create or Update Comment](#create-or-update-comment)
    - [Like Post or Comment](#like-post-or-comment)
    - [Dislike Post or Comment](#dislike-post-or-comment)
    - [Undo Like or Dislike Post or Comment](#undo-like-or-dislike-post-or-comment)
    - [Delete Post or Comment](#delete-post-or-comment)
    - [Remove Post or Comment](#remove-post-or-comment)
    - [Undo Delete or Remove](#undo-delete-or-remove)
    - [Add Mod](#add-mod)
    - [Remove Mod](#remove-mod)
    - [Block User](#block-user)
    - [Undo Block User](#undo-block-user)
  - [User to User](#user-to-user)
    - [Create or Update Private message](#create-or-update-private-message)
    - [Delete Private Message](#delete-private-message)
    - [Undo Delete Private Message](#undo-delete-private-message)

<!-- tocstop -->

## Context

```json
{{#include ../../include/crates/apub/assets/lemmy/context.json}}
```

The context is identical for all activities and objects.

## Actors

### Community

An automated actor. Users can send posts or comments to it, which the community forwards to its followers in the form of `Announce`.

Sends activities to user: `Accept/Follow`, `Announce`

Receives activities from user: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (only admin/mod), `Delete` (only creator), `Undo` (only for own actions)

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/group.json}}
```

| Field Name          | Description                                                                                           |
| ------------------- | ----------------------------------------------------------------------------------------------------- |
| `preferredUsername` | Name of the actor                                                                                     |
| `name`              | Title of the community                                                                                |
| `sensitive`         | True indicates that all posts in the community are nsfw                                               |
| `attributedTo`      | First the community creator, then all the remaining moderators                                        |
| `content`           | Text for the community sidebar, usually containing a description and rules                            |
| `icon`              | Icon, shown next to the community name                                                                |
| `image`             | Banner image, shown on top of the community page                                                      |
| `inbox`             | ActivityPub inbox URL                                                                                 |
| `outbox`            | ActivityPub outbox URL, only contains up to 20 latest posts, no comments, votes or other activities   |
| `followers`         | Follower collection URL, only contains the number of followers, no references to individual followers |
| `endpoints`         | Contains URL of shared inbox                                                                          |
| `published`         | Datetime when the community was first created                                                         |
| `updated`           | Datetime when the community was last changed                                                          |
| `publicKey`         | The public key used to verify signatures from this actor                                              |

### User

A person, interacts primarily with the community where it sends and receives posts/comments. Can also create and moderate communities, and send private messages to other users.

Sends activities to Community: `Follow`, `Undo/Follow`, `Create`, `Update`, `Like`, `Dislike`, `Remove` (only admin/mod), `Delete` (only creator), `Undo` (only for own actions)

Receives activities from Community: `Accept/Follow`, `Announce`

Sends and receives activities from/to other users: `Create/Note`, `Update/Note`, `Delete/Note`, `Undo/Delete/Note` (all those related to private messages)

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/person.json}}
```

| Field Name          | Description                                              |
| ------------------- | -------------------------------------------------------- |
| `preferredUsername` | Name of the actor                                        |
| `name`              | The user's displayname                                   |
| `content`           | User bio                                                 |
| `icon`              | The user's avatar, shown next to the username            |
| `image`             | The user's banner, shown on top of the profile           |
| `inbox`             | ActivityPub inbox URL                                    |
| `endpoints`         | Contains URL of shared inbox                             |
| `published`         | Datetime when the user signed up                         |
| `updated`           | Datetime when the user profile was last changed          |
| `publicKey`         | The public key used to verify signatures from this actor |

The user inbox is not actually implemented yet, and is only a placeholder for ActivityPub implementations which require it.

### Instance

Represents a Lemmy instance, and is used to federate global data like the instance description or site bans. It can be fetched from the root path.

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/instance.json}}
```

| Field Name  | Description                                              |
| ----------- | -------------------------------------------------------- |
| `name`      | Instance name                                            |
| `summary`   | Short description                                        |
| `content`   | Long description (sidebar)                               |
| `icon`      | Instance icon                                            |
| `image`     | Instance banner                                          |
| `inbox`     | ActivityPub inbox URL                                    |
| `endpoints` | Contains URL of shared inbox                             |
| `published` | Datetime when the instance was created                   |
| `updated`   | Datetime when the instance metadata                      |
| `publicKey` | The public key used to verify signatures from this actor |

## Objects

### Post

A page with title, and optional URL and text content. The URL often leads to an image, in which case a thumbnail is included. Each post belongs to exactly one community.

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/page.json}}
```

| Field Name        | Description                                                                                         |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| `attributedTo`    | ID of the user which created this post                                                              |
| `to`              | ID of the community where it was posted to                                                          |
| `name`            | Title of the post                                                                                   |
| `content`         | Body of the post                                                                                    |
| `url`             | An arbitrary link to be shared                                                                      |
| `image`           | Thumbnail for `url`, only present if it is an image link                                            |
| `commentsEnabled` | False indicates that the post is locked, and no comments can be added                               |
| `sensitive`       | True marks the post as NSFW, blurs the thumbnail and hides it from users with NSFW settign disabled |
| `stickied`        | True means that it is shown on top of the community                                                 |
| `published`       | Datetime when the post was created                                                                  |
| `updated`         | Datetime when the post was edited (not present if it was never edited)                              |

### Comment

A reply to a post, or reply to another comment. Contains only text (including references to other users or communities). Lemmy displays comments in a tree structure.

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/note.json}}
```

| Field Name     | Description                                                                                                                             |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| `attributedTo` | ID of the user who created the comment                                                                                                  |
| `to`           | Community where the comment was made                                                                                                    |
| `content`      | The comment text                                                                                                                        |
| `inReplyTo`    | IDs of the post where this comment was made, and the parent comment. If this is a top-level comment, `inReplyTo` only contains the post |
| `published`    | Datetime when the comment was created                                                                                                   |
| `updated`      | Datetime when the comment was edited (not present if it was never edited)                                                               |

### Private Message

A direct message from one user to another. Can not include additional users. Threading is not implemented yet, so the `inReplyTo` field is missing.

```json
{{#include ../../include/crates/apub/assets/lemmy/objects/chat_message.json}}
```

| Field Name     | Description                                                               |
| -------------- | ------------------------------------------------------------------------- |
| `attributedTo` | ID of the user who created this private message                           |
| `to`           | ID of the recipient                                                       |
| `content`      | The text of the private message                                           |
| `published`    | Datetime when the message was created                                     |
| `updated`      | Datetime when the message was edited (not present if it was never edited) |

## Collections

### Community Outbox

```json
{{#include ../../include/crates/apub/assets/lemmy/collections/group_outbox.json}}
```

The outbox only contains `Create/Post` activities for now.

### Community Followers

```json
{{#include ../../include/crates/apub/assets/lemmy/collections/group_followers.json}}
```

The followers collection is only used to expose the number of followers. Actor IDs are not included, to protect user privacy.

### Community Moderators

```json
{{#include ../../include/crates/apub/assets/lemmy/collections/group_moderators.json}}
```

### User Outbox

```json
{{#include ../../include/crates/apub/assets/lemmy/collections/person_outbox.json}}
```

## Activities

### User to Community

#### Follow

When the user clicks "Subscribe" in a community, a `Follow` is sent. The community automatically responds with an `Accept/Follow`.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/following/follow.json}}
```

#### Unfollow

Clicking on the unsubscribe button in a community causes an `Undo/Follow` to be sent. The community removes the user from its follower list after receiving it.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/following/undo_follow.json}}
```

#### Report Post or Comment

Reports a post or comment for rule violation, so that mods/admins review it.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/community/report_page.json}}
```

### Community to User

#### Accept Follow

Automatically sent by the community in response to a `Follow`. At the same time, the community adds this user to its followers list.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/following/accept.json}}
```

#### Announce

When the community receives a post or comment activity, it wraps that into an `Announce` and sends it to all followers.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/community/announce_create_page.json}}
```

### Announcable

All of these activities are sent from a user to a community. The community then wraps it in an Announce activity, and sends it to its followers.

#### Create or Update Post

When a user creates a new post, it is sent to the respective community. Editing a previously created post sends an almost identical activity, except the `type` being `Update`. We don't support mentions in posts yet.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/create_or_update/create_page.json}}
```

#### Create or Update Comment

A reply to a post, or to another comment. Can contain mentions of other users. Editing a previously created post sends an almost identical activity, except the `type` being `Update`.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/create_or_update/create_note.json}}
```

#### Like Post or Comment

An upvote for a post or comment.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/voting/like_note.json}}
```

#### Dislike Post or Comment

A downvote for a post or comment.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/voting/dislike_page.json}}
```

#### Undo Like or Dislike Post or Comment

Remove a vote that was previously done by the same user.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/voting/undo_like_note.json}}
```

#### Delete Post or Comment

Deletes a previously created post or comment. This can only be done by the original creator of that post/comment.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/deletion/delete_page.json}}
```

#### Remove Post or Comment

Removes a post or comment. This can only be done by a community mod, or by an admin on the instance where the community is hosted. The difference to delete is that remove activities have a summary field, which contains the reason for removal, as provided by the mod/admin.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/deletion/remove_note.json}}
```

#### Undo Delete or Remove

Reverts the action done by the activity in the object field. In this example, the removed Note is restored.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/deletion/undo_remove_note.json}}
```

#### Add Mod

Add a new mod to the community. Has to be sent by an existing community mod, or an admin of the community's instance.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/community/add_mod.json}}
```

#### Remove Mod

Remove an existing mod from the community. Has to be sent by an existing community mod, or an admin of the community's instance.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/community/remove_mod.json}}
```

#### Block User

Blocks a user so he can't participate anymore. The scope is determined by the `target` field: either a community, or a whole instance. The `removeData` field can optionally be set to indicate that all previous posts of the user should
be deleted.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/block/block_user.json}}
```

#### Undo Block User

Reverts a previous user block.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/block/undo_block_user.json}}
```

### User to User

#### Create or Update Private message

Creates a new private message between two users.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/create_or_update/create_private_message.json}}
```

#### Delete Private Message

Deletes a previous private message.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/deletion/delete_private_message.json}}
```

#### Undo Delete Private Message

Restores a previously deleted private message. The `object` is regenerated from scratch, as such the activity ID and other fields are different.

```json
{{#include ../../include/crates/apub/assets/lemmy/activities/deletion/undo_delete_private_message.json}}
```
