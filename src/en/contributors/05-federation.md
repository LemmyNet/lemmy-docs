## Federation

Lemmy uses the ActivityPub protocol for communication between servers. If you are unfamiliar with the protocol, you can start by reading the [resource links](06-resources.md#activitypub-resources). This document explains how to interact with it from other projects.

In Lemmy we use some specific terms to refer to ActivityPub items. They are essentially our specific implementations of well-known ActivityPub concepts:

- Community: `Group`
- User: `Person`
- Post: `Page`
- Comment: `Note`

Almost every action in Lemmy happens inside a group. The Federation Enhancement Proposal [Group Federation](https://codeberg.org/fediverse/fep/src/branch/main/feps/fep-1b12.md) gives a high-level overview how this works. The generic federation logic is implemented in the [activitypub-federation](https://github.com/LemmyNet/activitypub-federation-rust) library. It can also be used by other Rust projects.

Sometimes you will see a notation like `Create/Note`. This refers to a `Create` activity with a `Note` as object.

Below are explanations and examples for all actors, objects and activities from Lemmy. These include many optional fields which you can safely ignore.

## Context

```json
{{#include ../../../include/crates/apub/assets/lemmy/context.json}}
```

The context is identical for all activities and objects.

## Actors

### Community

An automated actor. Users can send posts or comments to it, which the community forwards to its followers in the form of `Announce`.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/group.json}}
```

| Field Name          | Description                                                                                           |
| ------------------- | ----------------------------------------------------------------------------------------------------- |
| `preferredUsername` | Name of the actor                                                                                     |
| `name`              | Title of the community                                                                                |
| `sensitive`         | True indicates that all posts in the community are nsfw                                               |
| `attributedTo`      | First the community creator, then all the remaining moderators                                        |
| `summary`           | Text for the community sidebar, usually containing a description and rules                            |
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

A person, interacts primarily with the community where it sends and receives posts/comments. Can also create and moderate communities, and send private messages to other users. Can be followed from other platforms.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/person.json}}
```

| Field Name          | Description                                              |
| ------------------- | -------------------------------------------------------- |
| `preferredUsername` | Name of the actor                                        |
| `name`              | The user's displayname                                   |
| `summary`           | User bio                                                 |
| `icon`              | The user's avatar, shown next to the username            |
| `image`             | The user's banner, shown on top of the profile           |
| `inbox`             | ActivityPub inbox URL                                    |
| `endpoints`         | Contains URL of shared inbox                             |
| `published`         | Datetime when the user signed up                         |
| `updated`           | Datetime when the user profile was last changed          |
| `publicKey`         | The public key used to verify signatures from this actor |

### Instance

Represents a Lemmy instance, and is used to federate global data like the instance description or site bans. It can be fetched from the root path.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/instance.json}}
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

A page with title, and optional URL and text content. The attachment URL often leads to an image, in which case a thumbnail is included. Each post belongs to exactly one community. Sent out as `Page`, but for receiving the types `Article`, `Note`, `Video` and `Event` are also accepted.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/page.json}}
```

| Field Name        | Description                                                                                         |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| `attributedTo`    | ID of the user which created this post                                                              |
| `to`              | ID of the community where it was posted to                                                          |
| `name`            | Title of the post (mandatory)                                                                       |
| `content`         | Body of the post                                                                                    |
| `attachment`      | A single website or image link                                                                      |
| `image`           | Thumbnail for `url`, only present if it is an image link                                            |
| `commentsEnabled` | False indicates that the post is locked, and no comments can be added                               |
| `sensitive`       | True marks the post as NSFW, blurs the thumbnail and hides it from users with NSFW settign disabled |
| `stickied`        | True means that it is shown on top of the community                                                 |
| `published`       | Datetime when the post was created                                                                  |
| `updated`         | Datetime when the post was edited (not present if it was never edited)                              |

### Comment

A reply to a post, or reply to another comment. Contains only text (including references to other users or communities). Lemmy displays comments in a tree structure.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/note.json}}
```

| Field Name     | Description                                                                                                                           |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `attributedTo` | ID of the user who created the comment                                                                                                |
| `to`           | Community where the comment was made                                                                                                  |
| `content`      | The comment text                                                                                                                      |
| `inReplyTo`    | ID of the parent object. In case of a top-level comment this is the post ID, in case of a nested comment it is the parent comment ID. |
| `published`    | Datetime when the comment was created                                                                                                 |
| `updated`      | Datetime when the comment was edited (not present if it was never edited)                                                             |

### Private Message

A direct message from one user to another. Can not include additional users. Threading is not implemented yet, so the `inReplyTo` field is missing.

```json
{{#include ../../../include/crates/apub/assets/lemmy/objects/chat_message.json}}
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
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_outbox.json}}
```

The outbox only contains `Create/Post` activities for now.

### Community Followers

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_followers.json}}
```

The followers collection is only used to expose the number of followers. Actor IDs are not included, to protect user privacy.

### Community Moderators

List of moderators who can perform actions like removing posts or banning users.

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_moderators.json}}
```

### Community Featured Posts

List of posts which are stickied in the community.

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/group_featured_posts.json}}
```

### User Outbox

Only contains `totalItems` count, but no actual `items` for privacy reasons.

```json
{{#include ../../../include/crates/apub/assets/lemmy/collections/person_outbox.json}}
```

## Activities

### User to Community

#### Follow

Each Community page has a "Follow" button. Clicking this triggers a `Follow` activity to be sent from the user to the Community inbox. The Community will automatically respond with an `Accept/Follow` activity to the user inbox. It will also add the user to its list of followers, and deliver any activities about Posts/Comments in the Community to the user.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/follow.json}}
```

#### Unfollow

After following a Community, the "Follow" button is replaced by "Unfollow". Clicking this sends an `Undo/Follow` activity to the Community inbox. The Community removes the User from its followers list and doesn't send any activities to it anymore.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/undo_follow.json}}
```

#### Create or Update Post

When a user creates a new post, it is sent to the respective community as `Create/Page`. Editing a previously created post sends an almost identical activity, except the `type` being `Update`.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_page.json}}
```

#### Create or Update Comment

A reply to a post, or to another comment as `Create/Note`. Can contain mentions of other users. Editing a previously created post sends an almost identical activity, except the `type` being `Update`.

The origin instance also scans the Comment for any User mentions, and sends the `Create/Note` to
those Users as well.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_note.json}}
```

#### Like Post or Comment

An upvote for a post or comment.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/like_note.json}}
```

#### Dislike Post or Comment

A downvote for a post or comment.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/dislike_page.json}}
```

#### Undo Like or Dislike Post or Comment

Revert a vote that was previously done by the same user.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/voting/undo_like_note.json}}
```

#### Delete Post or Comment

Mods can remove Posts and Comments from their Communities. Admins can remove any Posts or Comments on the entire site. Communities can also be removed by admins. The item is then hidden from all users.

Removals are sent to all followers of the Community, so that they also take effect there. The exception is if an admin removes an item from a Community which is hosted on a different instance. In this case, the removal only takes effect locally.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/delete_page.json}}
```

#### Undo Delete

Post or comment deletions can be reverted by the same user.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/undo_delete_page.json}}
```

#### Report Post, comment or private message

Reports content for rule violation, so that mods/admins can review it.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/report_page.json}}
```

#### Delete User

Sent when a user deletes his own account.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/delete_user.json}}
```

### Community to User

#### Accept Follow

Automatically sent by the community in response to a `Follow`. At the same time, the community adds this user to its followers list.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/following/accept.json}}
```

#### Announce

If the Community receives any Post or Comment related activity (Create, Update, Like, Dislike, Remove, Delete, Undo etc.), it will forward this to its followers. For this, an Announce is created with the Community as actor, and the received activity as object. This is sent to all followers, so they get updated in real time.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/announce_create_page.json}}
```

### Moderation

These actions can only be done by instance admins or community moderators. They are sent to the community and announced by it. See [](../users/04-moderation.md) for a general overview how moderation works in Lemmy. Communities can only be created on the same instance where a user is registered. After that, mods from other instances can be added with `Add/User` activity.

#### Remove Post or Comment

Removes a post or comment. The difference to delete is that remove activities have a summary field, which contains the reason for removal, as provided by the mod/admin.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/remove_note.json}}
```

#### Block User

Blocks a user so he can't participate anymore. The scope is determined by the `target` field: either a community, or a whole instance. The `removeData` field can optionally be set to indicate that all previous posts of the user should be deleted.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/block/block_user.json}}
```

#### Lock post

Posts can be locked so that no new comments can be created.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/lock_page.json}}
```

#### Undo mod actions

All previously listed mod actions can be reverted by wrapping the original activity in `Undo`. Note that Lemmy regenerates the inner activity with a new ID.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/undo_remove_note.json}}
```

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/block/undo_block_user.json}}
```

#### Add or remove featured post

Posts can be pinned so that they are always shown on top of the community. This is federated with the [Community featured posts](#community-featured-posts) collection.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/add_featured_post.json}}
```

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/remove_featured_post.json}}
```

#### Add or remove mod

Add a new mod to the community. Has to be sent by an existing community mod, or an admin of the community's instance.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/add_mod.json}}
```

An existing mod can be removed in the same way.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/community/remove_mod.json}}
```

### User to User

#### Follow a user

Users from other platforms can follow Lemmy users and receive all of their posts to the inbox. Note that users who are registered on Lemmy can only follow groups, not other users.

```json
{{#include ../../../include/crates/apub/assets/pleroma/activities/follow.json}}
```

#### Create or Update Private message

User profiles have a "Send Message" button, which opens a dialog permitting to send a private message to this user. It is sent as a `Create/ChatMessage` to the user inbox. Private messages can only be directed at a single User. They can also be edited with `Update/ChatMessage`.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/create_or_update/create_private_message.json}}
```

#### Delete Private Message

Deletes a previous private message.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/delete_private_message.json}}
```

#### Undo Delete Private Message

Restores a previously deleted private message. The `object` is regenerated from scratch, as such the activity ID and other fields are different.

```json
{{#include ../../../include/crates/apub/assets/lemmy/activities/deletion/undo_delete_private_message.json}}
```
