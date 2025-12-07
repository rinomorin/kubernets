#!/bin/bash

# ─── Domain and DNS ─────────────────────────────────────────────
export ipa_domain="home.morinsoft.ca"
export dns_zone="api.home.morinsoft.ca"
export ssh_key_path="/home/secops/.ssh/id_rsa.pub"
export secops_edkey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHrv4WNtFzRbtS5TxvqTrhHbib5+C9Za6q+JcDi1pV6 rmorin@rl-10.morinsoft.ca'
export secops_key='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDY7mVnfYbrUphqCWkm0QxIwH3stJPi/Vqtt2ddDOwN5DhXQaRG+4IJQE3TOsYheoo/jYkS52nsYyXZWCZCNtXT4/htMAZlqAmOy/Bz5Lid31NIZoFRKN5GsxrzRU3jyRGnDLnjJifhrchTrSb1RNeb+FDWr4wpqTHDkZ5Zfh4OLkaLWJ0hqHWBE/H9t1AZ/VHvPj6i0fNfp+QM4uwg82dwS1a5GtjwrCxyEl37KRKdZsTZnByVG6zUlT6gOAVJ7y0dkhcL9zHi1NpnJPCO6EhhVNZpicHVEyVO+17GCfQfTb/EKjKo/7r6/CmTRvAHoen16dBs8iTfS0faSctC9YNZg65xt2e2PQRfodCtmYZdVsqYtsyvjbKM2qdNiTKQGhlfl8dgGh/N4xsh7vadkPznFLmluFJlWukEWw+9FnnAi69xaCbOq9uz6+JhY+4a16C//NbnEVzTTyK8l3MbxedeZ7FNaHlfYiPfj4ZogbOaoNYARF24eDzavEucHKcsyFylAPU/aV0C+XfDsZiHnfFf1o2hkPaDJUd+37Qyu8vBojcaACFIE4JbTe7vI36A4hWuJrckRKbY8NRIbWhpzlnc7yM3+YzI8SjjrFTH4vFPVnVrDrSPrd6zFE6KMaFu4XZxDSj6CxURPY9Eo4Rnw6GRTMH14clYKLKa4ZYwTLgcUQ== rmorin@rl-10.morinsoft.ca'
# ─── Account Identity ───────────────────────────  ────────────────
export account_name="MorinSoft"

# ─── Admin Credentials ──────────────────────────────────────────
export admin_id="sysadmin"
export admin_set="On32Build4SysAdmin"
export admin_hash=$(echo -n "$admin_set" | openssl passwd -6 -stdin)

# ───    SecOps Credentials ─────────────────────────────────────────
export secops_id="secops"
export secops_pwd="On32Secure4Sec0ps~"
export secops_hash=$(echo -n "$secops_pwd" | openssl passwd -6 -stdin)
export ssh_key_path="/home/secops/.ssh/id_rsa.pub"

# ─── Optional Overrides ─────────────────────────────────────────
export temp_pwd="IJustW@nt1nToo~"
export ipa_dm_password="On32dr1v3H0me~"
export ipa_admin_password="On32L00kUpToo~"

export ipa_dispatcher_enable_summary=true
export ipa_dispatcher_enable_promotion=tr

# iso file path
export iso_path="/var/lib/libvirt/images/Rocky-9.6-x86_64-boot.iso"

# ─── Kubernetes Settings ────────────────────────────────────────
export kubetnet_version="1.34"
export default_netmask="255.255.255.0"
export default_net_device="ens1s0"
export cluster_ip_addr="10.0.0.20"
export cluster_netmask="255.255.255.0"
export cluster_gateway="10.0.0.1"
export cluster_net_device="ens2s0"
export nat_net_device="ens3s0"
export ipa_master="ipa01.$ipa_domain"

# export kubeadm_cluster_name="home.morinsoft"
# export kubeadm_pod_network_cidr="10.244.0.0/16"
