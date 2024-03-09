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

### Building

Use these commands to create a custom container based on your local branch and tagged accordingly.

This is useful if you want to modify the source code of your instance to add some extra functionalities which are not available in the main release.

```bash
sudo docker build . -f docker/Dockerfile --build-arg RUST_RELEASE_MODE=release -t "lemmy:${git rev-parse --abbrev-ref HEAD}"
```

#### Build Troubleshooting

In case the build fails, the following might help resolve it

##### Translations missing

If you see an error like this

```
Error: FileRead { file: "translations/email/en.json", source: Os { code: 2, kind: NotFound, message: "No such file or directory" } }
```

Try these commands

```bash
git submodule init && git submodule update
```

Then try building again

### Running custom build on your server

If you want a custom docker build to run on your instance via docker, you don't need to upload to a container repository, you can upload directly from your PC through ssh.

The following commands will copy the file to your instance and then load it onto your server's container registry

```bash
LEMMY_SRV=lemmy.example.com # Add the FQDN, IP or hostname of your lemmy server here
# We store in /tmp to avoid putting it in our local branch and commiting it by mistake
sudo docker save -o /tmp/customlemmy.tar lemmy:${git rev-parse --abbrev-ref HEAD}
# We change permissios to allow our normal user to read the file as root might not have ssh keys
sudo chown ${whoami} /tmp/${git rev-parse --abbrev-ref HEAD}
scp /tmp/customlemmy.tar ${LEMMY_SRV}:
ssh ${LEMMY_SRV}
# This command should be run while in your lemmy server as the user you uploaded
sudo docker load -i ${HOME}/customlemmy.tar
```

After the container is in your registry, simply change the docker-compose to have your own tag in the `image` key

```
image: lemmy:your_branch_name
```

Finally, reinitiate the container

```
docker-compose up -d
```

You should now be running your custom docker container.

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

You can log into each using the instance name, and `lemmylemmy` as the password, IE (`lemmy_alpha`, `lemmylemmy`).

To start federation between instances, visit one of them and search for a user, community or post, like this. Note that
the Lemmy backend runs on a different port than the frontend, so you have to increment the port number from
the URL bar by one.

- `http://lemmy-gamma:8561/u/lemmy-gamma`
- `http://lemmy-alpha:8541/c/main`
- `http://lemmy-beta:8551/post/3`
