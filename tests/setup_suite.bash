#!/usr/bin/env bats

setup_suite() {
  NETWORK="ddev-docker"
  if docker network inspect "$NETWORK" &>/dev/null; then
      echo "Network '$NETWORK' already exists."
  else
      echo "Creating network '$NETWORK'."
      docker network create "$NETWORK"
  fi

  # Create a shared volume for bind mounts
  SHARED_VOLUME="ddev-shared-volume"
  if docker volume inspect "$SHARED_VOLUME" &>/dev/null; then
      echo "Volume '$SHARED_VOLUME' already exists."
  else
      echo "Creating volume '$SHARED_VOLUME'."
      docker volume create "$SHARED_VOLUME"
  fi

  # Initialize the shared volume with full permissions
  docker run --rm \
    -v "$SHARED_VOLUME:/mnt/ddev-shared" \
    alpine:latest sh -c "mkdir -p /mnt/ddev-shared && chmod -R 777 /mnt/ddev-shared"

  # Run DIND with the shared volume mounted
  docker run --privileged -e DOCKER_TLS_CERTDIR="" \
    --name ddev-dind \
    -d \
    --network ddev-docker \
    --network-alias docker \
    -v "$SHARED_VOLUME:/mnt/ddev-shared" \
    docker:dind
  waitForDinD
}

waitForDinD() {
    local TEST_COMMAND="
        COUNT=0;
        while ! docker info > /dev/null 2>&1; do
          if [ \"\${COUNT}\" -ge 30 ]; then
            echo \"Could not connect to docker after \$COUNT seconds\"
            exit 1
          fi

          sleep 1
          COUNT=\$((COUNT + 1));
        done
    "

    docker run --rm --network ddev-docker --name wait-for-docker-dind "docker:latest" /bin/sh -c "${TEST_COMMAND}"
}

teardown_suite() {
  docker stop ddev-dind
  docker rm ddev-dind
  docker volume rm ddev-shared-volume
}
