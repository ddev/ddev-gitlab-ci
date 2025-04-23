[![Docker Image](https://img.shields.io/badge/GitHub-Packages-2496ED?logo=github&logoColor=white)](https://github.com/ddev/ddev-gitlab-ci/pkgs/container/ddev-gitlab-ci)
[![build](https://github.com/ddev/ddev-gitlab-ci/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/ddev/ddev-gitlab-ci/actions/workflows/build.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/ddev/ddev-gitlab-ci)](https://github.com/ddev/ddev-gitlab-ci/commits)

# DDEV GitLab CI - Docker in Docker (dind)

A container image to run DDEV on any GitLab Runner (hosted/self-hosted).

## Configuration for GitLab Runners

The Runner can run on the two container engines - Docker and Podman.
Both container engines work, but the required configuration is slightly different.

### Example configurations

Depending on your setup, you want to pick one of the following example configurations.

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
 * `-v` - DDEV version e.g. `v1.24.4`
 * `-l` - Load the image (`--load`)
 * `-p` - Push the image (`--push`)
 * `-x` - Build multi-arch image (`--platform linux/amd64,linux/arm64`)

### Version to tags

| Command                 | Tags to be created                   |
|-------------------------|--------------------------------------|
| `./build.sh -v latest`  | `latest` (aka head/nightly)          |
| `./build.sh -v stable`  | `stable`, `v1.x`, `v1.x.y` (release) |
| `./build.sh -v v1.24`   | `v1.24`, `v1.24.x` (latest bugfix)   |
| `./build.sh -v v1.24.4` | `v1.24.4`                            |
| `./build.sh -v v1.23`   | `v1.23`, `v1.23.x` (latest bugfix)   |
| ...                     | ...                                  |

The image is stored on the [GitHub Packages Registry](https://github.com/ddev/ddev-gitlab-ci/pkgs/container/ddev-gitlab-ci).

> [!NOTE]
> `GITHUB_TOKEN` needs additional configuration https://github.com/orgs/community/discussions/26274#discussioncomment-3251137:
>
> Head over to $yourOrganization → Packages → $yourPackage → Package settings (to the right / bottom)
>
> And configure “Manage Actions access” section to allow the git repository in question write permissions on this package/docker repository

### Run tests locally

Requires [bats-core](https://bats-core.readthedocs.io/en/stable/installation.html) and [yq](https://github.com/mikefarah/yq/tree/v4.44.2?tab=readme-ov-file#install).

```bash
DDEV_VERSION=latest bash bats tests
```

**Maintained by [@ochorocho](https://github.com/ochorocho) and [@b13](https://github.com/b13)**
