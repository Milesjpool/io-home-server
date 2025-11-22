# AGENTS.md

This document provides context for AI agents working with this repository.

## Repository Overview

This is a home server provisioning repository for "Io", an Ubuntu server running various services including gaming (Steam Big Picture), media (Jellyfin), monitoring (Prometheus/Grafana), and home automation (Home Assistant).

## Repository Structure

```
io-home-server/
├── install/              # OS installation automation (Ubuntu autoinstall)
├── provision/
│   ├── desktop/         # Desktop environment provisioning
│   └── server/          # Server provisioning
│       ├── .apps/       # Individual service/app configurations
│       ├── global.env   # Shared environment variables
│       └── private.env  # Private/sensitive configuration
```

## Key Patterns & Conventions

### Service Structure
Each app in `provision/server/.apps/` typically contains:
- `install.sh` - Installation script (idempotent, can be run multiple times)
- `docker-compose.yml` - For containerized services
- `*.template` files - Configuration templates with `__PLACEHOLDER__` syntax
- `private.env` - Service-specific private configuration (not committed)

### Environment Files
- `global.env` - Shared variables (timezone, network subnets, Docker config)
- `private.env` - User-specific sensitive data (controller MACs, API keys, etc.)
- Templates use `sed` to replace placeholders: `sed "s|__PLACEHOLDER__|$VALUE|g"`

### Installation Scripts
- All `install.sh` scripts should be idempotent
- Source environment files: `source ../../global.env` or `source ../home-assistant/.env`
- Use `sudo` for system-level changes
- Install systemd services via templates

## Server Hardware

- **CPU**: AMD (with integrated GPU)
- **Dedicated GPU**: Intel Arc (card1, primary for gaming)
- **Display**: HDMI output (HDMI-3, 1920x1080)
- **OS**: Ubuntu Server (headless, but can run X server)

### GPU Configuration
- `DRI_PRIME=0` selects Intel Arc GPU (card1)
- `MESA_VK_DEVICE_SELECT=0` for Vulkan device selection
- AMD integrated GPU used for display, Intel Arc for rendering

## Key Services

### Steam Big Picture
- Runs as systemd service with headless X server
- Bluetooth controller support with udev rules for auto-start
- Requires `kernel.unprivileged_userns_clone=1` for user namespaces

### Home Assistant
- Docker container
- Integrates with other services via REST APIs
- Configuration in `provision/server/.apps/home-assistant/`
- Packages directory for service integrations

### Monitoring Stack
- Prometheus, Grafana, Loki, Promtail, AlertManager
- All containerized via Docker Compose
- Node exporter for system metrics
- Fail2ban exporter for security metrics

### Reverse Proxy
- Caddy (containerized)
- Handles routing to internal services
- HTTP auth planned (OAuth/SSO)

## Technical Details

### User Context
- Primary user: `<username>` (UID: 1000)
- Services run as root or specific users as needed
- `sudo -u#UID` used to run commands as specific users

### Systemd Services
- Services typically run as root for X server access
- User commands executed via `sudo -u#UID`
- Environment variables must be exported within sudo context
- `XDG_RUNTIME_DIR=/run/user/$UID` required for user services

### Docker
- Subnet: `<docker-subnet>` (e.g., `172.20.0.0/16`)
- Gateway: `<docker-gateway>` (e.g., `172.20.0.1`)
- Services communicate via Docker network

### Network
- LAN subnet: `<lan-subnet>` (e.g., `192.168.x.0/24`)
- UFW firewall configured
- Docker subnet allowed for service communication

## Development Guidelines

**IMPORTANT**: When making changes during development, always use the idempotent install scripts rather than directly manipulating files or calling docker-compose.

### ✅ DO:
- Run `./install.sh` scripts to apply changes
- Modify template files and let install scripts process them
- Edit configuration files in the service directories
- Let install scripts handle file copying, templating, and service installation

### ❌ DON'T:
- Copy files directly to system locations (e.g., `/etc/systemd/system/`)
- Run `docker-compose` commands directly
- Manually edit files in system directories
- Bypass the install scripts

**Why?** The install scripts ensure:
- Templates are properly processed with environment variables
- Files are placed in correct locations
- Systemd services are properly installed and reloaded
- Docker Compose services are started correctly
- Changes are idempotent and can be safely re-run

**Example workflow:**
1. Edit a service template file (e.g., `*.service.template`)
2. Run `cd provision/server/.apps/<service-name> && ./install.sh`
3. The script handles templating, copying, and service reload

## Common Workflows

### Adding a New Service
1. Create directory in `provision/server/.apps/`
2. Add `install.sh` (idempotent)
3. Add templates for config files
4. Add `private.env` if needed (add to `.gitignore`)
5. Update main `provision/server/install.sh` if needed

### Testing Changes
- **Always run `install.sh` scripts** to apply changes (they're idempotent)
- Never manually copy files or run docker-compose directly
- Check service status: `systemctl status <service>`
- View logs: `journalctl -u <service> -f`

## Important Notes

- **Never commit `private.env` files** - they contain personal data
- **Templates use double underscores**: `__PLACEHOLDER__`
- **Install scripts are idempotent** - safe to run multiple times
- **Services don't auto-start on boot** unless explicitly enabled
- **User namespaces** may be required for some services (enabled via sysctl)
- **GPU selection is counter-intuitive**: `DRI_PRIME=0` selects Intel Arc (card1)

