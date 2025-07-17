#!/bin/bash

# 安装 Packer
# https://developer.hashicorp.com/packer/tutorials/docker-get-started/get-started-install-cli
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install packer

# 安装 Make
sudo apt install -y make

# 安装其他依赖
# https://maas.io/docs/how-to-build-custom-images
sudo apt install -y libnbd-bin nbdkit fuse2fs qemu-utils qemu-system ovmf cloud-image-utils
