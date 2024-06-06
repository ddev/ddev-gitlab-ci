#!/usr/bin/env bash

GITHUB_OWNER=ddev
PUSH=""
IMAGE_NAME="ghcr.io/ochorocho/ddev-docker"
DDEV_VERSION=""

# @todo:
#   * Allow version v1.23 -> v1.23
#   * --push --load options
#   * Use bats for tests?!

help() {
    echo "Available options:"
    echo "  * v - DDEV version e.g. 'v1.23.1'"
    echo "  * l - Load the image (--load)"
    echo "  * p - Push the image (--push)"
}

loadVersionAndTags() {
  # @todo: Currently limited to 99 releases, may use pagination
  ddev_releases=($(curl --silent -L -H "Accept: application/vnd.github+json" https://api.github.com/repos/${GITHUB_OWNER}/ddev/releases?per_page=99 | jq -r '.[].tag_name'))

  IFS='.' read -r -a version <<< "$OPTION_VERSION"
  bugfix_release="${version[2]}"

  if [[ "${version[2]}" == "" ]]; then
    bugfix_release="[0-9]+"
    # Add minor tag version. In cas only major.minor is given, it will be tagged as well
    additional_tag="${version[0]}.${version[1]}"
  fi

  pattern="^${version[0]}\.${version[1]}\.${bugfix_release}$"
  filtered_array=()

  for element in "${ddev_releases[@]}"; do
    if [[ $element =~ $pattern ]]; then
      filtered_array+=("$element")
    fi
  done

  DDEV_VERSION="${filtered_array[0]}"

  # Define image tags
  if [[ $additional_tag == "" ]]; then
    DOCKER_TAGS=("-t $IMAGE_NAME:${DDEV_VERSION}")
  else
    DOCKER_TAGS=("-t $IMAGE_NAME:$additional_tag" "-t $IMAGE_NAME:$DDEV_VERSION")
  fi
}

while getopts ":v:h:p" opt; do
  case $opt in
  h)
    help
    exit 1
    ;;
  v)
    OPTION_VERSION="${OPTARG}"
    ;;
  p)
    PUSH="--push"
    ;;
  *)
    echo "Invalid option: -$OPTARG"
    help
    exit 1
    ;;
  esac
done

loadVersionAndTags

# @todo: Add --load option
docker buildx build --platform linux/amd64,linux/arm64 --no-cache --pull . -f Dockerfile ${DOCKER_TAGS[@]} --build-arg ddev_version="$DDEV_VERSION" $PUSH
#docker run --rm -it -v "$(pwd)/test.sh:/tmp/test.sh" --entrypoint "ash" "$IMAGE_NAME:$DDEV_VERSION" /tmp/test.sh
