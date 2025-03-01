
[//]: # (This file was auto-generated. Do not edit. See /src.)

# firebird-docker

Docker images for Firebird Database.



# Quick reference

  - [Quick Start Guide](https://firebirdsql.org/file/documentation/html/en/firebirddocs/qsg5/firebird-5-quickstartguide.html)
  - [Language Reference](https://firebirdsql.org/file/documentation/html/en/refdocs/fblangref50/firebird-50-language-reference.html)
  - [Release Notes](https://firebirdsql.org/file/documentation/release_notes/html/en/5_0/rlsnotes50.html)



# Supported tags

|`firebirdsql/firebird`|Dockerfile|
|:-|:-:|
|`5`, `5.0.2`, `latest`|[Dockerfile](./generated/5.0.2/bookworm/Dockerfile)|
 |`bullseye`, `5-bullseye`, `5.0.2-bullseye`|[Dockerfile](./generated/5.0.2/bullseye/Dockerfile)|
 |`jammy`, `5-jammy`, `5.0.2-jammy`|[Dockerfile](./generated/5.0.2/jammy/Dockerfile)|
 |`noble`, `5-noble`, `5.0.2-noble`|[Dockerfile](./generated/5.0.2/noble/Dockerfile)|
 |`5.0.1`|[Dockerfile](./generated/5.0.1/bookworm/Dockerfile)|
 |`5.0.1-bullseye`|[Dockerfile](./generated/5.0.1/bullseye/Dockerfile)|
 |`5.0.1-jammy`|[Dockerfile](./generated/5.0.1/jammy/Dockerfile)|
 |`5.0.1-noble`|[Dockerfile](./generated/5.0.1/noble/Dockerfile)|
 |`5.0.0`|[Dockerfile](./generated/5.0.0/bookworm/Dockerfile)|
 |`5.0.0-bullseye`|[Dockerfile](./generated/5.0.0/bullseye/Dockerfile)|
 |`5.0.0-jammy`|[Dockerfile](./generated/5.0.0/jammy/Dockerfile)|
 |`5.0.0-noble`|[Dockerfile](./generated/5.0.0/noble/Dockerfile)|
 |`4`, `4.0.5`|[Dockerfile](./generated/4.0.5/bookworm/Dockerfile)|
 |`4-bullseye`, `4.0.5-bullseye`|[Dockerfile](./generated/4.0.5/bullseye/Dockerfile)|
 |`4-jammy`, `4.0.5-jammy`|[Dockerfile](./generated/4.0.5/jammy/Dockerfile)|
 |`4-noble`, `4.0.5-noble`|[Dockerfile](./generated/4.0.5/noble/Dockerfile)|
 |`4.0.4`|[Dockerfile](./generated/4.0.4/bookworm/Dockerfile)|
 |`4.0.4-bullseye`|[Dockerfile](./generated/4.0.4/bullseye/Dockerfile)|
 |`4.0.4-jammy`|[Dockerfile](./generated/4.0.4/jammy/Dockerfile)|
 |`4.0.4-noble`|[Dockerfile](./generated/4.0.4/noble/Dockerfile)|
 |`4.0.3`|[Dockerfile](./generated/4.0.3/bookworm/Dockerfile)|
 |`4.0.3-bullseye`|[Dockerfile](./generated/4.0.3/bullseye/Dockerfile)|
 |`4.0.3-jammy`|[Dockerfile](./generated/4.0.3/jammy/Dockerfile)|
 |`4.0.3-noble`|[Dockerfile](./generated/4.0.3/noble/Dockerfile)|
 |`4.0.2`|[Dockerfile](./generated/4.0.2/bookworm/Dockerfile)|
 |`4.0.2-bullseye`|[Dockerfile](./generated/4.0.2/bullseye/Dockerfile)|
 |`4.0.2-jammy`|[Dockerfile](./generated/4.0.2/jammy/Dockerfile)|
 |`4.0.2-noble`|[Dockerfile](./generated/4.0.2/noble/Dockerfile)|
 |`4.0.1`|[Dockerfile](./generated/4.0.1/bookworm/Dockerfile)|
 |`4.0.1-bullseye`|[Dockerfile](./generated/4.0.1/bullseye/Dockerfile)|
 |`4.0.1-jammy`|[Dockerfile](./generated/4.0.1/jammy/Dockerfile)|
 |`4.0.1-noble`|[Dockerfile](./generated/4.0.1/noble/Dockerfile)|
 |`4.0.0`|[Dockerfile](./generated/4.0.0/bookworm/Dockerfile)|
 |`4.0.0-bullseye`|[Dockerfile](./generated/4.0.0/bullseye/Dockerfile)|
 |`4.0.0-jammy`|[Dockerfile](./generated/4.0.0/jammy/Dockerfile)|
 |`4.0.0-noble`|[Dockerfile](./generated/4.0.0/noble/Dockerfile)|
 |`3`, `3.0.12`|[Dockerfile](./generated/3.0.12/bookworm/Dockerfile)|
 |`3-bullseye`, `3.0.12-bullseye`|[Dockerfile](./generated/3.0.12/bullseye/Dockerfile)|
 |`3-jammy`, `3.0.12-jammy`|[Dockerfile](./generated/3.0.12/jammy/Dockerfile)|
 |`3.0.11`|[Dockerfile](./generated/3.0.11/bookworm/Dockerfile)|
 |`3.0.11-bullseye`|[Dockerfile](./generated/3.0.11/bullseye/Dockerfile)|
 |`3.0.11-jammy`|[Dockerfile](./generated/3.0.11/jammy/Dockerfile)|
 |`3.0.10`|[Dockerfile](./generated/3.0.10/bookworm/Dockerfile)|
 |`3.0.10-bullseye`|[Dockerfile](./generated/3.0.10/bullseye/Dockerfile)|
 |`3.0.10-jammy`|[Dockerfile](./generated/3.0.10/jammy/Dockerfile)|
 |`3.0.9`|[Dockerfile](./generated/3.0.9/bookworm/Dockerfile)|
 |`3.0.9-bullseye`|[Dockerfile](./generated/3.0.9/bullseye/Dockerfile)|
 |`3.0.9-jammy`|[Dockerfile](./generated/3.0.9/jammy/Dockerfile)|
 |`3.0.8`|[Dockerfile](./generated/3.0.8/bookworm/Dockerfile)|
 |`3.0.8-bullseye`|[Dockerfile](./generated/3.0.8/bullseye/Dockerfile)|
 |`3.0.8-jammy`|[Dockerfile](./generated/3.0.8/jammy/Dockerfile)|


> _Firebird 3 does not have an image for Ubuntu 24.04 LTS (Noble Numbat) due to a dependency (`libncurses5`) missing from Ubuntu sources._



# How to use this image

Image defaults:
  - `EXPOSE 3050/tcp`
  - `VOLUME /var/lib/firebird/data`

## Start a Firebird server instance

```bash
docker run \
    -e FIREBIRD_ROOT_PASSWORD=************ \
    -e FIREBIRD_USER=alice \
    -e FIREBIRD_PASSWORD=************ \
    -e FIREBIRD_DATABASE=mirror.fdb \
    -e FIREBIRD_DATABASE_DEFAULT_CHARSET=UTF8 \
    -v ./data:/var/lib/firebird/data \
    --detach firebirdsql/firebird
```



## Using [`Docker Compose`](https://github.com/docker/compose)

```yaml
services:
  firebird:
    image: firebirdsql/firebird
    restart: always
    environment:
      - FIREBIRD_ROOT_PASSWORD=************
      - FIREBIRD_USER=alice
      - FIREBIRD_PASSWORD=************
      - FIREBIRD_DATABASE=mirror.fdb
      - FIREBIRD_DATABASE_DEFAULT_CHARSET=UTF8
    volumes:
      - ./data:/var/lib/firebird/data
```



## Connect to an existing instance using `isql`

```bash
docker run -it --rm firebirdsql/firebird isql -u SYSDBA -p ************ SERVER:/path/to/file.fdb
```



## Environment variables

The following environment variables can be used to customize the container.



### `FIREBIRD_ROOT_PASSWORD`

Firebird installer generates a one-off password for `SYSDBA` and stores it in `/opt/firebird/SYSDBA.password`.

If `FIREBIRD_ROOT_PASSWORD` is set, `SYSDBA` password will be changed. And the file `/opt/firebird/SYSDBA.password` will be removed.



### `FIREBIRD_USER`

Creates an user in Firebird security database.

You must inform a password in `FIREBIRD_PASSWORD` variable. Otherwise the container initialization will fail.



### `FIREBIRD_DATABASE`

Creates a new database. Ignored if the database already exists.

Database location is `/var/lib/firebird/data`. Absolute paths (outside this folder) are allowed.

You may use `FIREBIRD_DATABASE_PAGE_SIZE` to set the database page size. And `FIREBIRD_DATABASE_DEFAULT_CHARSET` to set the default character set.



### `FIREBIRD_USE_LEGACY_AUTH`

Enables [legacy authentication](https://firebirdsql.org/file/documentation/release_notes/html/en/3_0/rlsnotes30.html#rnfb30-compat-legacyauth) (not recommended).



### `FIREBIRD_CONF_*`

Any variable starting with `FIREBIRD_CONF_` can be used to set values in Firebird configuration file (`firebird.conf`).

E.g. You can use `FIREBIRD_CONF_DataTypeCompatibility=3.0` to set the value of key `DataTypeCompatibility` to `3.0` in `firebird.conf`.

Please note that keys are case sensitive. And any key not present in `firebird.conf` will be ignored.



### `*_FILE`

Any of the previously listed environment variables may be loaded from file by appending the `_FILE` suffix to the variable name.

E.g. `FIREBIRD_PASSWORD_FILE=/run/secrets/firebird-passwd` will load `FIREBIRD_PASSWORD` with the content from `/run/secrets/firebird-passwd` file.

Note that both the original variable and its `_FILE` variant are mutually exclusive. Trying to use both will cause the container initialization to fail.



## Using database aliases

To use database aliases, create your own `databases.conf` file and configure a [Docker bind mount](https://docs.docker.com/engine/storage/bind-mounts/) for it at `/opt/firebird/databases.conf`.

More information: 
- [Firebird Quick Start Guide](https://www.firebirdsql.org/file/documentation/html/en/firebirddocs/qsg3/firebird-3-quickstartguide.html#qsg3-config-security) (section "Use database aliases")



## Using Firebird Events

To use this image with [Firebird Events](https://firebirdsql.org/file/documentation/html/en/refdocs/fblangref50/firebird-50-language-reference.html#fblangref50-psql-postevent) you need to:
- use `FIREBIRD_CONF_RemoteAuxPort` environment variable to set the value of `RemoteAuxPort` configuration to a specific port (e.g. 3051); and
- [Publish](https://docs.docker.com/get-started/docker-concepts/running-containers/publishing-ports/) this port to the host.

More information:

- [This answer](https://stackoverflow.com/a/49918178/33244) from Mark Rotteveel at Stack Overflow.
- [The Power of Firebird Events](https://www.firebirdsql.org/file/documentation/papers_presentations/Power_Firebird_events.pdf) from Milan Babuškov.



## Initializing the database contents

When creating a new database with `FIREBIRD_DATABASE` environment variable you can initialize it running one or more shell or SQL scripts.

Any file with extensions `.sh`, `.sql`, `.sql.gz`, `.sql.xz` and `.sql.zst` found in `/docker-entrypoint-initdb.d/` will be executed in _alphabetical_ order. `.sh` files without file execute permission (`+x`) will be _sourced_ rather than executed.

**IMPORTANT:** Scripts will only run if you start the container with a data directory that is empty. Any pre-existing database will be left untouched on container startup.



## Setting container time zone

The container runs in the `UTC` time zone by default. To change this, you can set the `TZ` environment variable:

```yaml
    environment:
      - TZ=America/New_York
```

Alternatively, you can use the same time zone as your host system by mapping the `/etc/localtime` and `/etc/timezone` system files:

```yaml
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
```

# Development notes

## Prerequisites

  - [Docker](https://docs.docker.com/engine/install/)
  - [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)
  - [Invoke-Build](https://github.com/nightroman/Invoke-Build#install-as-module)



## Build

To generate the source files and build each image from [`assets.json`](assets.json) configuration file, run:

```bash
Invoke-Build
```

You can then check all created images with:

```bash
docker image ls firebirdsql/firebird
```



## Tests

To run the test suite for each image, use:

```bash
Invoke-Build Test
```

