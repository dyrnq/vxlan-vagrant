#!/usr/bin/env bash
set -eux;

ip4=$(/sbin/ip -o -4 addr list enp0s8 | awk '{print $4}' | cut -d/ -f1 | head -n1);

iptables -t filter -A FORWARD -s 10.244.0.0/16 -j ACCEPT
iptables -t filter -A FORWARD -d 10.244.0.0/16 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.244.0.0/16 -d 10.244.0.0/16 -j RETURN
iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 224.0.0.0/4 -j MASQUERADE --random-fully
iptables -t nat -A POSTROUTING ! -s 10.244.0.0/16 -d 10.244.0.0/24 -j RETURN
iptables -t nat -A POSTROUTING ! -s 10.244.0.0/16 -d 10.244.0.0/16 -j MASQUERADE --random-fully


ip link add cni0 type bridge
ip link set dev cni0 mtu 1450

ip link add veth0 type veth peer name veth1
ip link set dev veth0 mtu 1450
# brctl addif cni0 veth0
ip link set dev veth0 master cni0
ip link add vxlan-10 type vxlan id 10 local "$ip4" dev enp0s8 dstport 8472 nolearning
ip link set dev vxlan-10 address 00:4b:d6:7b:d5:8d

ip link set dev veth0 up
ip link set dev cni0 up
ip link set dev vxlan-10 up
ip addr add 10.244.0.1/24 broadcast 10.244.0.255 dev cni0
ip addr add 10.244.0.0/32 dev vxlan-10
ip netns add ns1
ip link set veth1 netns ns1
ip netns exec ns1 ip link set dev veth1 mtu 1450
ip netns exec ns1 ip link set dev veth1 address 00:8e:6a:c9:a3:0b
ip netns exec ns1 ip link set dev veth1 up
ip netns exec ns1 ip link set dev lo up
ip netns exec ns1 ip addr add 10.244.0.2/24 dev veth1
ip netns exec ns1 ip route add default via 10.244.0.1

ip route add 10.244.2.0/24 dev vxlan-10 via 10.244.2.0 onlink
ip route add 10.244.1.0/24 dev vxlan-10 via 10.244.1.0 onlink

arp -s 10.244.2.0 22:a3:cf:13:ec:4a -i vxlan-10
arp -s 10.244.1.0 2a:7b:50:26:9c:b8 -i vxlan-10

bridge fdb append 00:00:00:00:00:00 dev vxlan-10 dst 192.168.28.12
bridge fdb append 7e:88:8f:bf:bf:73 dev vxlan-10 dst 192.168.28.12

bridge fdb append 00:00:00:00:00:00 dev vxlan-10 dst 192.168.28.11
bridge fdb append b2:cd:05:e0:67:ea dev vxlan-10 dst 192.168.28.11