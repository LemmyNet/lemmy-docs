# Theming Guide

## Bootstrap

Lemmy uses [Bootstrap v5](https://getbootstrap.com/), and very few custom css classes, so any bootstrap v5 compatible theme should work fine. Use a tool like [bootstrap.build](https://bootstrap.build/) to create a bootstrap v5 theme. Export the `bootstrap.min.css` once you're done, and save the `_variables.scss` too.

## Custom Theme Directory

If you installed Lemmy with Docker, save your theme file to `./volumes/lemmy-ui/extra_themes`. For native installation (without Docker), themes are loaded by lemmy-ui from ./extra_themes folder. A different path can be specified with LEMMY_UI_EXTRA_THEMES_FOLDER environment variable.

After a theme is added, users can select it under `/settings`. Admins can set a theme as site default under `/admin`.

## Default Theme Locations

Default Lemmy themes are located in `/lemmy-ui/src/assets/css/themes`. Atom themes used for styling `<code>` are in `/lemmy-ui/src/assets/css/code-themes`. Custom css classes and changes to the default Bootstrap styles are in `/lemmy-ui/src/assets/css/main.css`.

## Making CSS Themes with Sass and Bootstrap

Some tips if making a theme based off the default Lemmy themes. 

Every theme has these files: 

- an output `theme.css`
- an output `theme.css.map`
- `theme.scss`
- `_variables.theme.scss`

All `_variables.theme.scss` files will inherit variables from `_variables.scss`.
All `theme.scss` will import bootstrap variables from `"../../../../node_modules/bootstrap/scss/bootstrap";` and its `_variables.theme.scss` file. It may import additional variables from another theme if it is built off it. For example, `litely-compact.scss` imports from `_variables.litely.scss`.

### Using SCSS Files

If you are new to Sass, keep in mind that `theme.scss` files are for css and Sass flavored css. `_variables.theme.scss` are for variables. 

#### Export Your CSS File 

To export your custom `.scss` and `_variables.theme.scss` files to a `.css` file open the command line in the same directory as your files and run:
`sass theme.scss theme.css` which will generate the `.css` and `.css.map` files.

### Bootstrap Notes

If you are new to Bootstrap, be aware that variables starting with a dollar sign like `$variable` are Bootstrap variables and when output to css will look like `--bs-variable`. You can also define custom root variables in your `_variables.theme.scss` files like `:root {--custom-variable: value;};` and you can refer to this again in your `theme.scss` file.

#### Bootstrap Variables on Lemmy

The Darkly and Litely themes use default Bootstrap variables to define the grayscales and colours. Inspecting the Bootstrap documentation for how colours are applied to elements is recommended, along with inspecting the CSS and output files.

##### Light and Dark Modes

Even though `darkly.css` is a dark theme, it has in-built light and dark modes using media queries. The Bootstrap variables `$enable-dark-mode` and `$enable-light-mode` can be used to toggle this behaviour on or off.

##### Overwriting Variables

Most Lemmy theming is done with Bootstrap's default variables. Some variables are defined with `!important` which means if you have defined them in your custom theme that unless it also has `!important` it will be overwritten. To check, do a search in one of the default theme files or use the Developer Tools in your browser.

To quickly test your theme if you do not own a Lemmy instance, you can use a browser add on to load your custom CSS file.

##### External Stylesheets

As users cannot currently upload their own themes in Settings (only Admin can do that), custom themes loaded with an external style sheet will need to take into account that users will have a pre-selected theme in Settings that may have conflicting styles with the custom theme. If a theme is developed from an existing theme, having the default theme selected in Settings can minimize style conflicts. 

## How CSS Themes are Added to Settings

In short, given the css theme is the correct file format and in the correct theme directory, it will be appended to the bottom of the theme list in Settings. The name is the filename minus the file extension. Details are below.

### CSS Format Check

The Typescript file `theme-handler.ts` in `/lemmy-ui/src/server/handlers/` will check for existing `css` files from the custom theme folder (`./volumes/lemmy-ui/extra_themes` or `./extra_themes`). Non `css` files will trigger an error.

### Building the Theme List

If a custom css theme is found, the handler will call `themes-list-handler.ts` which will load `build-themes-list.ts` from `/lemmy-ui/src/server/utils/`. The file `buid-themes-list.ts` will search the directories for files ending in `.css` and build a list. 

Custom themes are appended to the bottom of the theme list. 

### Theme Names

`build-themes-list.ts` will remove the file extension `.css` from the theme filename to display in Settings. For example, `darkly-compact.css` will appear as `darkly-compact`.

## Build and Format Theme Files Quickly

Some tips to save time which would be useful for theme developers or if you are submitting pull requests to [lemmy-ui (Github)](https://github.com/LemmyNet/lemmy-ui).

After changing variables or Sass files:

- run `pnpm themes:build` to automatically rebuild all Lemmy css theme files using Sass
- run `npx prettier -w /lemmy-ui/src/assets/css/themes` to reformat the code in the themes directory with prettier
