# soroban-k8s-infrastructure

This setup has been tested on Ubuntu 20.04, Ubuntu 22.04, and Ubuntu 24.04. Before proceeding with the Kubernetes multi-master node installation, please ensure that your system is up-to-date and properly configured by executing the following commands:

## Preparing the Ubuntu Operating System

1. **Update and Upgrade the System:**
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y

2. **Set the Timezone:**
    ```bash
    sudo timedatectl set-timezone ???/???

3. **Disable Uncomplicated Firewall (UFW):**
   ```bash
   sudo systemctl status ufw
   sudo systemctl stop ufw
   
4. **Configure Security Limits:**

    Edit the `/etc/security/limits.conf` file:
    ```bash
    sudo nano /etc/security/limits.conf
    ```
    Add the following lines:
    ```bash
    * soft nofile 65536
    * hard nofile 65536
    ```
   
5. **Check the Updated Limit:**
   ```bash
   ulimit -n

6. **Configure System Journal:**

   Edit the /etc/systemd/journald.conf file:
   ```bash
   sudo nano /etc/systemd/journald.conf
   ```
   Add or modify the following lines:
   ```bash
   Storage=persistent
   SystemMaxUse=10G
   RuntimeMaxUse=10G
   ```
7. **Restart System Journal Service::**
   ```bash
   sudo systemctl restart systemd-journald
   ```

## Kubernetes Installation

Files are downloaded to the same directory and edit the hosts file. In the setup-master-nodes.sh file, KEEPALIVED_VIP, KEEPALIVED_SRC_IP and NETWORK_INTERFACE are set according to their own server. After setting, the setup-master-nodes.sh script is run on the master nodes.
```bash
chmod +x setup-master-nodes.sh
./setup-master-nodes.sh
```

The initialize_all_nodes.sh script is run on the master nodes.
```bash
chmod +x initialize_all_nodes.sh
./initialize_all_nodes.sh
```

To prepare worker nodes, the setup-worker-nodes.sh script is run on the worker nodes.
```bash
chmod +x setup-worker-nodes.sh
./setup-worker-nodes.sh
```

