#!/bin/bash
# ------------------------------------------------------------------------
# K8S LAB ENVIRONMENT GENERATOR (SAMPLE)
# ------------------------------------------------------------------------

# --- Cluster Security ---
TOKEN_PART1=$(openssl rand -hex 3)
TOKEN_PART2=$(openssl rand -hex 8)
export K8S_CLUSTER_TOKEN="${TOKEN_PART1}.${TOKEN_PART2}"

# --- Domain & DNS ---
export ipa_domain="example.com"
export cloud_zone="cloud.example.com"
export VM_HOST_IP="192.168.1.10" # Your KVM Host
export ipa_admin_password="REPLACE_ME_WITH_SECURE_PWD"

# --- Identity & SSH ---
# Provide the RAW string of your public key here for Kickstart injection
export secops_key='ssh-rsa AAAA... user@host'
export helper_ssh_pubkey_path="~/.ssh/id_rsa.pub"

# --- OS & Software Versions ---
export iso_path="/var/lib/libvirt/images/Rocky-9-latest-x86_64-dvd.iso"
export kubetnet_version="1.34"
export crictl_version="1.34.0"

# --- Resource Defaults ---
export VM_MEM=4096
export VM_CPU=2
export VM_DISK_SIZE=50

echo "Environment Sample Loaded. Run 'ansible-playbook' in this session."