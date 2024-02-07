#!/bin/bash
#
# OS Base Update and Installation

set -e

go_version=$2
kernel_version=$1

echo "Updating OS and install packages"

# Accept config prompts without user for tshark
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
echo "wireshark-common wireshark-common/group-is-user-group boolean true" | sudo debconf-set-selections

DEBIAN_FRONTEND=noninteractive sudo apt-get -yqq update && sudo apt-get -yqq dist-upgrade
DEBIAN_FRONTEND=noninteractive sudo apt-get install -yqq \
  apt-transport-https \
  bird \
  build-essential \
  curl \
  iproute2 \
  jq \
  libbpf-dev \
  libsystemd-dev \
  libxtables-dev \
  linux-headers-$kernel_version \
  linux-image-$kernel_version \
  net-tools \
  python3-pip \
  software-properties-common \
  tcpdump \
  tshark \
  wget
  echo "Done!"

echo "Installing Go"
wget --quiet https://go.dev/dl/go$go_version.linux-amd64.tar.gz -O- | sudo tar -C /usr/local -zxf -
sudo bash -c "cat > /etc/profile.d/gopath.sh <<'EOFGO'
  export GOROOT=/usr/local/go
  export GOPATH=/go
  export PATH="${GOPATH}/bin:${GOROOT}/bin:${HOME}/.local/bin:${PATH}"
EOFGO
  "
echo "Done!"

# Allow non-root user to run packet captures
echo "Update Wireshark permissions"
sudo groupadd wireshark || true
sudo usermod -a -G wireshark $USER || true
sudo chgrp wireshark /usr/bin/dumpcap
sudo chmod 4750 /usr/bin/dumpcap
pip install -r ../../requirements-focal.txt
echo "Done!"