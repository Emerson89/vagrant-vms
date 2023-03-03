#!/usr/bin/env bash
#USER='vagrant'
#PASS='123'
#
#sudo usermod -p $(openssl passwd -1 ${PASS}) $USER
#sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
#sudo systemctl restart sshd

# Disable selinux
#setenforce 0
#sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

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
curl -fsSL https://get.docker.com | bash

sudo systemctl enable --now docker
systemctl status docker | grep "Active:"
sudo usermod -aG docker vagrant

# echo "Install rke..."
#echo
#wget https://github.com/rancher/rke/releases/download/v1.3.15/rke_linux-amd64
#sudo mv rke_linux-amd64 /usr/local/bin/rke
#rke up
sudo reboot

##export KUBECONFIG=./kube_config_cluster.yml
