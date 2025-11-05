# syntax=docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6
FROM debian:trixie-slim@sha256:a347fd7510ee31a84387619a492ad6c8eb0af2f2682b916ff3e643eb076f925a

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
