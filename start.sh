#!/bin/sh

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Generate OpenVPN server config if not exists
if [ ! -f /etc/openvpn/server.conf ]; then
    cat <<EOF > /etc/openvpn/server.conf
port 443
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1"
push "dhcp-option DNS 1.1.1.1"
keepalive 10 120
tls-server
cipher AES-256-CBC
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 3
EOF
fi

# Start OpenVPN server
openvpn --config /etc/openvpn/server.conf
