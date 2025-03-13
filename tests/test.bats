#!/bin/bash

setup() {
  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support
}

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

    if [ "$DDEV_VERSION" = "latest" ]; then
      # The HEAD version contains a hash e.g. v1.24.1-4-gbce95e65e
      regex='^v([0-9]+)\.([0-9]+)\.([0-9]+)-([0-9]+)-([a-z0-9]+)$'
    else
      regex='^v([0-9]+)\.([0-9]+)\.([0-9]+)$'
    fi

    [[ $version =~ $regex ]]
    [ "$status" -eq 0 ]
}

@test "See mkcert is installed" {
    run docker-run "mkcert -help"

    assert_output --partial "Usage of mkcert:"
    assert_success
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

    assert_output --partial "Configuration complete. You may now run 'ddev start'"
    assert_output --partial "Hello World"
    assert_success
}

@test "Run ddev debug dockercheck" {
    run docker-run "ddev debug dockercheck"

    assert_output --partial "Able to run simple container that mounts a volume."
    assert_output --partial "Able to use internet inside container."
    assert_success
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

    assert_output --partial "Successfully started tryddevproject-"
    assert_success
}

docker-run() {
  local COMMAND=${1}

  docker run --rm -it --network ddev-docker ghcr.io/ddev/ddev-gitlab-ci:"${DDEV_VERSION}" /bin/sh -c "${COMMAND}"
}
