# Painkiller 2004 Linux Game Server in Docker

[![1] ![2] ![3]](https://github.com/t3r6/pkserver-docker/pkgs/container/pkserver)

[1]: <https://ghcr-badge.egpl.dev/t3r6/pkserver/tags?color=%2344cc11&ignore=&n=3&label=image+tags&trim=>
[2]: <https://ghcr-badge.egpl.dev/t3r6/pkserver/latest_tag?color=%2344cc11&ignore=&label=version&trim=>
[3]: <https://ghcr-badge.egpl.dev/t3r6/pkserver/size?color=%2344cc11&tag=main&label=image+size&trim=>

 [![Release Package](
  <https://github.com/t3r6/pkserver-docker/actions/workflows/docker-image.yml/badge.svg>
  )](
  <https://github.com/t3r6/pkserver-docker/actions/workflows/docker-image.yml>
)

This repository is used to quickly start and manage a Painkiller game server. It contains a free official [Painkiller](https://en.wikipedia.org/wiki/Painkiller_(video_game)) 2004 Linux Server released by People Can Fly with [PK++](https://www.moddb.com/mods/pk) competitive mod and additional life improvements.

## Supported Architectures

* Linux AMD64
* Linux ARM64

## Additional improvements

1. `pkserver` now uses OpenSpy instead of the deprecated GameSpy.
2. You can now pass custom configs and lscripts to the `pkserver` binary via hacks.
3. Added popular custom maps

## Requirements

* [Docker](https://docs.docker.com/engine/install/)/[Podman](https://podman.io/docs/installation)
* Optional: [Docker Compose](https://docs.docker.com/compose/install/linux/)/[Podman Compose](https://github.com/containers/podman-compose) to run docker-compose.yml
* Optional: [QEMU](https://www.qemu.org/download/) for multi-platform builds

I recommend installing `podman` and `podman-compose` for a quick server run. If you are planning to manage a complex server setup with restart policies, install `docker` and the `docker compose` plugin instead.

All of the below commands are indicated for `podman` but you can run all of them with `docker` the same way.

> Pay attention that Docker cannot see Podman images and vice versa so better stick to one tool.

## Quick start

> `hostname -I` is the command to show the IP addresses for the host. Please make sure that this command works on your OS and that you don't have multiple IPs before running the below command. Otherwise, replace `$(hostname -I)` with the IP address.

1. Start a server with the name 'ffa' (this command will automatically pull the Docker image and start a container):

    ```
    podman run --rm --name ffa -itd --net=host docker.io/painkillergameclassic/pkserver:main +interface $(hostname -I)
    ```

2. Check that the container with the pkserver is running:

    ```
    podman container ls
    ```

3. Open and forward the default Painkiller `3455` port in your firewall if required.

4. Check if your game is advertised on [OpenSpy](http://beta.openspy.net/en/server-list/painkiller)

5. Open the Painkiller game client and join a server. 

    > You won't see your own server in the in-game browser if you run the server and the clinet on the same machine so join it via IP.

    ```
    /connect ip
    ```

6. Stop the container named 'ffa':

    ```
    podman container stop ffa
    ```

7. Remove the stopped container:

    ```
    podman container prune
    ```

## Building

1. Clone the repository

2. Optional: put custom maps inside the `pkserver/Data/` folder, modify `pkserver/Bin/config.ini`.

3. Run the following command:

    - 'dot' is an indication that you build the Docker image from the Dockerfile in this directory
    - `-t/--tag` is the name of your future local Docker image

    ```
    podman build . --no-cache -t pkserver:v1
    ```

4. Check that the image has been built:

    ```
    podman image ls
    ```

## Running a server after the build

I didn't find a way to make the `pkserver` binary work in a Virtual Machine via the Docker bridge network driver so I suggest running it via the host Docker network driver. `hostname -I` is the command to show the IP addresses for the host. Please make sure that this command works on your OS and that you don't have multiple IPs before running the below command. Otherwise, replace `$(hostname -I)` with the IP address.

> You don't need to use the `+interface` command if you have one network interface on your host or if you set `Cfg.NetworkInterface` directly in the `pkserver/Bin/config.ini` file before building a Docker image.

1. Start a server with the name 'ffa':

    ```
    podman run --rm --name ffa -itd --net=host pkserver:v1 +interface $(hostname -I)
    ```

2. Check that the container with the server is running:

    ```
    podman container ls
    ```

3. Stop the container named 'ffa':

    ```
    podman container stop ffa
    ```

### Run a server with a custom config

Docker containers are ephemeral. It means that when you restart a container, all the information will be lost and you start from scratch. Thus, you need to bind a file from the outside of the Docker container. The simplest way would be to use the [bind mounts](https://docs.docker.com/storage/bind-mounts/) Docker feature. As an alternative you can use Docker volumes but I found this method inconvenient for the Painkiller server management since you cannot insert data directly into a volume without copying it to a container.

1. Copy `./pkserver/Bin/config.ini` from this repository to your host, for example, to `${HOME}/my_pkserver/config.ini`.

2. Make sure the file has the right permissions:

    ```
    chmod 664 conffa.ini
    ```

3. Modify `${HOME}/my_pkserver/config.ini` to your needs. You can also rename this file to something like `conf11.ini`.

    > You can only give a custom name to config.ini with the exact 6 letter size because scripts in this image hacks the binary, for example, you can rename it to `conffa.ini`, `conctf.ini` but you cannot name it `myconfig.ini`.

4. Run the server with the following command:

    ```
    export PKS_CFG="conf11.ini"
    export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
    podman run --rm --name ffa -itd -e PKS_CFG --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --net=host pkserver:v1 +interface $(hostname -I)
    ```

### Run a server with custom lscripts

This repository has 2 custom packages: `./pkserver/Data/PKPlus12.pak` for PK++ 1.2 and `./pkserver/Data/PKPlus13.pak` for PK++ 1.3.

In order to run a specific version of the mod, pass the package name to the CLI via Docker variable.

```
podman run --rm --name ffa -itd -e PKS_LSCRIPTS='PKPlus13.pak' --net=host pkserver:v1 +interface $(hostname -I)
```

An example of using a custom config with custom LScripts:

```
export PKS_CFG="conf13.ini"
export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name ffa -itd -e PKS_CFG -e PKS_LSCRIPTS='PKPlus13.pak' --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --net=host pkserver:v1 +interface $(hostname -I)
```

You can also use packs with custom names; however, you'll need to bind them using bind mounts or add to `./pkserver/Data/` and rebuild the Docker image.

> You can only give a custom name to `LScripts.pak` with the exact 8 letter size because it's a hack, for example, you can rename it to `LScript3.pak` but you cannot name it `MyLScripts.pak`.

Make sure the file has the right permissions:

```
chmod 664 LScript3.pak
```

```
export PKS_LSCRIPTS="LScript3.pak"
export PKS_LSCRIPTS_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name ffa -itd -e PKS_LSCRIPTS --mount type=bind,source=${PKS_LSCRIPTS_SOURCE},target=/opt/pkserver/Data/${PKS_LSCRIPTS} --net=host pkserver:v1 +interface $(hostname -I)
```

### Run a server with custom maps

An example, including everything above. Let's say you put a custom map to `${HOME}/my_pkserver/DM_bam.pkm`:

Make sure the file has the right permissions:

```
chmod 664 DM_bam.pkm
```

```
export MAP1="DM_bam.pkm"
export MAP1_SOURCE="${HOME}/my_pkserver/DM_bam.pkm"
export PKS_CFG="conf13.ini"
export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name ffa -itd -e PKS_CFG -e PKS_LSCRIPTS='PKPlus13.pak' --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --mount type=bind,source=${MAP1},target=/opt/pkserver/Data/${MAP1} --net=host pkserver:v1 +interface $(hostname -I)
```

### Run multiple containers based on the same image

You can run multiple server instances based on the same image by giving them different names and passing different parameters and ports.

> To change the port, go to `config.ini` and modify the `Cfg.ServerPort` line.

Let's say I have 3 different config files with different ports on my host (FFA config, DUEL config, CTF config) and I'd like to bind them to 3 different containers based on the same image:

> All configs should have 664 permissions.

```
export PKS_CFG="conffa.ini"
export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name ffa -itd -e PKS_CFG --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --net=host pkserver:v1 +interface $(hostname -I)
```

```
export PKS_CFG="conctf.ini"
export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name ctf -itd -e PKS_CFG --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --net=host pkserver:v1 +interface $(hostname -I)
```

```
export PKS_CFG="coduel.ini"
export PKS_CFG_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
podman run --rm --name duel -itd -e PKS_CFG --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/${PKS_CFG} --net=host pkserver:v1 +interface $(hostname -I)
```

Check the containers are running:

```
podman container ls
```

Check if there are failed containers:

```
podman container ls -a
```

Stop and delete all containers:

```
podman stop $(podman ps -a -q)
podman rm $(podman ps -a -q)
```

## Managing server logs and stats

Since this guide does not imply that you use Docker volumes, to manage `pkserver` logs and stats you need to create a cron job that periodically copies LOG and TXT files from a container to your host.

`pkserver` keeps them in the `/opt/pkserver/Bin/` directory. In this example, we copy LOG and TXT files from the container named 'ffa' to the `HOME` directory on the host:

```
podman exec ffa bash -c 'tar -cf - /opt/pkserver/Bin/*.log /opt/pkserver/Bin/*.txt' | tar --strip-components 3 -C ${HOME} -xvf -
```

## Managing server resources

`pkserver` has memory leaks. It is advised to set RAM limits on a container (250 MB for Duels and not more than 512 MB for FFA):

```
podman run --rm --name ffa -itd --memory="400m" --net=host pkserver:v1 +interface $(hostname -I)
```

Check the container stats:

```
podman stats
```

Set the container restart policy:

> Restart policy option only works with `docker` by default. If you want to use restart policies with `podman`, you need to run `podman generate systemd --restart-policy container_id` or find another workaround.

```
docker run --name ffa -itd --memory="400m" --restart unless-stopped --net=host pkserver:v1 +interface $(hostname -I)
```

Additional info:

- [Start containers automatically](https://docs.docker.com/config/containers/start-containers-automatically/)
- [Runtime options with Memory, CPUs, and GPUs](https://docs.docker.com/config/containers/resource_constraints/)

## Docker Compose

Docker Compose is a fast and convenient way to declaratively configure multiple containers. You can run multiple servers with one command, no scripts are required. I will use `podman-compose` in my examples.

The `docker-compose.yml` is provided in this repository as a template.

> Pay attention to the `config.ini` files. The configuration should be different for each server. If you, for example, run several servers on the same port, other containers will crash.

> **Issue**: Docker Compose mounts files as folders.
**Solution**: indicate the path to the `config.ini` file with dot/slash `source: ./config.ini`.

Configure it for your needs and run with:

```
podman-compose up -d
```

Check the resources:

```
podman ps
```

Stop all containers:

```
podman-compose down
```

```
podman container prune
```

## Mini Dockerfile

You can skip using this image. This is merely a wrapper around the `pkserver` package. It is implied that you have the full [pkserver](https://www.moddb.com/games/painkiller/downloads/painkiller-linux-server-164-full-openspy) package on your host and use that container binding every folder to it.

1. Building:

    ```
    podman build -f mini.Dockerfile . --no-cache -t pkserver-mini:v1
    ```

2. Launching. Let's assume you installed `pkserver` to the `${HOME}"/pkserver/` directory:

    ```
    podman run --rm -it --name mini --mount type=bind,source="${HOME}"/pkserver/Bin,target=/opt/pkserver/Bin --mount type=bind,source="${HOME}"/pkserver/bin,target=/opt/pkserver/bin --mount type=bind,source="${HOME}"/pkserver/Data,target=/opt/pkserver/Data --mount type=bind,source="${HOME}"/pkserver/data,target=/opt/pkserver/data --net=host pkserver-mini:v1 +interface $(hostname -I)
    ```

## Debug a container

1. You can enter your container with:

    ```
    podman exec -it ${container_name} bash
    ```

2. Enter a failed container by changing Docker entrypoint:

    ```
    podman run -it --entrypoint=bash ${container_name}
    ```

3. To copy inside/outside containers use [docker cp](https://docs.docker.com/reference/cli/docker/container/cp/).

4. Clean your system from Docker packages:

    ```
    podman system prune -a
    ```
