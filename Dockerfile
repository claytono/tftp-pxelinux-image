# syntax=docker/dockerfile:1
FROM debian:trixie-slim

# Install tftpd-hpa and pxelinux
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tftpd-hpa \
        pxelinux \
        syslinux-common \
        procps && \
    rm -rf /var/lib/apt/lists/*

# Create tftp directory
RUN mkdir -p /tftp && \
    chmod 755 /tftp

# Hard link pxelinux files to tftp root
RUN ln /usr/lib/PXELINUX/pxelinux.0 /tftp/ && \
    ln /usr/lib/syslinux/modules/bios/*.c32 /tftp/ && \
    mkdir -p /tftp/pxelinux.cfg

# Set permissions for tftp user (created by tftpd-hpa package)
RUN chown -R tftp:tftp /tftp

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose TFTP port
EXPOSE 69/udp

# Health check - verify tftpd process is running
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep -x in.tftpd > /dev/null || exit 1

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
