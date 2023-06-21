## Docker Development

### Dependencies

Debian-based distro:

```bash
sudo apt install git docker-compose
sudo systemctl start docker
git clone https://github.com/LemmyNet/lemmy --recursive
```

Arch-based distro:

```bash
sudo pacman -S git docker-compose
sudo systemctl start docker
```

Get the code with submodules:

```bash
git clone https://github.com/LemmyNet/lemmy --recursive
```

### Running

```bash
cd docker
./docker_update.sh
```

Then open [localhost:1236](http://localhost:1236) in your browser.

Building with Docker is relatively slow. To get faster builds you need to use [local development](02-local-development.md) instead.

## Federation Development

The federation setup allows starting a few local Lemmy instances, to test federation functionality. You can start it with the following commands:

```bash
cd docker/federation
./start-local-instances.bash
```

The federation test sets up 5 instances:

| Instance      | Admin username | Location                                | Notes                                   |
| ------------- | -------------- | --------------------------------------- | --------------------------------------- |
| lemmy-alpha   | lemmy_alpha    | [127.0.0.1:8540](http://127.0.0.1:8540) | federated with all other instances      |
| lemmy-beta    | lemmy_beta     | [127.0.0.1:8550](http://127.0.0.1:8550) | federated with all other instances      |
| lemmy-gamma   | lemmy_gamma    | [127.0.0.1:8560](http://127.0.0.1:8560) | federated with all other instances      |
| lemmy-delta   | lemmy_delta    | [127.0.0.1:8570](http://127.0.0.1:8570) | only allows federation with lemmy-beta  |
| lemmy-epsilon | lemmy_epsilon  | [127.0.0.1:8580](http://127.0.0.1:8580) | uses blocklist, has lemmy-alpha blocked |

You can log into each using the instance name, and `lemmy` as the password, IE (`lemmy_alpha`, `lemmy`).

To start federation between instances, visit one of them and search for a user, community or post, like this. Note that
the Lemmy backend runs on a different port than the frontend, so you have to increment the port number from
the URL bar by one.

- `http://lemmy-gamma:8561/u/lemmy-gamma`
- `http://lemmy-alpha:8541/c/main`
- `http://lemmy-beta:8551/post/3`
