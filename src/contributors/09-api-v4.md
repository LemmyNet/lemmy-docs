# API v4 Upgrade Guide

This document outlines the main changes between API v3 (Lemmy 0.19) and API v4 (Lemmy 1.0). You can use the following resources to adapt the new API:

- [Official API docs (including OpenAPI spec)](https://join-lemmy.org/api/main)
- Browse [voyager.lemmy.ml](https://voyager.lemmy.ml), and use the browser console to see which API requests are made
- Look at the relevant pull requests for a given feature in lemmy-ui (eg [notifications](https://github.com/LemmyNet/lemmy-ui/pulls?q=is%3Apr+notifications+is%3Aclosed+))

Note that this document only covers changes to existing features, not new features. If any breaking changes are missing, please make a pull request to [this file](https://github.com/LemmyNet/lemmy-docs/blob/main/src/contributors/09-api-v4.md). If you have any questions, use the [development chat on matrix](https://matrix.to/#/#lemmydev:matrix.org) or [/c/lemmy-support](https://lemmy.ml/c/lemmy_support).

## Rename account endpoints

Various endpoints have been renamed, especially those under `/api/v3/user` have been moved to `/api/v4/account/auth`.

- `/api/v3/user/register` to `/api/v4/account/auth/register`
- `/api/v3/user/login` to `/api/v4/account/auth/login`
- `/api/v3/user/logout` to `/api/v4/account/auth/logout`
- ...
- `/api/v4/site` doesn't have `my_user` anymore, this is now available at [`GET /api/v4/account`](https://join-lemmy.org/api/main#operation/GetMyUser)

https://github.com/LemmyNet/lemmy/pull/5216

## Combined endpoints

There are various places in the UI where different types of data are shown together, for example posts and comments in the user profile. Until `0.19` these were queried separately, to display the (last 20 posts) and (last 20 comments). For `1.0` Dessalines implemented combined queries, so that the new endpoint `/api/v4/person/content` returns the last 20 (posts and comments). See the [issue](https://github.com/LemmyNet/lemmy/issues/2444) and linked pull requests for more details.

The combined endpoints are:

- [`GET /api/v4/person/content`](https://join-lemmy.org/api/main#operation/ListPersonContent)
- [`GET /api/v4/account/inbox`](https://join-lemmy.org/api/main#operation/ListInbox)
- [`GET /api/v4/account/saved`](https://join-lemmy.org/api/main#operation/ListPersonSaved)
- [`GET /api/v4/modlog`](https://join-lemmy.org/api/main#operation/GetModlog)
- [`GET /api/v4/report/list`](https://join-lemmy.org/api/main#operation/ListReports)

## Image endpoints

Uploading or deleting avatars, icons and banners is done through separate endpoints now. With this change it is possible to disable image uploads, while still allowing changes to avatars etc.

- [POST `/api/v4/account/avatar`](https://join-lemmy.org/api/main#operation/UploadUserAvatar)
- [DELETE `/api/v4/account/avatar`](https://join-lemmy.org/api/main#operation/DeleteUserAvatar)
- [POST `/api/v4/community/banner`](https://join-lemmy.org/api/main#operation/UploadCommunityBanner)
- ...

The endpoints for image upload and proxying have been moved to `GET /api/v4/image/{filename}` and `GET /api/v4/image/proxy` respectively.

https://github.com/LemmyNet/lemmy/pull/5260

## Cursor Pagination

Instead of a `page` parameter, API v4 uses cursors for pagination. To make it simple, a cursor is a string which encodes the id of the last item on the current page. When going to the next page, the client sends the `next_page` cursor as `page_cursor,` and the API sends back items which come after this one. This way users don't lose their place in the feed, but continue exactly where they left off.

## Notifications Rewrite

With API v3 notification functionality was spread across various different endpoints. Now all is available under a single endpoint [/api/v4/account/notification/list](https://join-lemmy.org/api/main#tag/Account/operation/ListNotifications). Notifications also include modlog entries affecting the current user.

## Post Time Range Filter

The previous sorts `TopHour`, `TopDay` etc are gone and replaced `Top` sort. Instead there is now a separate parameter `time_range_seconds` which accepts arbitrary time values and works with all sort types.

## Other Breaking Changes

- [Rename actor_id columns to ap_id](https://github.com/LemmyNet/lemmy/pull/5393)
- [Removing local_user.show_scores column, since its now on the local_user_vote_display_mode table.](https://github.com/LemmyNet/lemmy/pull/4497)
- [Move custom emojis and tagline views to separate endpoints](https://github.com/LemmyNet/lemmy/pull/4580)
- [Remove pointless block_views](https://github.com/LemmyNet/lemmy/pull/4841)
- [Changing list_logins to return a ListLoginsResponse object.](https://github.com/LemmyNet/lemmy/pull/4888)
- [Remove pointless local_user_id from LocalUserVoteDisplayMode](https://github.com/LemmyNet/lemmy/pull/4890)
- [Remove enable nsfw](https://github.com/LemmyNet/lemmy/pull/5017)
