#!/bin/bash
set -e

# Set defaults
TFTP_DIRECTORY="${TFTP_DIRECTORY:-/tftp}"
TFTP_USERNAME="${TFTP_USERNAME:-tftp}"

# Build tftpd command
TFTPD_ARGS=()

# If TFTP_ARGS is set, use it to replace all default arguments
if [ -n "${TFTP_ARGS}" ]; then
    read -ra TFTPD_ARGS <<< "${TFTP_ARGS}"
else
    # Default arguments
    TFTPD_ARGS+=("--foreground")
    TFTPD_ARGS+=("--user" "${TFTP_USERNAME}")
    TFTPD_ARGS+=("--address" "0.0.0.0:69")
    TFTPD_ARGS+=("--port-range" "69:69")
    TFTPD_ARGS+=("--secure")

    # Add additional options if specified
    if [ -n "${TFTP_OPTIONS}" ]; then
        read -ra OPTS <<< "${TFTP_OPTIONS}"
        TFTPD_ARGS+=("${OPTS[@]}")
    fi

    # Add directory last
    TFTPD_ARGS+=("${TFTP_DIRECTORY}")
fi

# Ensure tftp directory exists and has correct permissions
mkdir -p "${TFTP_DIRECTORY}"
chown -R "${TFTP_USERNAME}:${TFTP_USERNAME}" "${TFTP_DIRECTORY}"

# Log configuration
echo "Starting tftpd-hpa with configuration:"
echo "  Directory: ${TFTP_DIRECTORY}"
echo "  Username: ${TFTP_USERNAME}"
echo ""
echo "Full command: in.tftpd ${TFTPD_ARGS[*]}"
echo ""

# Start tftpd
exec in.tftpd "${TFTPD_ARGS[@]}"
