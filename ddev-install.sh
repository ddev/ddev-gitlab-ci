#!/usr/bin/ash

apk add --no-cache bash sudo jq curl
adduser -D ddev -g "ddev" -s /bin/bash -D ddev -h /home/ddev
echo "ddev ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ddev && chmod 0440 /etc/sudoers.d/ddev
unamearch=$(uname -m)

RED='\033[31m'
RESET='\033[0m'

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

# Prepare and install binaries
mkdir ddev

if [ "$DDEV_VERSION" = "latest" ]; then
  # Download ddev head (nightly)
  wget "https://nightly.link/ddev/ddev/workflows/master-build/master/all-ddev-executables.zip"

  unzip all-ddev-executables.zip
  tar xfvz ddev_linux-${ARCH}.* --directory ddev
  # Extract nightly version from file name
  LAST_STARTED_VERSION=$(find ddev_linux-${ARCH}* | sed -n "s/.*ddev_linux-${ARCH}\.\(.*\)\.tar\.gz/\1/p")
else
  # Download specific ddev version
  wget "https://github.com/ddev/ddev/releases/download/${DDEV_VERSION}/ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz"

  tar xfvz "ddev_linux-${ARCH}.${DDEV_VERSION}.tar.gz" --directory ddev
  LAST_STARTED_VERSION=${DDEV_VERSION}
fi

mv ddev/ddev /usr/local/bin/
mv ddev/mkcert /usr/local/bin/
sudo -u ddev /usr/local/bin/mkcert -install
rm -Rf ddev*

# Ensure required folders exist
mkdir -p /home/ddev/.ddev/commands/host
echo "
disable_http2: false
fail_on_hook_fail: false
instrumentation_opt_in: false
internet_detection_timeout_ms: 3000
last_started_version: ${LAST_STARTED_VERSION}
letsencrypt_email: ""
mkcert_caroot: /home/ddev/.local/share/mkcert
no_bind_mounts: false
omit_containers: []
performance_mode: none
project_tld: ddev.site
router: traefik
router_bind_all_interfaces: false
router_http_port: \"80\"
router_https_port: \"443\"
mailpit_http_port: \"8025\"
mailpit_https_port: \"8026\"
simple_formatting: false
table_style: default
traefik_monitor_port: \"10999\"
use_hardened_images: false
use_letsencrypt: false
wsl2_no_windows_hosts_mgt: false
web_environment: []
xdebug_ide_location: ""
" > /home/ddev/.ddev/global_config.yaml

mkdir /builds
chown -R ddev:ddev /home/ddev /builds
