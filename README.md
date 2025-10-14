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
| `TFTP_BLOCKSIZE` | `1468` | Maximum block size for transfers |
| `TFTP_OPTIONS` | `--secure` | Additional tftpd-hpa options |

### Common TFTP Options

- `--secure` - Change root directory on startup (recommended)
- `--create` - Allow new files to be created
- `--verbosity 4` - Increase logging verbosity (0-4)
- `--permissive` - Perform no additional permissions checks
- `--umask 022` - Set file creation mask

### Examples

**Enable file creation with verbose logging:**
```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/tftp \
  -e TFTP_OPTIONS="--secure --create --verbosity 4" \
  ghcr.io/claytono/tftp-pxelinux-image:latest
```

**Custom directory and block size:**
```bash
docker run -d \
  --name tftp \
  -p 69:69/udp \
  -v /path/to/tftp/files:/data \
  -e TFTP_DIRECTORY=/data \
  -e TFTP_BLOCKSIZE=8192 \
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
      TFTP_OPTIONS: "--secure --create --verbosity 2"
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

This repository uses Renovate to automatically update the base Debian image digest. When the base image is updated:

1. Renovate detects the new digest
2. Opens a PR with the updated Dockerfile
3. GitHub Actions builds and tests the image
4. If configured, auto-merges after 3 days
5. Pushes the new image with `latest` tag

## Architecture Support

- `linux/amd64`
- `linux/arm64`

Images are built using Docker Buildx with QEMU emulation for cross-platform support.

## License

This repository configuration is provided as-is. The included software (tftpd-hpa, PXELinux) maintains its original licenses.
