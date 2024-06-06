#!/bin/bash

docker --version | head -n 1 || exit 1
docker-compose --version | head -n 1 || exit 1
ddev --version | head -n 1 || exit 1
mkcert -version
echo "Current user: $(whoami)"
