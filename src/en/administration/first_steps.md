# Administration First Steps

After you successfully installed Lemmy either [manually with Docker](administration/install_docker.html) or [automatically with Ansible](administration/install_ansible.html) here are some recommendations for a new administrator of a Lemmy server.

## Admin Settings

The first thing to do is to go to your admin panel, which can be found by clicking on the cog at the top right next to the search icon. Here you define a description for your site, so that people know if it is about one specific topic or if all subjects are welcome. You can also add an icon and a banner that define your server, it can for example be the logo of your organization.

Take the time to browse through the entire page to discover the different options you have to customize your Lemmy instance, on the same page you can edit your [configuration file](administration/configuration.html), where you can find information about your database, the email used by the server, the federation options or the main administrator.

It is always good to define another administrator than yourself, for if it is necessary to take actions while you make your best nap. Take a look at the [moderation guide](moderation/moderation.html) for more information on how to do this.

## Check that everything is working properly

### Federation

To test that your instance federation is working correctly execute `curl -H 'Accept: application/activity+json' https://your-instance.com/u/your-username`, it should return a .json file, and not an .html one.

## Inclusion on join-lemmy.org instance list

To be included in the list of Lemmy instances on [join-lemmy.org](https://join-lemmy.org/instances) you must meet the following requirements:
- [x] Federate with at least one instance from the list
- [x] Have a site description and icon
- [x] Be patient and wait the site to be updated, there's no fixed schedule for that

In the meantime you can always promote your server on other social networks like Mastodon using the hashtag `#Lemmy`.

## Keeping up to date

You can subscribe to the Github RSS feeds to be informed of the latest releases:
- [lemmy](https://github.com/LemmyNet/lemmy/releases.atom)
- [lemmy-ui](https://github.com/LemmyNet/lemmy-ui/releases.atom)
- [lemmy-js-client](https://github.com/LemmyNet/lemmy-js-client/releases.atom)
- [joinlemmy-site](https://github.com/LemmyNet/joinlemmy-site/releases.atom)

There is also a [Matrix chat](https://matrix.to/#/!OwmdVYiZSXrXbtCNLw:matrix.org) for instance administrators that you can join. You'll find some really friendly people there who will help you (or at least try to) if you run into any issue.
