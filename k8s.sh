#!/bin/bash
yum install epel-release -y
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
setenforce 0
swapoff -a
hostnamectl set-hostname master-k8s
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
tee /etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install kubeadm -y
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
systemctl restart docker && systemctl enable docker
systemctl  restart kubelet && systemctl enable kubelet
tee /etc/docker/daemon.json<<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
systemctl restart docker
kubeadm init --apiserver-advertise-address=192.168.33.10
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64| tr -d '\n')"
kubectl get nodes
sleep 20
kubectl get pods --all-namespaces

#senha rancher - OFFexwqUlMDIhgmC