#!/bin/bash

docker --version | head -n 1 || exit 1
docker-compose --version | head -n 1 || exit 1
ddev --version | head -n 1 || exit 1
echo "mkcert $(mkcert -version || exit 1)"
echo "Current user: $(whoami)"
