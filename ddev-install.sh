#!/usr/bin/ash

apk add --no-cache bash sudo jq
adduser -D ddev -g "ddev" -s /bin/bash -D ddev -h /home/ddev
echo "ddev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ddev && chmod 0440 /etc/sudoers.d/ddev
unamearch=$(uname -m)

# Get binary to be downloaded
case ${unamearch} in
  x86_64) ARCH="amd64";
;;
  aarch64) ARCH="arm64";
;;
  arm64) ARCH="arm64"
;;
*) printf "${RED}Sorry, your machine architecture ${unamearch} is not currently supported.\n${RESET}" && exit 106
;;
esac

wget "https://github.com/ddev/ddev/releases/download/${DDEV_VERSION}/ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"

# Prepare and install binaries
mkdir ddev
tar xfvz "ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz" --directory ddev
mv ddev/ddev /usr/local/bin/
mv ddev/mkcert /usr/local/bin/
rm -Rf ddev "ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"

# Ensure required folders exist
mkdir -p /home/ddev/.ddev/commands/host
chown -R ddev:ddev /home/ddev/.ddev/
