# syntax=docker/dockerfile:1
FROM debian:trixie-slim

# Install tftpd-hpa and pxelinux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tftpd-hpa \
        pxelinux \
        syslinux-common && \
    rm -rf /var/lib/apt/lists/*

# Create tftp directory
RUN mkdir -p /tftp && \
    chmod 755 /tftp

# Copy pxelinux files to tftp root
RUN cp /usr/lib/PXELINUX/pxelinux.0 /tftp/ && \
    cp /usr/lib/syslinux/modules/bios/*.c32 /tftp/ && \
    mkdir -p /tftp/pxelinux.cfg

# Create tftp user
RUN useradd -r -s /usr/sbin/nologin tftp && \
    chown -R tftp:tftp /tftp

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose TFTP port
EXPOSE 69/udp

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
