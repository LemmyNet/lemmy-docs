# Fediverse interaction

As mentioned in the introduction, Lemmy users and non-Lemmy users from the fediverse can communicate between each other, too. The way Lemmy users' activity is handled by non-Lemmy instances depends on the software running on the latter. If you are interested in that, you should read the documentation of the software run by the non-Lemmy instance in question. Here, we only focus on how non-Lemmy users' activity is handled by Lemmy instances. There are only a few things to keep in mind:

- Many fediverse-compatible social media have no notion of "group". These display Lemmy communities as single users, e.g. `@meta@sopuli.xyz` rather than `!meta@sopuli.xyz`. Just open the community from your non-Lemmy instance to check the correct handle.
- Users of link aggregators like Lemmy tend not to use hashtags and mentions, so consider limiting yourself to the bare minimum when posting or commenting, even if the rules of the Lemmy community/instance in question do not mention it.

## Follow a Lemmy community

You can freely follow any Lemmy community from non-Lemmy software.

## Post in a Lemmy community

To post in a Lemmy community from a non-Lemmy fediverse account, simply create a post following these rules:

- If your non-Lemmy software does not feature a "title" field for posts, the first line (i.e., the content before the first newline character) should be the desired title for your Lemmy post. Only its first 100 characters will be shown, while the rest will be ignored.
- The post visibility must be "Public" or similar.
- You must mention the Lemmy community's full handle.
- Any other mentions should be placed after the one involving the target Lemmy community.
- Media should have alt text, as this is the same alt text that will be shown in Lemmy.

If your post follows these rules, it should be automatically reposted by the Lemmy community almost immediately. Unlike media, links cannot be attached, but you can simply insert them within the content of your post.

## Comment under a Lemmy post

Comments to a Lemmy post (or to one of its comments) will be visible on Lemmy.

## Troubleshooting

If your message does not appear in the community, you should:

- Wait a few minutes.
- Double-check the rules mentioned above.
- Ensure the Lemmy instance has not defederated from your non-Lemmy instance (or the other way around). For example, the Lemmy administrator might have disabled federation with all instances (except for a limited whitelist), or they could have blacklisted the non-Lemmy instance specifically. To check this, Lemmy offers an "Instances" button in its footer. The software run by the non-Lemmy instance probably offers a similar functionality.
