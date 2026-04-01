#!/bin/bash
# ------------------------------------------------------------------------
# ACME K8S LAB - GENERIC BUILD ENVIRONMENT TEMPLATE
# ------------------------------------------------------------------------

# 1. Generate Kubeadm Token (Automated)
TOKEN_PART1=$(openssl rand -hex 3)
TOKEN_PART2=$(openssl rand -hex 8)
export K8S_CLUSTER_TOKEN="${TOKEN_PART1}.${TOKEN_PART2}"
echo "Generated K8s Token: $K8S_CLUSTER_TOKEN"

# 2. Domain and DNS Hierarchy
export ACCOUNT="AcmeCorp"
export ipa_domain="lab.example.com"
export cloud_zone="cloud.lab.example.com"
export cloud_provision="provision.lab.example.com"
export dns_zone="api.lab.example.com"
export ipa_master="idm01.$ipa_domain"
export ipa_admin_principal="admin@LAB.EXAMPLE.COM"
export metallb_vip="10.0.0.200"


# 3. Credentials & Hashes (Replace these with your actual secure values)
export admin_set="ReplaceWithSecurePass1"
export admin_hash=$(echo -n "$admin_set" | openssl passwd -6 -stdin)
export secops_pwd="ReplaceWithSecurePass2"
export secops_hash=$(echo -n "$secops_pwd" | openssl passwd -6 -stdin)
export ipa_admin_password="ReplaceWithSecurePass3"
export ipa_dm_password="ReplaceWithSecurePass4"

# 4. SSH Key Management (Placeholders for Golden Image Injection)
# Update these paths to match your local helper environment
export ssh_key_path="$HOME/.ssh/id_rsa.pub"
export helper_ssh_pubkey_path="~/.ssh/id_rsa.pub"

# Replace the strings below with your actual public keys
export secops_key='ssh-rsa AAAAB3...[REDACTED]... user@workstation'
export core_ssh_key='ssh-rsa AAAAB3...[REDACTED]... ansible@helper'
export secops_edkey='ssh-ed25519 AAAAC3...[REDACTED]... user@workstation'

# 5. KVM & Virtualization Settings
export OS_VERSION="9.x"
export VM_HOST_IP="192.168.1.10"
export VM_HOST="kvm-host.lab.example.com"
export iso_path="/var/lib/libvirt/images/Rocky-9-latest-x86_64-dvd.iso"
export VM_MEM=4096
export VM_CPU=4
export VM_DISK_SIZE=50
export VG_NAME="vg_guest"

# 6. Networking & VIPs
export ingress_ip="192.168.1.30"
export nat_mac_device="52:54:00:xx:xx:xx"
export default_netmask="255.255.255.0"
export cluster_gateway="10.0.0.1"

# 7. Kubernetes Software Versions
export kubetnet_version="1.34"
export crio_version="1.34"

# 8. Build Meta & Automation
export golden_image_name="el9-golden-base"
export build_loops=120

echo "-------------------------------------------------------"
echo " Generic Lab Environment Loaded Successfully "
echo " Target KVM: $VM_HOST ($VM_HOST_IP) "
echo " Domain: $ipa_domain "
echo "-------------------------------------------------------"