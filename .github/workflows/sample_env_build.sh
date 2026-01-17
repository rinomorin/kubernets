#!/bin/bash

# ─── Domain and DNS ─────────────────────────────────────────────
export ipa_domain="example.local"
export cloud_zone="cloud.example.local"
export cloud_id="cloudsvc"
export dns_zone="api.example.local"
export ssh_key_path="/home/user/.ssh/id_rsa.pub"
export secops_edkey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFakeExampleKeyValueHere user@example.local'
export secops_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCFakeExampleRSAKeyValueHere user@example.local'

# ─── Account Identity ───────────────────────────────────────────
export account_name="ExampleCorp"

# Password policy
export passwd_max_age=45
export passwd_min_age=2
export passwd_warn_age=10

# ─── Admin Credentials ──────────────────────────────────────────
export admin_id="adminuser"
export admin_set="ExampleAdminPassword123!"
export admin_hash=$(echo -n "$admin_set" | openssl passwd -6 -stdin)

# ─── SecOps Credentials ─────────────────────────────────────────
export secops_id="secops"
export secops_pwd="ExampleSecOpsPwd456!"
export secops_hash=$(echo -n "$secops_pwd" | openssl passwd -6 -stdin)
export ssh_key_path="/home/secops/.ssh/id_rsa.pub"

# Fedora CoreOS ISO
export FCOS_ISO_URL="https://example.com/fcos/example.iso"
export FCOS_ISO_SIG="https://example.com/fcos/example.iso.sig"
export FCOS_ISO_SHA256="1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd"

# Helper node credentials
export helper_id="helper"
export helper_pwd="HelperPwd789!"
export helper_hash=$(echo -n "$helper_pwd" | openssl passwd -6 -stdin)

# ─── Optional Overrides ─────────────────────────────────────────
export temp_pwd="TempPwd123!"
export ipa_dm_password="DMPassword123!"
export ipa_admin_password="AdminPassword123!"

export ipa_dispatcher_enable_summary=true
export ipa_dispatcher_enable_promotion=true

# ISO file path
export iso_path="/var/lib/libvirt/images/ExampleOS-1.0-x86_64.iso"

# ─── Kubernetes Settings ────────────────────────────────────────
export kubetnet_version="1.30"
export crictl_version="1.30.0"
export default_netmask="255.255.255.0"
export default_net_device="eth0"
export cluster_ip_addr="10.10.0.20"
export cluster_netmask="255.255.255.0"
export cluster_gateway="10.10.0.1"
export cluster_net_device="eth1"
export nat_ip_device="172.20.0.20"
export nat_net_device="eth2"
export nat_mac_device="52:54:00:aa:bb:cc"
export ipa_master="ipa01.$ipa_domain"
export ipa_admin_principal="admin@EXAMPLE.LOCAL"
export ingress_id="ingress"
export ingress_ip="192.168.50.30"

# Virtual machine settings
export VM_MEM=4096
export VM_CPU=4
export VM_DISK_SIZE=50
export VM_HOST="kvmhost.example.local"
export VM_HOST_IP="192.168.50.10"
export VM_ISO="/var/lib/libvirt/images/ExampleOS-1.0-x86_64.iso"
export VG_NAME="vg_kvm"

# Helper working directory and key paths
export CLOUD_HELPER_USER="cloud_helper"
export CREATE_CLOUD_HELPER_ON_KVM=true
export HELPER_HOSTNAME="helper@$ipa_domain"
export HELPER_WORKDIR="/opt/$CLOUD_HELPER_USER"
export HELPER_BIN_DIR="$HELPER_WORKDIR/bin"
export HELPER_SSH_KEY_PATH="$HELPER_WORKDIR/id_rsa_cloud_helper"
export helper_ssh_pubkey_path="~/.ssh/id_rsa.pub"
export SSH_KEY_COMMENT="$CLOUD_HELPER_USER@$HELPER_HOSTNAME"
export INSTALL_COREOS_ON_HELPER=true
export HELPER_PACKAGES="jq,curl,qemu-img"
export KVM_PACKAGE="qemu-img,libvirt-client"
export KVM_HOST_GROUPS="libvirt,kvm"
export KVM_LIBVIRT_URI="qemu+ssh:///system"
export KVM_POOL_NAME="KVM_Pool"
export KVM_NETWORK_CLUSTER="br-cluster"
export KVM_NETWORK_NAT="br-nat"
export KVM_NETWORK_PROVIDER="default"
export ENABLE_POLKIT_LIBVIRT=false
export VIRSH_WRAPPER_NAME="virsh-remote"
export CREATE_CLOUD_HELPER_ON_KVM="true"
export CLOUD_HELPER_VENV="/opt/cloud_helper/venv"
export COREOS_IMAGE_URL="https://example.com/fcos/example-metal.raw.xz"
