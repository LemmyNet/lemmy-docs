# Lemmy Documentation

Documentation for the Lemmy project

## Building

You need to have [Cargo](https://doc.rust-lang.org/cargo/) installed.

Our documentation tool [mdbook](https://github.com/rust-lang/mdBook) doesn't support localisation yet, so we are using code that is still work on progress to create our documentation with localisation. Note that this code still has some rough edges. See [github.com/rust-lang/mdBook/pull/1306](https://github.com/rust-lang/mdBook/pull/1306) for more details.

```bash
cargo install mdbook --git https://github.com/Ruin0x11/mdBook.git \
    --branch localization --rev d06249b
# generate static page in `book` subfolder
mdbook build
# serve the book at `http://localhost:3000`, and rebuilds on changes
mdbook serve
```

## Adding a new Language

- Edit `book.toml` to add the metadata for your language
- Copy `src/en/SUMMARY.md` to `src/xx/SUMMARY.md` (where xx is your language's identifier)
- In `src/xx/`, write your translation into files and folders with the same name as in `src/en/`
- Use the instructions above to ensure that it builds without errors

## Guidelines for adding a new Translation

- After following the instructions above for adding a new language, open a pull request in the repository.
- We don't expect that you translate the entire documentation as fast as possible, its more important that you consistently work to improve the translation (even if its only a few hours a week or less).
- The goal is not to make a sentence-for-sentence translation of the English docs, but writing something that addresses the needs of users in your language. For example, if docker-compose docs are lacking in a language, that should be explained more extensively in lemmy docs for that language
- This is technical documentation, so try to avoid mentioning things that are unrelated to Lemmy itself, and avoid mentioning specific Lemmy instances.
- Avoid adding files which don't exist in English or other languages, as that would lead to problems when switching between languages.
- We will merge a new language after it has been worked on regularly for at least a month, and at least some pages are finished.
- After merging, we will add a label for the language, to help organising issues and pull requests by language.
- The translator will also get maintainer rights in this repository, to allow managing contributions for their language.
