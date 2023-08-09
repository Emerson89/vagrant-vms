#!/usr/bin/env bash

# Disable swap
swapoff -a
sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Starting Instalation of Docker"

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "Install Docker..."
echo

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update  

sudo apt-get install docker-ce=5:20.10.13~3-0~ubuntu-focal docker-ce-cli=5:20.10.13~3-0~ubuntu-focal containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo systemctl enable --now docker
systemctl status docker | grep "Active:"
sudo usermod -aG docker vagrant

sudo reboot

#List the available versions:
#apt-cache madison docker-ce | awk '{ print $3 }'

##export KUBECONFIG=./kube_config_cluster.yml
