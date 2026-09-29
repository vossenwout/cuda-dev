#!/usr/bin/env bash
# Run as root on the Ubuntu/Debian VM. Requires Docker and NVIDIA drivers.
# Restarts Docker and any services requiring restart without prompting.
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
    echo "Run as root: sudo bash $0" >&2
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

apt-get update
apt-get install -y -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" ca-certificates curl gnupg

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | gpg --batch --yes --dearmor \
        -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    > /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt-get update
apt-get install -y -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold" nvidia-container-toolkit

nvidia-ctk runtime configure --runtime=docker
systemctl restart docker
