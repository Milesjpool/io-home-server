# Homepage

A beautiful, responsive homepage that serves as a dashboard for all network services on the Io home server.

## Features

- **Modern Design**: Clean, responsive interface with gradient backgrounds and smooth animations
- **Service Discovery**: Automatically displays all available services with descriptions and status indicators
- **Categorized Layout**: Services are organized by type (Monitoring, Media, Network, etc.)
- **Mobile Friendly**: Responsive design that works well on all device sizes
- **Live Status**: Visual indicators show service availability

## Services Included

### Monitoring
- **Grafana**: System metrics and performance dashboards
- **Prometheus**: Time-series database for metrics collection
- **Alertmanager**: Alert management and notification routing

### Media & Productivity
- **Jellyfin**: Personal media streaming server
- **Calibre Web**: Digital library and e-book management

### Network & Security
- **AdGuard Home**: Network-wide ad and tracker blocking
- **WireGuard VPN**: Secure remote access configuration

### Home Automation
- **Home Assistant**: Smart home device control and automation

### Management
- **Portainer**: Docker container management interface
- **Desktop Control**: Remote desktop access

## Installation

Run the install script to deploy the homepage:

```bash
./install.sh
```

This will:
1. Create necessary directories
2. Start the nginx container serving the homepage
3. Make it available through the reverse proxy as the default route

## Architecture

- **Container**: nginx:alpine serving static HTML
- **Network**: Connected to the proxy network for reverse proxy access
- **Default Route**: Configured in Caddy to serve when no specific subdomain matches

## Customization

To modify the homepage:
1. Edit `www/index.html` to update content, styling, or add/remove services
2. Restart the container: `docker compose restart homepage`

The homepage automatically adapts to the existing service configuration and provides a centralized entry point for all network applications.