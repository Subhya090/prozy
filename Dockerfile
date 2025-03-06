# Use Ubuntu as the base image
FROM ubuntu:latest

# Install SSH Server
RUN apt update && apt install -y openssh-server

# Create SSH directory and allow root login
RUN mkdir /var/run/sshd && \
    echo "root:sam" | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expose SSH (22) + 5 Random Ports
EXPOSE 22 3000 4000 5000 6000 7000

# Start SSH service in foreground
CMD ["/usr/sbin/sshd", "-D"]
