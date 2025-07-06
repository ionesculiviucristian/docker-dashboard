#!/bin/bash
set -eu

# Step 1: Install dnsmasq (a lightweight DNS forwarder)
if ! pacman -Qi dnsmasq &>/dev/null; then
    sudo pacman -Syu dnsmasq
fi

# Step 2: Disable systemd-resolved
# We need to turn this off because it conflicts with our dnsmasq setup
if systemctl is-enabled --quiet systemd-resolved; then
    sudo systemctl disable systemd-resolved
fi

# Step 3: Stop systemd-resolved if it's currently running
if systemctl is-active --quiet systemd-resolved; then
    sudo systemctl stop systemd-resolved
fi

# Step 4: Configure NetworkManager to not interfere with our DNS setup
# This prevents NetworkManager from automatically changing our DNS settings
if ! grep -q '^dns=none' "/etc/NetworkManager/NetworkManager.conf"; then
    sudo tee -a "/etc/NetworkManager/NetworkManager.conf" << EOF
[main]
dns=none
rc-manager=unmanaged
EOF
fi

# Restart NetworkManager to apply the changes
sudo systemctl restart NetworkManager

# Step 5: Remove the automatic DNS configuration file
# Modern Linux systems often have /etc/resolv.conf as a link to an auto-generated file
# We need to remove this link so we can create our own static file
if [ -L "/etc/resolv.conf" ]; then
    sudo rm -f "/etc/resolv.conf"
fi

# Step 6: Create our own DNS configuration
# Tell the system to use our local DNS server (dnsmasq) for all DNS lookups
if ! grep -q '^nameserver 127.0.0.1' "/etc/resolv.conf" 2>/dev/null; then
    sudo tee "/etc/resolv.conf" << EOF
nameserver 127.0.0.1
EOF
fi

# Step 7: Configure dnsmasq with our custom settings
# This is where we tell dnsmasq how to handle different types of DNS requests
if ! grep -q '^address=/.localdev/127.0.0.1' "/etc/dnsmasq.conf" 2>/dev/null; then
    sudo tee -a "/etc/dnsmasq.conf" << EOF
address=/.localdev/127.0.0.1
cache-size=1000
listen-address=127.0.0.1
no-hosts
no-resolv
server=127.0.0.1#5353
EOF
fi

# Step 8: Start our new DNS system
sudo systemctl restart dnsmasq
