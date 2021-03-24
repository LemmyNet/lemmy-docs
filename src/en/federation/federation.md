# Federation
https://lemmy.ml/u/20776
Lemmy uses the ActivityPub protocol (a W3C standard) to enable federation between different servers (often called instances). This is very similar to the way email works. For example, if you use gmail.com, then you can not only send mails to other gmail.com users, but also to yahoo.com, yandex.ru and so on. Email uses the SMTP protocol to achieve this, so you can think of ActivityPub as "SMTP for social media". The amount of different actions possible on social media (post, comment, like, share, etc) means that ActivityPub is much more complicated than SMTP.

As with email, ActivityPub federation happens only between servers. So if you are registered on `enterprise.lemmy.ml`, you only connect to the API of `enterprise.lemmy.ml`, while the server takes care of sending and receiving data from other instances (eg `voyager.lemmy.ml`). The great advantage of this approach is that the average user doesn't have to do anything to use federation. In fact if you are using Lemmy, you are likely already using it. One way to confirm is by going to a community or user profile. If you are on `enterprise.lemmy.ml` and you see a user like `@nutomic@voyager.lemmy.ml`, or a community like `!main@ds9.lemmy.ml`, then those are federated, meaning they use a different instance from yours.

One way you can take advantage of federation is by opening a different instance, like `ds9.lemmy.ml`, and browsing it. If you see an interesting community, post or user that you want to interact with, just copy its URL and paste it into the search of your own instance. Your instance will connect to the other one (assuming the allowlist/blocklist allows it), and directly display the remote content to you, so that you can follow a community or comment on a post. Here are some examples of working searches:

- `!main@lemmy.ml` (Community)
- `@nutomic@lemmy.ml` (User)
- `https://lemmy.ml/c/programming` (Community)
- `https://lemmy.ml/u/nutomic` (User)
- `https://lemmy.ml/post/123` (Post)
- `https://lemmy.ml/comment/321` (Comment)

You can see the list of linked instances by following the "Instances" link at the bottom of any Lemmy page.

## Searching for communities

If you search for a community first time, 20 posts are fetched initially. Only if a least one user on your instance subscibes this community on the other host, this host will deliver updates to your instance.
Updates mean: 
- new posts
- new comments
- votings
- edited comments and posts

You can copy the URL of the community from the address-bar in your browser and insert it in your search-field. Wait a few seconds, the post will appear below. There is no indicator for a running search now!

## Searching for posts

Copy the URL of a post in your lemmy's search-field. Wait a few seconds until the post will appear. Klick on it, you'll be lead to the posting into the community, where you cann see the "Follow"-button and follow the community. Be aware, not all postings are fetched from the community, only a few ammount, and no comments!

## Searching for comments

If you find an interesting comment under a posting on another instance, you can find below the comment in the 3-dot-menu the link-symbol. Copy this link, oder klick on the link-button and copy the url from your address-bar in the browser. The link looks like `https://lemmy.ml/post/56382/comment/40796`. Remove the `post/XXX` part from this link and put it into your search-bar. For this example, search for `https://lemmy.ml/comment/40796`. 
This comment, all parent comments, users and community and the responding posting is fetched from the remote instance, if they are not known locally.
No siblings are fetched!!

If you wand more comments from older postings, you have to search for them the same way as described just above.

## Drawbacks

There is no possibility to fetch easily old postings or comments from a remote instance from your instance, if you have joined a community. 
