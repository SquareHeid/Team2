#!/bin/bash
# common + master-setup.sh

# Change hostname
sudo hostnamectl set-hostname ansible-master

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install dependencies
sudo apt-get install -y curl software-properties-common openssh-server 

# Install Ansible on the master node
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install -y ansible

echo "Ansible install completed"

# Ensure /home/ubuntu/playbook directory exists
if [ ! -d /home/ubuntu/playbook ]; then
    sudo mkdir -p /home/ubuntu/playbook
    sudo chown -R ubuntu:ubuntu /home/ubuntu/playbook
fi

echo "Ansible setup complete."