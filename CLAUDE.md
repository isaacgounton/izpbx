# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

izPBX is a Cloud Native VoIP Telephony System powered by Asterisk Engine and FreePBX Management GUI. This is a containerized PBX solution designed for both cloud and on-premise deployments with Docker Compose.

## Development Commands

### Core Operations
- **Start the system**: `docker compose up -d`
- **Stop the system**: `docker compose down`
- **View logs**: `docker compose logs -f izpbx`
- **Restart services**: `docker compose restart izpbx`

### Container Management
- **Enter izPBX container**: `docker exec -it izpbx bash`
- **Enter database container**: `docker exec -it izpbx-db bash`
- **Restart individual services**: `docker exec -it izpbx supervisorctl restart <service>`

### Available Services (inside izPBX container)
Use `supervisorctl restart <service>` to restart:
- `asterisk` - Asterisk PBX engine
- `httpd` - Apache web server
- `fail2ban` - Security monitoring
- `fop2` - Operator panel
- `cron` - Scheduled tasks
- `postfix` - Mail transport agent
- `zabbix-agent` - Monitoring agent

### Database Operations
- **Database upgrade after MariaDB update**: `source .env ; docker exec -it izpbx-db mysql_upgrade -u root -p$MYSQL_ROOT_PASSWORD`
- **Access database**: `docker exec -it izpbx-db mysql -u root -p`

## Architecture

### Container Structure
The system uses an "antipattern" container design required by the FreePBX ecosystem:

1. **izpbx container**: Main application container running multiple services
   - Asterisk PBX engine
   - FreePBX web interface (Apache + PHP)
   - Fail2ban security monitoring
   - Various supporting services (cron, postfix, etc.)
   - Uses `network_mode: host` for SIP/RTP traffic handling

2. **izpbx-db container**: MariaDB database backend
   - Persistent data storage in `./data/db/`
   - Exposed on port 3306 (configurable via `APP_PORT_MYSQL`)

### Key Directories
- `izpbx-asterisk/`: Main container build directory
  - `Dockerfile`: Container build definition
  - `rootfs/`: Container filesystem overlay
  - `build/`: Build scripts and utilities
  - `compose/`: Development compose files
- `data/`: Persistent data storage (created at runtime)
  - `data/db/`: Database files
  - `data/izpbx/`: FreePBX configuration and files

### Configuration Management
- **Main config**: `compose.yml` (don't edit directly)
- **Environment variables**: Copy `default.env` to `.env` and customize
- **Override settings**: Create `docker-compose.override.yml`
- **Security**: Change default passwords in `.env` file

### Build System
The container is built using a multi-stage Dockerfile that:
1. Installs base Rocky Linux 8 packages
2. Compiles Asterisk from source with specific modules
3. Downloads and caches FreePBX modules for offline installation
4. Installs additional components (FOP2, Zabbix agents, etc.)

### Network Architecture
- **Default**: Uses `network_mode: host` to expose services directly on host network
- **Multi-tenant**: Can use macvlan networks for multiple instances
- **Port ranges**: RTP traffic uses ports 10000-20000 by default

## Important Notes

### Security Considerations
- Default passwords must be changed in `.env` file
- Fail2ban is enabled by default for brute force protection
- Uses Let's Encrypt for automatic SSL certificates when exposed to internet

### Version Management
- Tags follow format: `ASTERISK.FREEPBX.IZPBX-BUILD`
- Major FreePBX upgrades require special procedures
- Set `FREEPBX_AUTOUPGRADE_CORE=true` for automatic core upgrades

### Multi-Tenant Deployment
For running multiple izPBX instances:
- Use macvlan networking with dedicated IPs
- Each instance requires separate database
- Modify network configuration in compose files

### Backup and Maintenance
- Persistent data stored in `./data/` directory
- FreePBX backups configured via web interface
- Database backups should be handled separately
- Logrotation configured for all services[byterover-mcp]

# important 
always use byterover-retrieve-knowledge tool to get the related context before any tasks 
always use byterover-store-knowledge to store all the critical informations after sucessful tasks