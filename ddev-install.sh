#!/usr/bin/ash

apk add bash sudo
adduser -D ddev -g "ddev" -s /bin/bash -D ddev -h /home/ddev
echo "ddev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ddev && chmod 0440 /etc/sudoers.d/ddev
unamearch=$(uname -m)
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

echo "https://github.com/ddev/ddev/releases/download/${DDEV_VERSION}/ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"

wget "https://github.com/ddev/ddev/releases/download/${DDEV_VERSION}/ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"
tar xfvz "ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"
mv ddev /usr/local/bin/

# Ensure required folders exist
mkdir -p /home/ddev/.ddev/commands/host
chown -R ddev:ddev /home/ddev/.ddev/

# Install mkcert
wget "https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-${ARCH}"
mv "mkcert-v1.4.4-linux-${ARCH}" /usr/local/bin/mkcert
chmod +x /usr/local/bin/mkcert
