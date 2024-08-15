# k8s-multi-master

This setup has been tested on Ubuntu 20.04, Ubuntu 22.04, and Ubuntu 24.04. Before proceeding with the Kubernetes multi-master node installation, please ensure that your system is up-to-date and properly configured by executing the following commands:

## Initial Setup

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
Edit the /etc/security/limits.conf file:
   ```bash
   sudo nano /etc/security/limits.conf
Add the following lines:
   ```bash
   * soft nofile 65536
   * hard nofile 65536
   
