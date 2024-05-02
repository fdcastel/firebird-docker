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
