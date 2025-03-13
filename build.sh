#!/usr/bin/env bash

GITHUB_OWNER=ddev
PUSH=""
LOAD=""
IMAGE_NAME="ghcr.io/ddev/ddev-gitlab-ci"
DDEV_VERSION=""

# @todo:
#   * --push --load options
#   * Use bats for tests?!

help() {
    echo "Available options:"
    echo "  * v - DDEV version e.g. 'v1.23.1'"
    echo "  * l - Load the image (--load)"
    echo "  * p - Push the image (--push)"
    echo "  * x - Build multi-arch image (--platform linux/amd64,linux/arm64)"
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

while getopts ":v:hplx" opt; do
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
  l)
    LOAD="--load"
    ;;
  x)
    PLATFORM="--platform linux/amd64,linux/arm64"
    ;;
  *)
    help
    echo "Invalid option: -$OPTARG"
    exit 1
    ;;
  esac
done

# Set version and tag for latest (aka nightly)
if [ "$OPTION_VERSION" = "latest" ]; then
  DDEV_VERSION="latest"
  DOCKER_TAGS=("-t $IMAGE_NAME:latest")
elif [ "$OPTION_VERSION" = "stable" ]; then
  DDEV_VERSION="$(curl --silent -L -H "Accept: application/vnd.github+json" https://api.github.com/repos/ddev/ddev/releases/latest | jq -r '.tag_name')"

  if [[ ! "$DDEV_VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Latest DDEV release '$DDEV_VERSION' is not a valid semver version."
    exit 2
  fi

  # Get version like v1.24
  additional_tag="${DDEV_VERSION%.*}"

  DOCKER_TAGS=("-t $IMAGE_NAME:stable" "-t $IMAGE_NAME:$additional_tag" "-t $IMAGE_NAME:$DDEV_VERSION")
else
  loadVersionAndTags
fi

echo $DDEV_VERSION
echo $DOCKER_TAGS

docker buildx build ${PLATFORM} --progress plain --no-cache --pull . -f Dockerfile ${DOCKER_TAGS[@]} --build-arg ddev_version="$DDEV_VERSION" $PUSH $LOAD
