#!/usr/bin/env bash
# gen_kick.sh - Generate IPA Kickstart file from environment parameters
# Usage:
#   export ip_addr=192.168.100.10
#   export ip_mask=255.255.255.0
#   export ip_gate=192.168.100.1
#   export dns_01=192.168.100.1
#   export dns_02=8.8.8.8
#   export ipa_host=ipa01.morinsoft.ca
#   export vg_name=dnsvg
#   export vg_short=dns
#   export pwd_var=On32Build4Cl0udT3st01
#   ./gen_kick.sh ipa.ks

set -euo pipefail

OUTFILE="${1:-ipa.ks}"

# --- Required parameters ---
: "${ip_addr:?ip_addr required}"
: "${ip_mask:?ip_mask required}"
: "${ip_gate:?ip_gate required}"
: "${dns_01:?dns_01 required}"
: "${dns_02:?dns_02 required}"
: "${ipa_host:?ipa_host required}"
: "${vg_name:?vg_name required}"
: "${vg_short:?vg_short required}"
: "${pwd_var:?pwd_var required}"

# --- Generate hashed password ---
pwd_hash=$(openssl passwd -6 "$pwd_var" | tr -d "\n")

cat > "$OUTFILE" <<EOF
#version=RHEL9
url --mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=BaseOS-9.6
repo --name=AppStream --mirrorlist=https://mirrors.rockylinux.org/mirrorlist?arch=x86_64&repo=AppStream-9.6

lang en_CA.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone UTC,UTC

network --bootproto=static --ip=${ip_addr} --netmask=${ip_mask} --gateway=${ip_gate} --nameserver=${dns_01},${dns_02} --hostname=${ipa_host}
timesource --ntp-server=pool.ntp.org

selinux --enforcing
firewall --enabled --service=ssh

ignoredisk --only-use=sda
clearpart --all --initlabel
bootloader --location=mbr --boot-drive=sda

part /boot --fstype="xfs" --ondisk=sda --size=1024
part /boot/efi --fstype="efi" --ondisk=sda --size=300 --fsoptions="umask=0077,shortname=winnt"
part pv.${vg_short} --fstype="lvmpv" --ondisk=sda --size=48128
volgroup ${vg_name} pv.${vg_short}

%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%addon com_redhat_oscap
    content-type = scap-security-guide
    datastream-id = scap_org.open-scap_datastream_from_xccdf_ssg-rhel9-xccdf.xml
    xccdf-id = scap_org.open-scap_cref_ssg-rhel9-xccdf.xml
    profile = xccdf_org.ssgproject.content_profile_cis
%end

logvol /tmp                 --fstype="xfs" --size=1024   --name=tmplv      --vgname=${vg_name} --fsoptions="nodev,nosuid,noexec"
logvol /var                 --fstype="xfs" --size=2048   --name=varlv      --vgname=${vg_name}
logvol /var/log             --fstype="xfs" --size=2048   --name=varloglv   --vgname=${vg_name}
logvol /var/log/audit       --fstype="xfs" --size=2048   --name=auditlv    --vgname=${vg_name}
logvol /var/tmp             --fstype="xfs" --size=1024   --name=vartmplv   --vgname=${vg_name} --fsoptions="nodev,nosuid,noexec"
logvol /dev/shm             --fstype="xfs" --size=1024   --name=shmlv      --vgname=${vg_name} --fsoptions="nodev,nosuid,noexec"
logvol /home                --fstype="xfs" --size=1024   --name=homelv     --vgname=${vg_name}
logvol /                    --fstype="xfs" --size=6144   --name=rootlv     --vgname=${vg_name}
logvol swap                 --fstype="swap" --size=2048   --name=swap       --vgname=${vg_name}

rootpw --iscrypted ${pwd_hash}
user --name=sysadmin --password=${pwd_hash} --iscrypted --gecos="System Admin" --groups=wheel
user --name=secops --password=On32Secure4Sec0ps~ --gecos="automation id" --groups=wheel

%packages
--ignoremissing
@^minimal-environment
@standard
@headless-management
openscap-scanner
scap-security-guide
aide
audit
libpwquality
policycoreutils
policycoreutils-python-utils
gnupg2
lvm2
iscsi-initiator-utils
chrony
openssl
sssd
rsyslog
logrotate
gnutls-utils
%end

%post --interpreter=/bin/bash --log=/root/kickstart-post.log
update-crypto-policies --set FIPS

groupadd sshok
usermod -aG sshok sysadmin
usermod -aG sshok secops
echo "sysadmin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "secops ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

cat > /etc/chrony.conf <<CHRONY
server 0.ca.pool.ntp.org iburst
server 1.ca.pool.ntp.org iburst
server 2.ca.pool.ntp.org iburst
server 3.ca.pool.ntp.org iburst
allow 192.168.100.0/24
local stratum 10
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
CHRONY
systemctl enable chronyd
systemctl restart chronyd

echo "${ip_addr} ${ipa_host} ${ipa_host%%.*}" >> /etc/hosts

systemctl enable named-pkcs11
systemctl restart named-pkcs11

update-crypto-policies --set FIPS

echo "sysadmin:${pwd_var}" | chpasswd
echo "secops:${pwd_var}~" | chpasswd

sleep 2
echo "Installation complete. System will power off."
%end
shutdown
EOF

echo "Kickstart file generated at $OUTFILE"
