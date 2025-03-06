FROM ubuntu:latest

# Install OpenVPN and dependencies
RUN apt update && apt install -y openvpn easy-rsa iproute2

# Create necessary directories
RUN mkdir -p /etc/openvpn

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose OpenVPN over TCP
EXPOSE 443/tcp

CMD ["/start.sh"]
