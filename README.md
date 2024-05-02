# firebird-docker

Docker images for Firebird Database.



# Quick reference

  - [Quick Start Guide](https://firebirdsql.org/file/documentation/html/en/firebirddocs/qsg5/firebird-5-quickstartguide.html)
  - [Language Reference](https://firebirdsql.org/file/documentation/html/en/refdocs/fblangref50/firebird-50-language-reference.html)
  - [Release Notes](https://firebirdsql.org/file/documentation/release_notes/html/en/5_0/rlsnotes50.html)



# Supported tags

|Tags|Dockerfile|OS|Last modified|
|-|:-:|:-:|:-:|
|`5`, `5-bookworm`, `bookworm`, `latest`|[Dockerfile](./generated/5/bookworm/Dockerfile)|Debian 12.5|2024-05-02|
|`5-jammy`, `jammy`|[Dockerfile](./generated/5/jammy/Dockerfile)|Ubuntu 22.04|2024-05-02|
|`4`, `4-bookworm`|[Dockerfile](./generated/4/bookworm/Dockerfile)|Debian 12.5|2024-05-02|
|`4-jammy`|[Dockerfile](./generated/4/jammy/Dockerfile)|Ubuntu 22.04|2024-05-02|
|`3`, `3-bookworm`|[Dockerfile](./generated/3/bookworm/Dockerfile)|Debian 12.5|2024-05-02|
|`3-jammy`|[Dockerfile](./generated/3/jammy/Dockerfile)|Ubuntu 22.04|2024-05-02|



# How to use this image


_[ToDo]_

_(Meanwhile, you can look at [the tests](src/image.tests.ps1#L71) to see what you can do)_

## Environment variables

The following environment variables can be used to customize the container.




### `FIREBIRD_ROOT_PASSWORD`
  - _alternate name_: `ISC_PASSWORD`

If present sets the password for `SYSDBA` user.

If not present a random password will be generated and stored into `/opt/firebird/SYSDBA.password`.



### `FIREBIRD_USER`

Creates a user in Firebird security database.

You must inform a password in `FIREBIRD_PASSWORD` variable. Otherwise the container initialization will fail.



### `FIREBIRD_DATABASE`

Creates a new database. Ignored if the database already exists.

Database location is `/run/firebird/data`. Absolute paths (outside this folder) are allowed.

You may use `FIREBIRD_DATABASE_PAGE_SIZE` to set the database page size.

You may use `FIREBIRD_DATABASE_DEFAULT_CHARSET` to set the default character set.



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



# Development notes

## Prerequisites

  - [Powershell](https://github.com/PowerShell/PowerShell):
    ```bash
    # On Ubuntu
    snap install powershell --classic
    pwsh
    ```

  - [`Invoke-Build`](https://github.com/nightroman/Invoke-Build):
    ```powershell
    Install-Module InvokeBuild -Force
    ```



## Build

To generate the source files and build each image from [`assets.json`](assets.json) configuration file, run:

```bash
Invoke-Build
```

You can then check all created images with:

```bash
docker image ls ghcr.io/fdcastel/firebird
```

```
REPOSITORY                  TAG          IMAGE ID       CREATED         SIZE
ghcr.io/fdcastel/firebird   5-jammy      7fcc613eadfc   2 minutes ago   177MB
ghcr.io/fdcastel/firebird   5-bookworm   aa93296f37d4   2 minutes ago   178MB
ghcr.io/fdcastel/firebird   3-jammy      c966eb830115   2 minutes ago   145MB
ghcr.io/fdcastel/firebird   4-jammy      e12502e3385a   2 minutes ago   186MB
ghcr.io/fdcastel/firebird   4-bookworm   174c278cfa9c   2 minutes ago   188MB
ghcr.io/fdcastel/firebird   3-bookworm   993b80786814   2 minutes ago   145MB
```


## Tests

To run the test suite for each image, use:

```bash
Invoke-Build Test
```
