#!/bin/bash
set -e

# Set defaults
TFTP_DIRECTORY="${TFTP_DIRECTORY:-/tftp}"
TFTP_USERNAME="${TFTP_USERNAME:-tftp}"
TFTP_BLOCKSIZE="${TFTP_BLOCKSIZE:-1468}"
TFTP_OPTIONS="${TFTP_OPTIONS:---secure}"

# Build tftpd command
TFTPD_ARGS=()
TFTPD_ARGS+=("--foreground")
TFTPD_ARGS+=("--user" "${TFTP_USERNAME}")
TFTPD_ARGS+=("--blocksize" "${TFTP_BLOCKSIZE}")
TFTPD_ARGS+=("--address" "0.0.0.0:69")

# Add custom options
if [ -n "${TFTP_OPTIONS}" ]; then
    read -ra OPTS <<< "${TFTP_OPTIONS}"
    TFTPD_ARGS+=("${OPTS[@]}")
fi

# Add directory last
TFTPD_ARGS+=("${TFTP_DIRECTORY}")

# Ensure tftp directory exists and has correct permissions
mkdir -p "${TFTP_DIRECTORY}"
chown -R "${TFTP_USERNAME}:${TFTP_USERNAME}" "${TFTP_DIRECTORY}"

# Log configuration
echo "Starting tftpd-hpa with configuration:"
echo "  Directory: ${TFTP_DIRECTORY}"
echo "  Username: ${TFTP_USERNAME}"
echo "  Block size: ${TFTP_BLOCKSIZE}"
echo "  Options: ${TFTP_OPTIONS}"
echo ""
echo "Full command: in.tftpd ${TFTPD_ARGS[*]}"
echo ""

# Start tftpd
exec in.tftpd "${TFTPD_ARGS[@]}"
