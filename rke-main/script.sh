#!/bin/bash

echo -e "\033[42;1;30mDisable SWAP...\033[0m"
sudo swapoff -a
sudo sed -i.bak '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo
echo -e "\033[42;1;30mInstall docker\033[0m"
sudo apt update
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker $USER
echo
echo -e "\033[42;1;30mSet config Network\033[0m"
sudo echo -e "overlay\nbr_netfilter" > /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter
sudo echo -e "net.bridge.bridge-nf-call-ip6tables = 1\nnet.bridge.bridge-nf-call-iptables = 1\nnet.ipv4.ip_forward = 1" > /etc/sysctl.d/kubernetes.conf
sudo sysctl --system
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
echo
echo -e "\033[42;1;30mInstall k8s\033[0m"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt install -y kubelet kubeadm kubectl
sudo kubeadm init --control-plane-endpoint=`hostname --all-ip-addresses | awk '{print $2}'`
sleep 3
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
echo -e "\033[42;1;30mInstall ingress\033[0m"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.4.0/deploy/static/provider/cloud/deploy.yaml
echo -e "\033[42;1;30mInstall dashboard k8s\033[0m"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
kubectl taint node $HOSTNAME node-role.kubernetes.io/control-plane:NoSchedule-
#kubectl create -f admin.yaml
#kubectl -n kubernetes-dashboard create token admin-user > $HOME/token
echo "Finalizado"