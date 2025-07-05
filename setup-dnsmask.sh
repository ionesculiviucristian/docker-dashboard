#!/bin/bash
set -eu 

# Install local DNS forwarder and DHCP server
if ! pacman -Qi dnsmasq &>/dev/null; then
  sudo pacman -Syu dnsmasq
fi

# Disable local DNS stub resolver
if systemctl is-enabled --quiet systemd-resolved; then
  sudo systemctl disable systemd-resolved
fi

# Stop local DNS stub resolver
if systemctl is-active --quiet systemd-resolved; then
  sudo systemctl stop systemd-resolved
fi

# Do not manage DNS
# Do not manage /etc/resolv.conf or other resolver configuration files
if ! grep -q '^dns=none' "/etc/NetworkManager/NetworkManager.conf"; then
sudo tee -a "/etc/NetworkManager/NetworkManager.conf" << EOF
[main]
dns=none
rc-manager=unmanaged
EOF
fi

sudo systemctl restart NetworkManager

# Remove systemd-resolved symlink
if [ -L "/etc/resolv.conf" ]; then
  sudo rm -f "/etc/resolv.conf"
fi

# Query local DNS server (on 127.0.0.1) for DNS resolution with Cloudflare fallback
if ! grep -q '^nameserver 127.0.0.1' "/etc/resolv.conf" 2>/dev/null; then
sudo tee "/etc/resolv.conf" << EOF
nameserver 127.0.0.1
nameserver 1.1.1.1
EOF
fi

# Resolve any DNS query ending with .localdev
# Serve DNS requests only on the loopback interface
if ! grep -q '^address=/.localdev/127.0.0.1' "/etc/dnsmasq.conf" 2>/dev/null; then
sudo tee -a "/etc/dnsmasq.conf" << EOF
address=/.localdev/127.0.0.1
listen-address=127.0.0.1
EOF
fi

sudo systemctl restart dnsmasq

exit 0
