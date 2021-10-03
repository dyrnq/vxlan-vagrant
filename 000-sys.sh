#!/usr/bin/env bash
sed -i "s@http://.*archive.ubuntu.com@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list && \
sed -i "s@http://.*security.ubuntu.com@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list;

echo "root:vagrant" | sudo chpasswd
timedatectl set-timezone "Asia/Shanghai"

# avoid installation failures,especially for poor networks
until brctl --version 2&> /dev/null; do
    DEBIAN_FRONTEND=noninteractive apt-get update
    # DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
    DEBIAN_FRONTEND=noninteractive apt-get install -y wget bridge-utils net-tools jq tar curl git unzip lsb-release gnupg ca-certificates conntrack traceroute
done



cat > /etc/sysctl.d/10-sysctl.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF
sysctl --system

cat > /etc/modules-load.d/90-net.conf << EOF
br_netfilter
EOF
modprobe br_netfilter