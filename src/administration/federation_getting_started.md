# Getting started with Federation

## Quickstart

Federation is enabled by default, but initially you won't see any content from other Lemmy instances. To get started you can browse [other Lemmy instances](https://join-lemmy.org/instances) for interesting communities, or browse the community list on [lemmyverse.net](https://lemmyverse.net/communities). Once you find an interesting community, simply paste the URL into the search field on your own Lemmy instance, for example `https://lemmy.ml/c/announcements`. To have new content in the community pushed to your instance, you need to click the "Follow" button in the sidebar.

If you notice that community follows are still shown as "Subscription Pending" after a few hours, or your posts are not visible on other instances, you may have a configuration problem. Checkout the [troubleshoothing guide](troubleshooting.md), you can also ask for help in [!lemmy@lemmy.ml](https://lemmy.ml/c/lemmy) or the [admin chat on Matrix](https://matrix.to/#/#lemmy-support-general:discuss.online).

## Fetching Data

If you see something interesting while browsing another Lemmy instance, you can easily import it in order to interact with the content. This works for users, communities, posts and comments. For posts and comments you can get the correct URL from the colorful "Fedilink" icon. All of the following formats are valid to fetch data over federation:

- `https://lemmy.ml/c/programming` (Community)
- `https://lemmy.ml/u/nutomic` (User)
- `https://lemmy.ml/post/123` (Post)
- `https://lemmy.ml/comment/321` (Comment)
- `!main@lemmy.ml` (Community)
- `@nutomic@lemmy.ml` (User)

When fetching a community, the most recent posts are also fetched automatically (but not comments or votes). When fetching a post, the community and author are also fetched automatically. And for comments, all parent comments, the post, their respective authors and the community are fetched. Sibling comments are not fetched automatically. If you want more comments from older posts, you have to search for each of them as described above.

You can also fetch content from other Fediverse platforms such as [Piefed](https://join.piefed.social/) or [Mbin](https://joinmbin.org/). Other platforms may also work, but only if they use communities like Lemmy.

## Blocking or Allowing Instances

Lemmy has three types of federation:

- Allowlist: Explicitly list instances to connect to.
- BlockList: Explicitly list instances to not connect to. Federation is open to all other instances.
- Open: Federate with all potential instances.

You can add allowed and blocked instances, by adding a comma-delimited list in your instance admin panel. IE to only federate with these instances, add: `enterprise.lemmy.ml,lemmy.ml` to the allowed instances section.

Lemmy uses the ActivityPub protocol (a W3C standard) to enable federation between different servers (often called instances). This is very similar to the way email works. For example, if you use gmail.com, then you can not only send mails to other gmail.com users, but also to yahoo.com, yandex.ru and so on. Email uses the SMTP protocol to achieve this, so you can think of ActivityPub as "SMTP for social media". The amount of different actions possible on social media (post, comment, like, share, etc) means that ActivityPub is much more complicated than SMTP.

As with email, ActivityPub federation happens only between servers. So if you are registered on `enterprise.lemmy.ml`, you only connect to the API of `enterprise.lemmy.ml`, while the server takes care of sending and receiving data from other instances (eg `voyager.lemmy.ml`). The great advantage of this approach is that the average user doesn't have to do anything to use federation. In fact if you are using Lemmy, you are likely already using it. One way to confirm is by going to a community or user profile. If you are on `enterprise.lemmy.ml` and you see a user like `@nutomic@voyager.lemmy.ml`, or a community like `!main@ds9.lemmy.ml`, then those are federated, meaning they use a different instance from yours.
