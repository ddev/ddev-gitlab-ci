# DDEV GitLab CI - Docker in Docker (dind)

This image is most likely to be used within the GitLab Runner.
As of now it only tested it on gitlab.com

**GitLab CI example**: [.gitlab-ci.yml](.gitlab-ci.yml)

# Workflow - Image build

Build the image

```bash
./build.sh -v <version, at least major.minor> -p
``` 

Available options:
 * v - DDEV version e.g. 'v1.23.1' 
 * l - Load the image (--load)
 * p - Push the image (--push)

## Version to tags

| Command               | Tags to be created             |
|-----------------------|--------------------------------|
| ./build.sh -v v1.22   | v1.22, v1.22.x (latest bugfix) |
| ./build.sh -v v1.22.5 | v1.22.5                        |
| ./build.sh -v v1.23   | v1.23, v1.23.x (latest bugfix) |
| ...                   | ...                            |


## TEST

Any good to disable TLS?!

```bash
NETWORK="ddev-docker"
if docker network inspect "$NETWORK" &>/dev/null; then
    echo "Network '$NETWORK' already exists."
else
    echo "Creating network '$NETWORK'."
    docker network create "$NETWORK"
fi

# Get DinD ready - need privileged mode?!?!?
# WORKING:::  docker run --privileged -e DOCKER_TLS_CERTDIR="" --name ddev-dind -d --network ddev-docker --network-alias docker docker:dind
docker run --privileged -e DOCKER_TLS_CERTDIR="" --name ddev-dind -d --network ddev-docker --network-alias docker docker:dind-rootless

# Wait till DinD is ready

# Run ddev/docker related commands - - -e DOCKER_HOST="tcp://docker:2375/"
docker run --rm -it --network ddev-docker ghcr.io/ochorocho/ddev-gitlab-ci:v1.23.3 version
```
