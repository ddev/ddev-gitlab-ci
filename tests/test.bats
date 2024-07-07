#!/bin/bash

@test "See docker version" {
    run docker-run "docker version -f json"

    version=$(echo "$output" | yq .Client.Version)
    regex='^([0-9]+)\.([0-9]+)\.([0-9]+)$'

    [[ $version =~ $regex ]]
    [ "$status" -eq 0 ]
}

@test "See ddev version" {
    run docker-run "ddev version -j"

    version=$(echo "$output" | tail -n 1 | yq '.raw.["DDEV version"]')
    regex='^v([0-9]+)\.([0-9]+)\.([0-9]+)$'

    [[ $version =~ $regex ]]
    [ "$status" -eq 0 ]
}

@test "See mkcert is installed" {
    run docker-run "mkcert -help"

    [[ "$output" == *"Usage of mkcert:"* ]]
    [ "$status" -eq 0 ]
}

@test "Create and run a ddev project" {
    local TEST_COMMAND="
        mkdir ~/ddev-test
        cd ~/ddev-test
        echo '<?php echo \"Hello World\";' > index.php
        ddev config --project-type php --auto
        ddev config global --no-bind-mounts=true
        ddev start
        curl https://ddev-test.ddev.site/index.php
        ddev poweroff
    "
    run docker-run "${TEST_COMMAND}"

    [[ "$output" == *"Configuration complete. You may now run 'ddev start'"* ]]
    [[ "$output" == *"Hello World"* ]]
    [ "$status" -eq 0 ]
}

@test "Run ddev debug dockercheck" {
    run docker-run "ddev debug dockercheck"

    [[ "$output" == *"Able to run simple container that mounts a volume."* ]]
    [[ "$output" == *"Able to use internet inside container."* ]]
    [ "$status" -eq 0 ]
}

# Use "--no-bind-mounts=true" to make "ddev debug test" pass. This is only required in testing environment
@test "Run ddev debug test" {
    local TEST_COMMAND="
      mkdir ~/ddev-test
      cd ~/ddev-test
      ddev config --project-type php --auto
      ddev config global --no-bind-mounts=true
      ddev debug test
    "
    run docker-run "${TEST_COMMAND}"

    [[ "$output" == *"All project containers are now ready."* ]]
    [[ "$output" == *"Successfully started tryddevproject-"* ]]
    [ "$status" -eq 0 ]
}

docker-run() {
  local COMMAND=${1}

  docker run --rm -it --network ddev-docker ghcr.io/ochorocho/ddev-gitlab-ci:"${DDEV_VERSION}" /bin/sh -c "${COMMAND}"
}
