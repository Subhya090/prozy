# Use Ubuntu as the base image
FROM ubuntu:latest


# Install OpenVPN and Easy-RSA for generating keys
RUN apt update && apt install -y openvpn easy-rsa iproute2

RUN mkdir -p /dev/net && mknod /dev/net/tun c 10 200 && chmod 600 /dev/net/tun
# Create OpenVPN directory
RUN mkdir -p /etc/openvpn/easy-rsa

# Copy Easy-RSA scripts for key generation
RUN cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
WORKDIR /etc/openvpn/easy-rsa

# Initialize PKI & Generate Certificates
RUN ./easyrsa init-pki && \
    echo "set_var EASYRSA_BATCH 1" > vars && \
    ./easyrsa build-ca nopass && \
    ./easyrsa gen-req server nopass && \
    ./easyrsa sign-req server server && \
    ./easyrsa gen-dh && \
    cp pki/ca.crt /etc/openvpn/ && \
    cp pki/issued/server.crt /etc/openvpn/ && \
    cp pki/private/server.key /etc/openvpn/ && \
    cp pki/dh.pem /etc/openvpn/

# Generate OpenVPN Server Configuration
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

# Expose OpenVPN Port
EXPOSE 5859/tcp

# Start OpenVPN
CMD ["openvpn", "--config", "/etc/openvpn/server.conf", "--dev", "tun"]
