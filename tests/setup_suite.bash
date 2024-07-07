#!/usr/bin/env bats

setup_suite() {
  NETWORK="ddev-docker"
  if docker network inspect "$NETWORK" &>/dev/null; then
      echo "Network '$NETWORK' already exists."
  else
      echo "Creating network '$NETWORK'."
      docker network create "$NETWORK"
  fi

  docker run --privileged -e DOCKER_TLS_CERTDIR="" --name ddev-dind -d --network ddev-docker --network-alias docker docker:dind
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
}
