# Branching and Releases

## Branches

In general, our handling of branches is the one described in [A stable mainline branching model for Git](https://www.bitsnbites.eu/a-stable-mainline-branching-model-for-git/). One difference is that we avoid rebase, and instead merge the base branch into the current working branch. This helps to avoid force pushes and conflicts.

## Releases

- For major release: make a new branch `release/v0.x`
- For minor release: cherry-pick desired changes onto `release/v0.x` branch
- Make a beta or release candidate version with `docker/prod/deploy.sh`
- Do the same for `lemmy-ui`: `./deploy.sh 0.x.0-rc-x`
- Deploy to federation test instances
    -  Keeping one instance at the last stable version to test federation compatibility (automate this with ansible)
    -  `ansible-playbook -i federation playbooks/site.yml --vault-password-file vault_pass -e rc_version=0.x.0-rc.x`
- Test that everything works as expected, make new beta/rc releases if needed
- Deploy to lemmy.ml, to discover remaining problems
- If that went well, make the official `0.x.0` release with `docker/prod/deploy.sh`
- Announce the release on Lemmy, Matrix, Mastodon
