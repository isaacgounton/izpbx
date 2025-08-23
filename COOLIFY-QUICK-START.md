# Quick Start: izPBX on Coolify

## TL;DR - Fast Deployment

### 1. Create Docker Compose Resource in Coolify
- **Name**: `izpbx`  
- **Docker Compose**: Copy from `coolify-compose.yml`

### 2. Essential Environment Variables
```env
# SECURITY - MUST CHANGE THESE
MYSQL_PASSWORD=YourSecurePassword123!
MYSQL_ROOT_PASSWORD=YourSecureRootPassword456!

# BASIC CONFIG
TZ=America/New_York
APP_FQDN=your-pbx.domain.com
SMTP_MAIL_FROM=pbx@yourdomain.com
SMTP_MAIL_TO=admin@yourdomain.com

# SSL (if using domain)
HTTPD_HTTPS_ENABLED=true
LETSENCRYPT_ENABLED=true
```

### 3. Deploy & Access
1. Click **Deploy** in Coolify
2. Wait 5-10 minutes for startup
3. Access: `http://your-coolify-url/admin/`
4. Complete FreePBX setup wizard

## Default Ports Exposed
- **Web**: 80, 443
- **SIP**: 5060 (TCP/UDP)
- **IAX**: 4569 (UDP)  
- **RTP**: 10000-10200 (UDP)

## First Login
- URL: `http://your-server/admin/`
- Follow FreePBX setup wizard
- Create admin user
- Wait for module installation

## Quick SIP Test
1. **Create Extension**: Applications → Extensions
2. **Configure Softphone**:
   - Server: Your Coolify URL/IP
   - Port: 5060
   - Credentials: From extension config

## Need Help?
See `COOLIFY-DEPLOYMENT.md` for detailed instructions.