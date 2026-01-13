#!/usr/bin/bash
set -euo pipefail
echo "starting">> /root/set_ip.tt
CONFIG="/var/lib/firstboot/netconfig.json"

# Read hostname
echo "set hostname">> /root/set_ip.tt
HOSTNAME=$(jq -r '.hostname' "$CONFIG")
hostnamectl set-hostname "$HOSTNAME"

# Loop through MAC → IP mappings
echo "read json">> /root/set_ip.tt
jq -r '.interfaces | to_entries[] | "\(.key) \(.value)"' "$CONFIG" | while read -r MAC IP; do
    IFACE=$(ip -o link | awk -v mac="$MAC" '$0 ~ mac {print $2}' | sed 's/://')
    [ -z "$IFACE" ] && continue

echo "updateip">> /root/set_ip.tt

cat >/etc/NetworkManager/system-connections/${IFACE}.nmconnection <<EOF
[connection]
id=${IFACE}
type=ethernet
interface-name=${IFACE}
autoconnect=true

[ipv4]
address1=${IP}/24
method=manual

[ipv6]
method=ignore
EOF

    chmod 600 /etc/NetworkManager/system-connections/${IFACE}.nmconnection
done

echo "restart service">> /root/set_ip.tt

systemctl restart NetworkManager

echo "end">> /root/set_ip.tt
