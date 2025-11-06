#!/bin/bash

# ─── Domain and DNS ─────────────────────────────────────────────
export ipa_domain="morinsoft.ca"
export dns_zone="api.morinsoft.ca"

# ─── Account Identity ───────────────────────────────────────────
export account_name="MorinSoft"

# ─── Admin Credentials ──────────────────────────────────────────
export admin_id="sysadmin"
export admin_set="On32Build4SysAdmin"

# ─── SecOps Credentials ─────────────────────────────────────────
export secops_id="secops"
export secops_pwd="On32Secure4Sec0ps~"

# ─── Optional Overrides ─────────────────────────────────────────
export temp_pwd="IJustW@nt1nToo~"
export ipa_dm_password="On32dr1v3H0me~"
export ipa_admin_password="On32L00kUpToo~"

export ipa_dispatcher_enable_summary=true
export ipa_dispatcher_enable_promotion=true

export kubeadm_cluster_name="morinsoft"
export kubeadm_pod_network_cidr="10.244.0.0/16"
export kubeadm_crio_version="1.34"

