# tftpd-hpa Docker Image

Multi-architecture Docker image for tftpd-hpa with PXELinux pre-installed.

## Features

- Minimal image size based on Debian slim
- Multi-architecture support (AMD64 and ARM64)
- PXELinux files pre-installed at TFTP root
- Configurable via environment variables
- Automatic updates via Renovate when base image changes
- Includes syslinux modules for PXE boot

## Quick Start

```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/tftp \
  ghcr.io/claytono/tftp-pxelinux-image:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TFTP_DIRECTORY` | `/tftp` | Root directory for TFTP files |
| `TFTP_USERNAME` | `tftp` | Username for the TFTP daemon |
| `TFTP_OPTIONS` | | Additional tftpd-hpa options to append to defaults |
| `TFTP_ARGS` | | Complete tftpd arguments (replaces all defaults) |

### Default Arguments

By default, tftpd is started with:
- `--foreground` - Run in foreground
- `--user tftp` - Run as tftp user
- `--address 0.0.0.0:69` - Listen on all interfaces
- `--port-range 69:69` - Use port 69 only
- `--secure` - Change root directory on startup

Use `TFTP_OPTIONS` to add additional options to the defaults, or `TFTP_ARGS` to completely replace all arguments. See the [tftpd(8) man page](https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html) for all available options.

### Examples

**Enable file creation with verbose logging:**
```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/tftp \
  -e TFTP_OPTIONS="--create --verbosity 4" \
  ghcr.io/claytono/tftp-pxelinux-image:latest
```

**Custom directory and block size:**
```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/data \
  -e TFTP_DIRECTORY=/data \
  -e TFTP_OPTIONS="--blocksize 8192" \
  ghcr.io/claytono/tftp-pxelinux-image:latest
```

**Completely custom arguments:**
```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/tftp \
  -e TFTP_ARGS="--foreground --user tftp --address 0.0.0.0:69 --create --verbosity 4 /tftp" \
  ghcr.io/claytono/tftp-pxelinux-image:latest
```

## Docker Compose

See [docker-compose.yml](docker-compose.yml) for a complete example.

```yaml
services:
  tftp:
    image: ghcr.io/claytono/tftp-pxelinux-image:latest
    container_name: tftp
    restart: unless-stopped
    ports:
      - "69:69/udp"
    volumes:
      - ./tftp:/tftp
    environment:
      TFTP_OPTIONS: "--create --verbosity 2"
```

## PXE Boot Setup

The image includes PXELinux and syslinux modules at `/tftp`. To set up PXE boot:

1. Create a `pxelinux.cfg/default` configuration file in your TFTP directory:

```
DEFAULT menu.c32
PROMPT 0
TIMEOUT 100

MENU TITLE PXE Boot Menu

LABEL local
    MENU LABEL Boot from local disk
    LOCALBOOT 0
```

2. Configure your DHCP server to point to this TFTP server:
   - Next-server: `<tftp-server-ip>`
   - Filename: `pxelinux.0`

3. Add your boot images (kernels, initrd files) to the TFTP directory

## Pre-installed Files

The following files are included at `/tftp`:

- `pxelinux.0` - PXE boot loader
- `*.c32` - Syslinux modules (menu.c32, chain.c32, etc.)
- `pxelinux.cfg/` - Configuration directory

## Building Locally

```bash
docker build -t tftp-image .
```

## Automated Updates

This repository uses Renovate to automatically update dependencies daily:

1. Detects updates to the base Debian image digest and GitHub Actions
2. Opens PRs with the updated digests
3. Auto-merges Docker digest updates after tests pass
4. Pushes the new image with `latest` tag

## Architecture Support

- `linux/amd64`
- `linux/arm64`

Images are built using Docker Buildx with QEMU emulation for cross-platform support.

## License

This repository configuration is provided as-is. The included software (tftpd-hpa, PXELinux) maintains its original licenses.
