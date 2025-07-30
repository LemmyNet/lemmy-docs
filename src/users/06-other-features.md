# Other Features

## Theming

Users can choose between a number of built-in color themes. Admins can also provide additional themes and set them as default.

## Easy to Install, Low Hardware Requirements

Lemmy is written in Rust, which is an extremely fast language. This is why it has very low hardware requirements. It can easily run on a Raspberry Pi or similar low-powered hardware. This makes it easy to administrate and keeps costs low.

## Backup of User Settings

Users can create a backup of their account data on the `/settings` page and store it locally. This can help in case the Lemmy instance goes down or the account gets banned. The backup includes settings like display name, bio, sort options as well as followed communities, saved posts, blocked communities and more. After registering on a new Lemmy instance, the backup file can be imported in the same place to restore the data. Restoring overwrites all the existing settings like bio and sort options. Follows and blocks on the other hand are additive, existing follows or blocks are kept unchanged. It is save to edit the backup file with a text editor to remove specific lines and avoid importing them (just be sure it is valid json before uploading).

## Language Tags

Lemmy instances and communities can specify which languages can be used for posting. Consider an instance aimed at Spanish users, it would limit the posting language to Spanish so that other languages can't be used. Or an international instance which only allows languages that the admin team understands. Community languages work in the same way, and are restricted to a subset of the instance languages. By default, all languages are allowed (including _undefined_).

Users can also specify which languages they speak, and will only see content in those languages. Lemmy tries to smartly select a default language for new posts if possible. Otherwise you have to specify the language manually.

## Lemmy as a Blog

Lemmy can also function as a blogging platform. Doing this is as simple as creating a community and enabling the option "Only moderators can post to this community". Now only you and other people that you invite can create posts, while everyone else can comment. Like any Lemmy community, it is also possible to follow from other Fediverse platforms and over RSS. For advanced usage, it is even possible to use the API and create a different frontend which looks more blog-like.
