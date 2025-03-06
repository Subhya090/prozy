# Use Ubuntu as the base image
FROM ubuntu:latest

# Install OpenVPN and Easy-RSA for generating keys
RUN apt update && apt install -y openvpn easy-rsa iproute2

# Create OpenVPN directory
RUN mkdir -p /etc/openvpn/easy-rsa

# Copy Easy-RSA scripts for key generation
RUN cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
WORKDIR /etc/openvpn/easy-rsa

# Initialize PKI (Public Key Infrastructure) & Generate Certificates
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

# Expose OpenVPN port
EXPOSE 443/tcp

# Start OpenVPN
CMD ["openvpn", "--config", "/etc/openvpn/server.conf"]
