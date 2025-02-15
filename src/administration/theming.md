# Theming Guide

Lemmy uses [Bootstrap v5](https://getbootstrap.com/), and very few custom css classes, so any bootstrap v5 compatible theme should work fine. Use a tool like [bootstrap.build](https://bootstrap.build/) to create a bootstrap v5 theme. Export the `bootstrap.min.css` once you're done, and save the `_variables.scss` too.

If you installed Lemmy with Docker, save your theme file to `./volumes/lemmy-ui/extra_themes`. For native installation (without Docker), themes are loaded by lemmy-ui from ./extra_themes folder. A different path can be specified with LEMMY_UI_EXTRA_THEMES_FOLDER environment variable.

After a theme is added, users can select it under `/settings`. Admins can set a theme as site default under `/admin`.
