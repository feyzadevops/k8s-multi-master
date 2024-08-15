#!/bin/bash

K8S_VERSION="v1.29"                                     # latest major version
CALICO_VERSION="v3.28.0"    # check latest release version on this link => https://github.com/projectcalico/calico
POD_NETWORK_CIDR="10.10.0.0/16"
HOSTNAME="k8s-master-1"
## KEEPALIVED CONFIG FILE VARIABLES
export KEEPALIVED_VIP=10.80.20.11
export KEEPALIVED_DEST_PORT=6443
export KEEPALIVED_STATE=MASTER          # MASTER | BACKUP
export KEEPALIVED_PIORITY=100           # Less than 100 others
export KEEPALIVED_PEERS=""
export KEEPALIVED_SRC_IP=10.80.18.2             #LOCAL IP
export NETWORK_INTERFACE=ens18

convert_hosts () {
    # Belirtilen dosyayı oku
    while read -r line; do
        # Yorum satırlarını ve boş satırları atla
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue

        # IP adresini ve host ismini ayıkla
        ip=$(echo $line | awk '{print $1}')
        host=$(echo $line | awk '{print $2}')

        # Eğer IP ve host değeri varsa, istenilen formatı yazdır
        if [[ -n "$ip" && -n "$host" ]]; then
            echo -e "\t\tserver $host $ip:6443 check" >> /etc/haproxy/haproxy.cfg
        fi
    done < ./masternodes
}

echo "INFO: Hosts file is updated"
cat ./hosts > /etc/hosts

hostnamectl set-hostname $HOSTNAME

cat ./hosts | grep -i master > ./masternodes
export KEEPALIVED_PEERS=$(cat masternodes | cut -d ' ' -f 1 | grep -v "$KEEPALIVED_SRC_IP")

echo "INFO: Closing Swap and cleaning fstab file"
swapoff -a
sed -i '/\\swap*/s/^/#/' /etc/fstab

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

echo "INFO: keepalived is installing ..."
apt -y install keepalived
cat ./check_apiserver.sh > /etc/keepalived/check_apiserver.sh
sed -i -e "s/VIP_XXX/$KEEPALIVED_VIP/g" /etc/keepalived/check_apiserver.sh
sed -i -e "s/PORT_XXX/$KEEPALIVED_DEST_PORT/g" /etc/keepalived/check_apiserver.sh
chmod +x /etc/keepalived/check_apiserver.sh
cat ./keepalived.conf > /etc/keepalived/keepalived.conf
sed -i "s/KEEPALIVED_STATE/$KEEPALIVED_STATE/g" /etc/keepalived/keepalived.conf
sed -i "s/KEEPALIVED_PIORITY/$KEEPALIVED_PIORITY/g" /etc/keepalived/keepalived.conf
sed -i "s/KEEPALIVED_PEERS/$KEEPALIVED_PEERS/g" /etc/keepalived/keepalived.conf
sed -i "s/KEEPALIVED_SRC_IP/$KEEPALIVED_SRC_IP/g" /etc/keepalived/keepalived.conf
sed -i "s/KEEPALIVED_VIP/$KEEPALIVED_VIP/g" /etc/keepalived/keepalived.conf
sed -i "s/NETWORK_INTERFACE/$NETWORK_INTERFACE/g" /etc/keepalived/keepalived.conf
systemctl enable --now keepalived
ip a | grep $KEEPALIVED_VIP

echo "INFO: Haproxy installing ..."
apt -y install haproxy
cat ./
systemctl enable --now haproxy
cat ./haproxy.cfg > /etc/haproxy/haproxy.cfg
convert_hosts
sed -i "s/NETWORK_INTERFACE/$NETWORK_INTERFACE/g" /etc/haproxy/haproxy.cfg

echo "write 1 (iptables-legacy) and press enter"
update-alternatives --config iptables
