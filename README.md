# DDEV GitLab CI - Docker in Docker (dind)

A container image to run DDEV on any GitLab Runner (hosted/self-hoster).

## Configuration for self-hosted GitLab Runners

The Runner can run on the two container engines - Docker and Podman.
Both container engines work, but the required configuration is slightly different.

### Example configurations for ...
 
* [gitlab.com](docs%2Fgitlab-com.md)
* [Docker](docs%2Fdocker.md)
* [Podman](docs%2Fpodman.md)

# Workflow - Image build

Build the image

```bash
./build.sh -v <version, at least major.minor> -p
``` 

Available options:
 * v - DDEV version e.g. 'v1.23.1' 
 * l - Load the image (--load)
 * p - Push the image (--push)
 * x - Build multi-arch image (--platform linux/amd64,linux/arm64)

## Version to tags

| Command               | Tags to be created             |
|-----------------------|--------------------------------|
| ./build.sh -v v1.22   | v1.22, v1.22.x (latest bugfix) |
| ./build.sh -v v1.22.5 | v1.22.5                        |
| ./build.sh -v v1.23   | v1.23, v1.23.x (latest bugfix) |
| ...                   | ...                            |

The image is stored on the [GitHub Package Registry](https://github.com/ochorocho/ddev-gitlab-ci/pkgs/container/ddev-gitlab-ci) 

## Run tests locally

Requires [bats-core](https://bats-core.readthedocs.io/en/stable/installation.html) and [yq](https://github.com/mikefarah/yq/tree/v4.44.2?tab=readme-ov-file#install).

```
DDEV_VERSION=v1.23.3 bash bats tests
```

