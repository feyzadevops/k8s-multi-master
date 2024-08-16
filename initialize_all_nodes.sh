K8S_VERSION=v1.29
CALICO_VERSION=v3.28.0

swapoff -a
sed -i.bak '/swap.img/s/^/#/' /etc/fstab

ufw disable
systemctl stop ufw

update-alternatives --config iptables

echo "INFO: Some package and tools installing like kubeadm,kubelet,curl,gpg etc..."
apt-update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

apt update

systemctl enable kubelet

echo "1" > /proc/sys/net/ipv4/ip_forward

echo "You can run kubeadm init command like below:"
echo "sudo kubeadm init --control-plane-endpoint "vip-k8s:6443" --upload-certs --cri-socket /run/containerd/containerd.sock --pod-network-cidr=10.10.0.0/16"

kubeadm init --control-plane-endpoint "vip-k8s:6443" --upload-certs --cri-socket /run/containerd/containerd.sock --pod-network-cidr=10.10.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "INFO: Configuring kubectl and Calico $CALICO_VERSION"
curl https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/tigera-operator.yaml -O && kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/tigera-operator.yaml

echo "INFO: Installing and Configure custom resources"
curl https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/custom-resources.yaml -O
sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.10.0.0\/16/g' custom-resources.yaml
kubectl create -f custom-resources.yaml
echo "RUN FOR K8s JOIN COMMAND >> kubeadm token create --print-join-command"
