# Use Ubuntu as the base image
FROM ubuntu:latest

# Install OpenVPN and dependencies
RUN apt update && apt install -y openvpn easy-rsa iproute2

# Enable IP forwarding
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p

# Create OpenVPN directory
RUN mkdir -p /etc/openvpn

# Generate OpenVPN server config
RUN echo " \
port 5859\n\
proto tcp\n\
dev tun\n\
ca /etc/openvpn/ca.crt\n\
cert /etc/openvpn/server.crt\n\
key /etc/openvpn/server.key\n\
dh /etc/openvpn/dh.pem\n\
server 10.8.0.0 255.255.255.0\n\
push \"redirect-gateway def1\"\n\
push \"dhcp-option DNS 1.1.1.1\"\n\
keepalive 10 120\n\
tls-server\n\
cipher AES-256-CBC\n\
persist-key\n\
persist-tun\n\
status /var/log/openvpn-status.log\n\
verb 3\n\
" > /etc/openvpn/server.conf

# Expose OpenVPN over TCP
EXPOSE 5859/tcp

# Run OpenVPN in the foreground
CMD ["openvpn", "--config", "/etc/openvpn/server.conf"]
