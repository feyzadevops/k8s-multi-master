#!/bin/bash

K8S_VERSION="v1.29"                                     
CALICO_VERSION="v3.28.0"
POD_NETWORK_CIDR="10.10.0.0/16"
HOSTNAME="k8s-master-1"

echo "INFO: Hosts file is updated"
cat ./hosts > /etc/hosts

hostnamectl set-hostname $HOSTNAME

echo "INFO: Closing Swap and cleaning fstab file"
swapoff -a
sed -i.bak '/swap.img/s/^/#/' /etc/fstab

echo "INFO: overlay and br_netfilter modules are activeting and configurating containerd ..."
modprobe overlay
modprobe br_netfilter
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

echo "INFO: system updating.."
apt-get update

echo "INFO: Containerd installing and configurating ..."
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

update-alternatives --config iptables

ufw disable
systemctl stop ufw
