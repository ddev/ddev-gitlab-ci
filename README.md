# DDEV GitLab CI - Docker in Docker (dind)

A container image to run DDEV on any GitLab Runner (hosted/self-hosted).

## Configuration for GitLab Runners

The Runner can run on the two container engines - Docker and Podman.
Both container engines work, but the required configuration is slightly different.

### Example configurations

Depending on your setup, you want to pick one if the following example configurations.

* [gitlab.com](docs%2Fgitlab-com.md)
* [Docker](docs%2Fdocker.md) (self-hosted)
* [Podman](docs%2Fpodman.md) (self-hosted)

## Image build (for contribution only)

If you want to extend the image, you'll find the instructions
and details below.

Build the image:

```bash
./build.sh -v <version, at least major.minor> -p
```

Available options:
 * v - DDEV version e.g. 'v1.23.1'
 * l - Load the image (--load)
 * p - Push the image (--push)
 * x - Build multi-arch image (--platform linux/amd64,linux/arm64)

### Version to tags

| Command               | Tags to be created             |
|-----------------------|--------------------------------|
| ./build.sh -v latest  | latest (aka head/nightly)      |
| ./build.sh -v stable  | stable, v1.x, v1.x.y (release) |
| ./build.sh -v v1.22   | v1.22, v1.22.x (latest bugfix) |
| ./build.sh -v v1.22.5 | v1.22.5                        |
| ./build.sh -v v1.23   | v1.23, v1.23.x (latest bugfix) |
| ...                   | ...                            |

The image is stored on the [GitHub Package Registry](https://github.com/ddev/ddev-gitlab-ci/pkgs/container/ddev-gitlab-ci)

### Run tests locally

Requires [bats-core](https://bats-core.readthedocs.io/en/stable/installation.html) and [yq](https://github.com/mikefarah/yq/tree/v4.44.2?tab=readme-ov-file#install).



```
DDEV_VERSION=v1.23.3 bash bats tests
```

**Maintained by [@ochorocho](https://github.com/ochorocho) and [@b13](https://github.com/b13)**
