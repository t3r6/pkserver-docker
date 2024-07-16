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
3. All the server config parameters can be passed as environment variables.
4. Added popular custom maps

## Requirements

* [Docker Engine with Docker Compose](https://docs.docker.com/engine/install/)
* Optional: [QEMU](https://www.qemu.org/download/) for multi-platform builds

> [Podman](https://podman.io/docs/installation) and [Podman Compose](https://github.com/containers/podman-compose) are not recommended due to potential issues with the default bridge network. Moreover, Podman doesn't directly manage restart policies and instead depends on systemd. However, Podman woks fine with the host network plugin. Pay attention that Docker cannot see Podman images and vice versa so better stick to one tool.

## Quick start

### Docker default bridge network

1. Start a server with the name 'ffa' (this command will automatically pull the Docker image and start a container):

    ```
    docker run --rm --name ffa -itd -p 3455:3455/udp docker.io/painkillergameclassic/pkserver:main
    ```

2. Check that the container with the pkserver is running:

    ```
    docker container ls
    ```

3. Open and forward the default Painkiller `3455` port in your firewall if required.

4. Check if your game is advertised on [OpenSpy](http://beta.openspy.net/en/server-list/painkiller)

5. Open the Painkiller game client and join a server.

    > It's likely that you won't see your own server in the in-game browser if you run the server and the clinet on the same machine so join it via IP.

    ```
    /connect ip
    ```

6. Stop the container named 'ffa':

    ```
    docker container stop ffa
    ```

7. Remove the stopped container:

    ```
    docker container prune
    ```

### Docker host network

In case you have any issues with the default Docker bridge network, like errors connected with NATNEG, try the Docker host network. In this case, you'll need to indicate the IP of your network card that has access to the internet:

```
docker run --rm --name ffa -itd -e Cfg_NetworkInterface="192.168.0.106" --net=host docker.io/painkillergameclassic/pkserver:main
```

### Running on a different port

In case you need to run a game on a different port, use Docker port mapping and the `Cfg_ServerPort` variable.

> Note that Painkiller GameSpy backend is outdated which can cause issues with the NATNEG protocol. Thus, we must map the same Docker ports on the container and the host and also change the port in the Painkiller config.ini. The following commands configure it under the hood.

Docker default bridge network:

```
docker run --rm --name ffa -itd -p 3456:3456/udp -e Cfg_ServerPort="3456" docker.io/painkillergameclassic/pkserver:main
```

Docker host network:

```
docker run --rm --name ffa -itd -e Cfg_ServerPort="3456" -e Cfg_NetworkInterface="192.168.0.106" --net=host docker.io/painkillergameclassic/pkserver:main
```

Alternative:

```
docker run --rm --name ffa -itd -e Cfg_ServerPort="3456" --net=host docker.io/painkillergameclassic/pkserver:main +interface 192.168.0.106
```

## Quick start with Docker Compose

Copy the `docker-compose.yml` file from this repository and run the following command in the same directory:

```
docker compose up -d
```

It will launch preconfigured servers.

Stop the servers:

```
docker compose down
```

## Building

1. Clone the repository

2. Optional: put custom maps inside the `pkserver/Data/` folder and modify `pkserver/Bin/config.ini`.

3. Run the following command:

    - 'dot' is an indication that you build the Docker image from the Dockerfile in this directory
    - `-t/--tag` is the name of your future local Docker image

    ```
    docker build . --no-cache -t pkserver:v1
    ```

4. Check that the image has been built:

    ```
    docker image ls
    ```

## Running a server after the build

1. Start a server with the name 'ffa':

    ```
    docker run --rm --name ffa -itd -p 3455:3455/udp pkserver:v1
    ```

2. Check that the container with the server is running:

    ```
    docker container ls
    ```

3. Stop the container named 'ffa':

    ```
    docker container stop ffa
    ```

### Using config variables

You can pass variables to a container instead of modifying `config.ini`.
Each variable corresponds to the `Cfg` parameter in `config.ini` and should start with `Cfg_`. The letter case does not matter, except for special `PKS_` variables.<br>
For example, `Cfg.ServerPort` corresponds to `CFG_SERVERPORT` or `Cfg_ServerPort`, `Cfg.NetworkInterface` to `CFG_NETWORKINTERFACE` or `Cfg_NetworkInterface`. However, `PKS_LSCRIPTS` should be passed with capital letters only.
Let's start a PK++ 1.3 server on a `3456` port:
```
docker run --rm --name ffa -itd -p 3456:3456/udp -e Cfg_ServerPort="3456" -e PKS_LSCRIPTS='PKPlus13.pak' docker.io/painkillergameclassic/pkserver:main
```

### Run a server with a custom config

Docker containers are ephemeral. It means that when you restart a container, all the information will be lost and you start from scratch. If you are NOT going to use variables for a container, you need to bind a file from the outside to the Docker container. The simplest way would be to use the [bind mounts](https://docs.docker.com/storage/bind-mounts/) Docker feature. As an alternative you can use Docker volumes but I found this method inconvenient for the Painkiller server management since you cannot insert data directly into a volume without copying it to a container.

1. Copy `./pkserver/Bin/config.ini` from the repository to your host, for example, to `${HOME}/my_pkserver/config.ini`.

2. Make sure the file has the right permissions:

```
chmod 664 config.ini
```

3. You can rename this file to whatever you like. Let's rename it to `config_ffa.ini`.

4. Run the server with the following commands. You bind `config_ffa.ini` on your host machine to `config.ini` in the Docker container:

```
export PKS_CFG_SOURCE="${HOME}/my_pkserver/config_ffa.ini"
docker run --rm --name ffa -itd --mount type=bind,source=${PKS_CFG_SOURCE},target=/opt/pkserver/Bin/config.ini -p 3455:3455/udp docker.io/painkillergameclassic/pkserver:main
```

### Run a server with custom lscripts

This repository has 2 custom packages: `./pkserver/Data/PKPlus12.pak` for PK++ 1.2 and `./pkserver/Data/PKPlus13.pak` for PK++ 1.3.

In order to run a specific version of the mod, pass the package name to the CLI via the Docker variable.

```
docker run --rm --name ffa -itd -p 3455:3455/udp -e PKS_LSCRIPTS='PKPlus13.pak' docker.io/painkillergameclassic/pkserver:main
```

You can also use lscripts packs with custom names; however, you'll need to bind them using bind mounts or add them to `./pkserver/Data/` and rebuild the Docker image.

> You can only give a custom name to `LScripts.pak` with the exact 8 letter size because it's a hack, for example, you can rename it to `LScript3.pak` but you cannot name it `MyLScripts.pak`.

Make sure the file has the right permissions:

```
chmod 664 LScript3.pak
```

```
export PKS_LSCRIPTS="LScript3.pak"
export PKS_LSCRIPTS_SOURCE="${HOME}/my_pkserver/${PKS_CFG}"
docker run --rm --name ffa -itd -p 3455:3455/udp -e PKS_LSCRIPTS --mount type=bind,source=${PKS_LSCRIPTS_SOURCE},target=/opt/pkserver/Data/${PKS_LSCRIPTS} docker.io/painkillergameclassic/pkserver:main
```

### Run a server with custom maps

Let's say you put a custom map to `${HOME}/my_pkserver/DM_K3Inzane.pkm`:

Make sure the file has the right permissions:

```
chmod 664 DM_K3Inzane.pkm
```

```
export MAP1="DM_K3Inzane.pkm"
export MAP1_SOURCE="${HOME}/my_pkserver/DM_K3Inzane.pkm"
docker run --rm --name ffa -itd -p 3455:3455/udp --mount type=bind,source=${MAP1_SOURCE},target=/opt/pkserver/Data/${MAP1} docker.io/painkillergameclassic/pkserver:main
```

### Run multiple containers based on the same image

You can run multiple server instances based on the same image by giving them different names and passing different parameters and ports.

> To change the port, go to `config.ini` and modify the `Cfg.ServerPort` line. Alternatively, you can set the `Cfg_ServerPort` variable.

Let's say I want to launch 3 servers (FFA, DUEL, CTF) on different ports using the same Docker image. The examples are simplified since I don't pass any additional configuration variables:

```
docker run --rm --name ffa -itd -p 3455:3455/udp docker.io/painkillergameclassic/pkserver:main
```

```
docker run --rm --name duel -itd -e Cfg_ServerPort="3456" -p 3456:3456/udp docker.io/painkillergameclassic/pkserver:main
```

```
docker run --rm --name ctf -itd -e Cfg_ServerPort="3457" -p 3457:3457/udp docker.io/painkillergameclassic/pkserver:main
```

Check the containers are running:

```
docker container ls
```

Check if there are failed containers:

```
docker container ls -a
```

Stop and delete all containers:

```
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

## Managing server logs and stats

Since this guide does not imply that you use Docker volumes, to manage `pkserver` logs and stats you need to create a cron job that periodically copies LOG and TXT files from a container to your host.

`pkserver` keeps them in the `/opt/pkserver/Bin/` directory. In this example, we copy LOG and TXT files from the container named 'ffa' to the `HOME` directory on the host:

```
docker exec ffa bash -c 'tar -cf - /opt/pkserver/Bin/*.log /opt/pkserver/Bin/*.txt' | tar --strip-components 3 -C ${HOME} -xvf -
```

## Managing server resources

`pkserver` has memory leaks. It is advised to set RAM limits on a container (250 MB for Duels and not more than 512 MB for FFA):

```
docker run --rm --name ffa -itd -p 3455:3455/udp --memory="400m" docker.io/painkillergameclassic/pkserver:main
```

Check the container stats:

```
docker stats
```

Set the container restart policy:

> Restart policy option only works with `docker` by default. If you want to use restart policies with `podman`, you need to run `podman generate systemd --restart-policy container_id` or find another workaround.

```
docker run --name ffa -itd -p 3455:3455/udp --memory="400m" --restart unless-stopped docker.io/painkillergameclassic/pkserver:main
```

Additional info:

- [Start containers automatically](https://docs.docker.com/config/containers/start-containers-automatically/)
- [Runtime options with Memory, CPUs, and GPUs](https://docs.docker.com/config/containers/resource_constraints/)

## Docker Compose

Docker Compose is a fast and convenient way to declaratively configure multiple containers. You can run multiple servers with one command, no scripts are required.

The `docker-compose.yml` is provided in this repository as a template. Most parameters are preconfigured.

> Pay attention to the `Cfg_ServerPort` variable or `config.ini` files. The port should be different for each server. If you, for example, run several servers on the same port, other containers will crash.

> **Issue**: Docker Compose mounts files as folders.
**Solution**: indicate the path to the `config.ini` file with dot/slash `source: ./config.ini`.

Configure it for your needs and run with:

```
docker compose up -d
```

Check the resources:

```
docker ps
```

Stop all containers:

```
docker compose down
```

```
docker container prune
```

## Mini Dockerfile

You can skip using this image. This is merely a wrapper around the `pkserver` package. It is implied that you have the full [pkserver](https://www.moddb.com/games/painkiller/downloads/painkiller-linux-server-164-full-openspy) package on your host and use that container binding every folder to it.

1. Building:

    ```
    docker build -f mini.Dockerfile . --no-cache -t pkserver-mini:v1
    ```

2. Launching. Let's assume you installed `pkserver` to the `${HOME}"/pkserver/` directory:

    ```
    docker run --rm -it --name mini -p 3455:3455/udp --mount type=bind,source="${HOME}"/pkserver/Bin,target=/opt/pkserver/Bin --mount type=bind,source="${HOME}"/pkserver/bin,target=/opt/pkserver/bin --mount type=bind,source="${HOME}"/pkserver/Data,target=/opt/pkserver/Data --mount type=bind,source="${HOME}"/pkserver/data,target=/opt/pkserver/data pkserver-mini:v1
    ```

## Debug a container

1. Pass the `+private` parameter to test Docker containers without exposing them to OpenSpy.

    ```
    docker run --rm --name ffa -itd -p 3455:3455/udp docker.io/painkillergameclassic/pkserver:main +private
    ```

2. To gracefully stop your server so that it won't dangle on OpenSpy, you need to attach to your container and run the `/quit` command:

    ```
    docker container attach ${container_name}
    ```

    To detach again, press `CTRL + P` followed by `CTRL + Q`.

3. You can enter your container with:

    ```
    docker exec -it ${container_name} bash
    ```

    To exit a container, type:

    ```
    exit
    ```

4. Enter a failed container by changing Docker entrypoint:

    ```
    docker run -it --entrypoint=bash ${container_name}
    ```

5. Login to a container as a root:

    ```
    docker exec -it -u 0 ffa bash
    ```

    You can then install all the required tools in the container with:

    ```
    apt-get update && apt-get install
    ```

6. To ping from a container, you need to enable some [container capabilities](https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities). Add ` --cap-add=IPC_LOCK --cap-add=NET_RAW` when starting a new container.

7. To copy inside/outside containers use [docker cp](https://docs.docker.com/reference/cli/docker/container/cp/).

8. Clean your system from Docker packages:

    ```
    docker system prune -a
    ```
