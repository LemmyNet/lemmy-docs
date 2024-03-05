## Moderation

The internet is full of bots, trolls and other malicious actors. Sooner or later they will post unwanted content to any website that is open to the public. It is the task of administrators and moderators to remove such unwanted content. Lemmy provides many tools for this, from removing individual posts, over temporary bans, to removing all content from an offending user.

Moderation in Lemmy is divided between administrators and moderators. Admins are responsible for the entire instance, and can take action on any content. They are also the only ones who can completely ban users. In contrast, moderators are only responsible for a single community. Where admins can ban a user from the entire instance, mods can only ban them from their community.

The most important thing that normal users can do if they notice a rule breaking post is to use the report function. If you notice such a post, click the flag icon to notify mods and admins. This way they can take action quickly and remove the offending content. To find out about removals and other mod actions, you can use the mod log which is linked at the bottom of the page. In some cases there may be content that you personally dislike, but which doesn't violate any rules. For this exists a block function which hides all posts from a given user or community.

Each instance has a set of rules to let users know which content is allowed or not. These rules can be found in the sidebar and apply to all local communities on that instance. Some communities may have their own rules in the respective sidebar, which apply in addition to the instance rules.

Because Lemmy is decentralized, there is no single moderation team for the platform, nor any platform-wide rules. Instead each instance is responsible to create and enforce its own moderation policy. This means that two Lemmy instances can have rules that completely disagree or even contradict. This can lead to problems if they interact with each other, because by default federation is open to any instance that speaks the same protocol. To handle such cases, administrators can choose to block federation with specific instances. To be even safer, they can also choose to be federated only with instances that are allowed explicitly.

### How to moderate

To get moderator powers, you either need to create a new community, or be appointed by an existing moderator. Similarly to become an admin, you need to create a new instance, or be appointed by an existing instance admin. Community moderation can be done over federation, you don't need to be registered on the same instance where the community is hosted. To be an instance administrator, you need an account on that specific instance. Admins and moderators are organized in a hierarchy, where the user who is listed first has the power to remove admins or mods who are listed later.

All moderation actions are taken on the context menu of posts or comments. Click the three dot button to expand available mod actions, as shown in the screenshot below. All actions can be reverted in the same way.

![moderation_01.png](moderation_01.png)
![moderation_02.png](moderation_02.png)

| Action             | Result                                                                                                                                      | Permission level |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| Lock               | Prevents making new comments under the post                                                                                                 | Moderator        |
| Sticky (Community) | Pin the publication to the top of the community listing                                                                                     | Moderator        |
| Sticky (Local)     | Pin the publication to the top of the frontpage                                                                                             | Admin            |
| Remove             | Delete the post                                                                                                                             | Moderator        |
| Ban from community | Ban user from interacting with the community, but can still use the rest of the site. There is also an option to remove all existing posts. | Moderator        |
| Appoint as mod     | Gives the user moderator status                                                                                                             | Moderator        |
| Ban from site      | Completely bans the account, so it can't login or interact at all. There is also an option to remove all existing posts.                    | Admin            |
| Purge user         | Completely delete the user, including all posts and uploaded media. Use with caution.                                                       | Admin            |
| Purge post/comment | Completely delete the post, including attached media.                                                                                       | Admin            |
| Appoint as admin   | Gives the user administrator status                                                                                                         | Admin            |

### Image Moderation

> Attribution: This documentation was originally posted by Michael Altfield [here](https://tech.michaelaltfield.net/2024/03/04/lemmy-fediverse-gdpr/)

Currently there is no WUI for deleting images in Lemmy. And deleting accounts does not delete the accounts' images. For more information, please see:

-   [lemmy #4433: Deleted Account should delete uploaded media
    (pictures) too](https://github.com/LemmyNet/lemmy/issues/4433)
-   [lemmy #4441: Users unable to delete their images (pictrs
    API)](https://github.com/LemmyNet/lemmy/issues/4441)
-   [lemmy #4445: Create an interface for local users to view and remove
    images](https://github.com/LemmyNet/lemmy/issues/4445)
-   [lemmy-ui #2359: Allow users to delete images they
    uploaded](https://github.com/LemmyNet/lemmy-ui/issues/2359)
-   [lemmy-ui #2360: Allow admins to view & delete uploaded
    images](https://github.com/LemmyNet/lemmy-ui/issues/2360)

#### How to purge images in Lemmy

[pict-rs](https://git.asonix.dog/asonix/pict-rs/) is a third-party
simple image hosting service that runs along-side Lemmy for instances
that allow users to upload media.

At the time of writing, [there is no WUI for admins to find and delete
images](https://github.com/LemmyNet/lemmy-ui/issues/2360). You have to
manually query the pict-rs database and execute an API call from the
command-line.

For the purposes of this example, let\'s assume you\'re trying to delete
the following image

```
https://monero.town/pictrs/image/001665df-3b25-415f-8a59-3d836bb68dd1.webp
```

There are two [API endpoints in
pict-rs](https://git.asonix.dog/asonix/pict-rs/) that can be used to
delete an image

##### Method One: /image/delete/{delete_token}/{alias}

This API call is publicly-accessible, but it first requires you to
obtain the image\'s \``delete_token`\`

The \``delete_token`\` is first returned by Lemmy when POSTing to the
\``/pictrs/image`\` endpoint

```
{
   "msg":"ok",
   "files":[
      {
         "file":"001665df-3b25-415f-8a59-3d836bb68dd1.webp",
         "delete_token":"d88b7f32-a56f-4679-bd93-4f334764d381"
      }
   ]
}
```

Two pieces of information are returned here:

1.  **file** (aka the \"alias\") is the *server* filename of the
    uploaded image
2.  **delete_token** is the token needed to delete the image

Of course, if you didn\'t capture this image\'s \``delete_token`\` at
upload-time, then you must fetch it from the postgres DB.

First, open a shell on your running postgres container. If you installed
Lemmy with docker compose, use \``docker compose ps`\` to get the
\"SERVICE\" name of your postgres host, and then enter it with
\``docker exec`\`

```
docker compose ps --format "table {{.Service}}\t{{.Image}}\t{{.Name}}"
docker compose exec <docker_service_name> /bin/bash
```

For example:

```
user@host:/home/user/lemmy# docker compose ps --format "table {{.Service}}\t{{.Image}}\t{{.Name}}"
SERVICE    IMAGE                            NAME
lemmy      dessalines/lemmy:0.19.3          lemmy-lemmy-1
lemmy-ui   dessalines/lemmy-ui:0.19.3       lemmy-lemmy-ui-1
pictrs     docker.io/asonix/pictrs:0.5.4    lemmy-pictrs-1
postfix    docker.io/mwader/postfix-relay   lemmy-postfix-1
postgres   docker.io/postgres:15-alpine     lemmy-postgres-1
proxy      docker.io/library/nginx          lemmy-proxy-1
user@host:/home/user/lemmy# 

user@host:/home/user/lemmy# docker compose exec postgres /bin/bash
postgres:/# 
```

Connect to the database as the \``lemmy`\` user

```
psql -U lemmy
```

For example

```
postgres:/# psql -U lemmy
psql (15.5)
Type "help" for help.

lemmy=# 
```

Query for the image by the \"alias\" (the filename)

```
select * from image_upload where pictrs_alias = '<image_filename>';
```

For example

```
lemmy=# select * from image_upload where pictrs_alias = '001665df-3b25-415f-8a59-3d836bb68dd1.webp';
 local_user_id | pictrs_alias | pictrs_delete_token | published 
---------------+--------------+---------------------+-----------
1149 | 001665df-3b25-415f-8a59-3d836bb68dd1.webp | d88b7f32-a56f-4679-bd93-4f334764d381 | 2024-02-07 11:10:17.158741+00
(1 row)

lemmy=# 
```

Now, take the \``pictrs_delete_token`\` from the above output, and use
it to delete the image.

The following command should be able to be run on any computer connected
to the internet.

```
curl -i "https://<instance_domain>/pictrs/image/delete/<pictrs_delete_token>/<image_filename>"
```

For example:

```
user@disp9140:~$ curl -i "https://monero.town/pictrs/image/delete/d88b7f32-a56f-4679-bd93-4f334764d381/001665df-3b25-415f-8a59-3d836bb68dd1.webp"

HTTP/2 204 No Content
server: nginx
date: Fri, 09 Feb 2024 15:37:48 GMT
vary: Origin, Access-Control-Request-Method, Access-Control-Request-Headers
cache-control: private
referrer-policy: same-origin
x-content-type-options: nosniff
x-frame-options: DENY
x-xss-protection: 1; mode=block
X-Firefox-Spdy: h2
user@disp9140:~$ 
```

> ⓘ Note: If you get an \``incorrect_login`\` error, then try \[a\]
logging into the instance in your web browser and then \[b\] pasting the
\"`https://<instance_domain>/pictrs/image/delete/<pictrs_delete_token>/<image_filename>`\"
URL into your web browser.

The image should be deleted.

##### Method Two: /internal/purge?alias={alias}

Alternatively, you could execute the deletion directly inside the pictrs
container. This eliminates the need to fetch the \``delete_token`\`.

First, open a shell on your running \``pictrs`\` container. If you
installed Lemmy with docker compose, use \``docker compose ps`\` to get
the \"SERVICE\" name of your postgres host, and then enter it with
\``docker exec`\`

```
docker compose ps --format "table {{.Service}}\t{{.Image}}\t{{.Name}}"
docker compose exec <docker_service_name> /bin/sh
```

For example:

```
user@host:/home/user/lemmy# docker compose ps --format "table {{.Service}}\t{{.Image}}\t{{.Name}}"
SERVICE    IMAGE                            NAME
lemmy      dessalines/lemmy:0.19.3          lemmy-lemmy-1
lemmy-ui   dessalines/lemmy-ui:0.19.3       lemmy-lemmy-ui-1
pictrs     docker.io/asonix/pictrs:0.5.4    lemmy-pictrs-1
postfix    docker.io/mwader/postfix-relay   lemmy-postfix-1
postgres   docker.io/postgres:15-alpine     lemmy-postgres-1
proxy      docker.io/library/nginx          lemmy-proxy-1
user@host:/home/user/lemmy# 

user@host:/home/user/lemmy# docker compose exec pictrs /bin/sh
~ $ 
```

Execute the following command inside the \``pictrs`\` container.

```
wget --server-response --post-data "" --header "X-Api-Token: ${PICTRS__SERVER__API_KEY}" "http://127.0.0.1:8080/internal/purge?alias=<image_filename>"
```

For example:

```
~ $ wget --server-response --post-data "" --header "X-Api-Token: ${PICTRS__SERVER__API_KEY}" "http://127.0.0.1:8080/internal/purge?alias=001665df-3b25-415f-8a59-3d836bb68dd1.webp"
Connecting to 127.0.0.1:8080 (127.0.0.1:8080)
HTTP/1.1 200 OK
content-length: 67
connection: close
content-type: application/json
date: Wed, 14 Feb 2024 12:56:24 GMT

saving to 'purge?alias=001665df-3b25-415f-8a59-3d836bb68dd1.webp'
purge?alias=001665df 100% |*****************************************************************************************************************************************************************************************************************************| 67 0:00:00 ETA
'purge?alias=001665df-3b25-415f-8a59-3d836bb68dd1.webp' saved

~ $ 
```

> ⓘ Note: There\'s an error in the pict-rs reference documentation. It
says you can POST to \`/internal/delete\`, but that just returns
`404 Not Found`.

The image should be deleted
