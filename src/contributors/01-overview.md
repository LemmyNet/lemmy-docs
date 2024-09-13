# Overview

Lemmy is an open source project and relies on community contributions to get better. Development happens mainly in the [Lemmy Github repositories](https://github.com/LemmyNet). Communication is done over [Matrix](https://matrix.to/#/#activitypub-community:codelutin.com).

These are the main repositories which are relevant for contributors:

- [lemmy](https://github.com/LemmyNet/lemmy): The backend which is the core of Lemmy. It implements SQL queries, provides the API and handles ActivityPub federation. Additionally it sends emails and provides RSS feeds. Written in Rust with actix-web and diesel. The issue tracker is also used for general enhancements which affect multiple repositories.
- [lemmy-ui](https://github.com/LemmyNet/lemmy-ui): The main frontend for Lemmy. It provides the user interface that you see when viewing a Lemmy instance. Written in Typescript and CSS with the Inferno framework.
- [lemmy-ansible](https://github.com/LemmyNet/lemmy-ansible): Automated installation method which is recommended for users without technical knowledge.
- [joinlemmy-site](https://github.com/LemmyNet/joinlemmy-site): Source code for the official project website [join-lemmy.org](https://join-lemmy.org/). Landing page for new users which includes general information and a list of instances.
- [lemmy-js-client](https://github.com/LemmyNet/lemmy-js-client): Client for the Lemmy API which is used by lemmy-ui. Can also be used by other projects to get started more easily.
- [activitypub-federation-rust](https://github.com/LemmyNet/activitypub-federation-rust): High-level framework for ActivityPub federation in Rust. Was originally part of the Lemmy code, but was extracted and made more generic so that other projects can use it too.

There are many different ways to contribute, depending on your skills and interests:

### Reporting issues

You may notice different problems or potential improvements when using Lemmy. You can report them in the relevant repository. Make sure to first search the issue tracker to avoid duplicates. When creating the issue, fill in the template and include as much relevant information as possible.

### Translating

Use [Weblate](https://weblate.join-lemmy.org/projects/lemmy/) to help translate Lemmy into different languages.

### Programming and Design

You can open a pull request to make changes to Lemmy. In case of bigger contributions it is recommended to discuss it in an issue first. See the next sections for instructions to compile and develop the projects.

### Donating

Besides contributing with your time, you can also consider [making a donation](https://join-lemmy.org/donate) to support the developers.
