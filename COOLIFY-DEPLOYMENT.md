# Complete Coolify Deployment Guide for izPBX

This guide provides step-by-step instructions for deploying izPBX VoIP PBX system on Coolify.

## Prerequisites

- ✅ Coolify instance running and accessible
- ✅ Server with sufficient resources (minimum 2GB RAM, 2 CPU cores)
- ✅ Domain name (optional but recommended for SSL)
- ✅ Network ports available for VoIP traffic

## Step 1: Create New Project in Coolify

1. **Login to Coolify** dashboard
2. **Create New Project**:
   - Name: `izpbx-voip`
   - Description: `izPBX VoIP Telephony System`
3. **Select your server** where you want to deploy

## Step 2: Deploy as Docker Compose Resource

### Create Docker Compose Resource

1. In your project, click **"+ New Resource"**
2. Select **"Docker Compose"**
3. Configure the resource:
   - **Name**: `izpbx`
   - **Docker Compose**: Copy the content from `coolify-compose.yml`
   - **Build Pack**: Skip (we're using pre-built images)

### Upload Docker Compose Configuration

Copy and paste the entire content of `coolify-compose.yml` into the Docker Compose field.

## Step 3: Configure Environment Variables

### Required Security Variables (MUST CHANGE)

In Coolify's environment section, add these **critical** variables:

```env
MYSQL_PASSWORD=YourVerySecurePassword123!
MYSQL_ROOT_PASSWORD=YourSuperSecureRootPassword456!
```

### Copy Environment Variables from coolify.env

1. Open the `coolify.env` file
2. Copy ALL variables to Coolify's environment section
3. **Customize these important variables**:

```env
# Your domain (if you have one)
APP_FQDN=your-pbx-domain.com

# Your timezone
TZ=America/New_York

# Email configuration
SMTP_MAIL_FROM=pbx@yourdomain.com
SMTP_MAIL_TO=admin@yourdomain.com

# SSL/HTTPS (enable if using domain)
HTTPD_HTTPS_ENABLED=true
LETSENCRYPT_ENABLED=true
```

## Step 4: Configure Network Ports

### Port Mapping Strategy

Coolify will automatically handle port mapping. The compose file is configured to use these default ports:

- **Web Interface**: 80, 443
- **SIP**: 5060 (TCP/UDP)
- **IAX**: 4569 (UDP)
- **RTP Range**: 10000-10200 (UDP)

### Custom Port Configuration (Optional)

If you need custom ports, add these variables:

```env
COOLIFY_HTTP_PORT=8080
COOLIFY_HTTPS_PORT=8443
COOLIFY_PJSIP_PORT=5060
COOLIFY_RTP_START=10000
COOLIFY_RTP_END=10200
```

## Step 5: Configure Persistent Storage

The compose file is configured with named volumes:
- `izpbx_db` - Database storage
- `izpbx_data` - FreePBX configuration and data

Coolify will automatically handle these volumes.

## Step 6: Deploy the Application

1. **Review Configuration**:
   - Verify all environment variables
   - Check port mappings
   - Ensure persistent volumes are configured

2. **Deploy**:
   - Click **"Deploy"**
   - Wait for both services to start (database first, then izPBX)
   - Monitor logs for any errors

3. **Deployment Timeline**:
   - Database: ~30 seconds
   - izPBX: ~2-5 minutes (first time setup)
   - Total: ~5-10 minutes for full deployment

## Step 7: Initial Access and Verification

### Access the Web Interface

1. **Find your application URL** in Coolify dashboard
2. **Access FreePBX Setup**:
   - URL: `http://your-coolify-domain/admin/`
   - Or: `http://server-ip:port/admin/`

### First-Time Setup Wizard

When you first access the interface, FreePBX will run its setup wizard:

1. **Welcome Screen** - Click "Let's Go"
2. **Database Setup** - Should auto-configure (using environment variables)
3. **Admin User Creation**:
   - Username: `admin`
   - Password: Choose a secure password
   - Email: Your admin email
4. **Module Installation** - Let it install default modules (~5-10 minutes)
5. **Firewall Configuration** - Configure as needed

## Step 8: Post-Deployment Configuration

### Essential FreePBX Settings

1. **Navigate to Admin → Advanced Settings**:
   ```
   CW Enabled by Default: NO
   Country Indication Tones: [Your Country]
   Ringtime Default: 60 seconds
   PHP Timezone: [Match your TZ environment variable]
   ```

2. **Configure SIP Settings** (Admin → Asterisk SIP Settings):
   ```
   External IP: [Your server's public IP]
   Local Networks: [Your internal network ranges]
   ```

3. **Security Settings** (Settings → Asterisk Logfile Settings):
   ```
   Allow Anonymous Inbound SIP Calls: No
   Allow SIP Guests: No
   ```

### Test VoIP Functionality

1. **Create Test Extensions**:
   - Go to Applications → Extensions
   - Create 2-3 test extensions

2. **Configure SIP Clients**:
   - Use a softphone (like Zoiper, X-Lite)
   - Server: Your Coolify domain/IP
   - Port: 5060
   - Username/Password: From your extension

3. **Test Calls**:
   - Register extensions
   - Make test calls between extensions
   - Verify audio quality

## Step 9: SSL/HTTPS Configuration (Optional)

### If Using Custom Domain

1. **DNS Setup**:
   - Point your domain to your Coolify server IP
   - Configure A records for your domain

2. **Enable HTTPS** (already configured in environment):
   ```env
   HTTPD_HTTPS_ENABLED=true
   LETSENCRYPT_ENABLED=true
   APP_FQDN=your-domain.com
   ```

3. **Force HTTPS Redirect**:
   ```env
   HTTPD_REDIRECT_HTTP_TO_HTTPS=true
   ```

## Troubleshooting Common Issues

### Database Connection Issues

**Symptom**: FreePBX can't connect to database

**Solution**:
1. Check database container logs in Coolify
2. Verify environment variables are correct
3. Ensure database container started before izPBX

### SIP/Audio Issues

**Symptom**: Can't register phones or no audio

**Solutions**:
1. **Check port mappings**:
   - Ensure UDP 5060 and RTP range are accessible
   - Verify firewall settings

2. **Configure NAT settings** in FreePBX:
   - Admin → Asterisk SIP Settings
   - Set external IP to your public server IP
   - Configure local networks properly

3. **Reduce RTP port range** if needed:
   ```env
   COOLIFY_RTP_START=10000
   COOLIFY_RTP_END=10050
   ```

### Web Interface Issues

**Symptom**: Can't access web interface

**Solutions**:
1. Check HTTP/HTTPS port mappings in Coolify
2. Verify Apache is running: Check container logs
3. Try accessing via direct IP:PORT

### Performance Issues

**Symptoms**: Slow response, timeouts

**Solutions**:
1. **Increase server resources**:
   - Minimum: 2GB RAM, 2 CPU cores
   - Recommended: 4GB RAM, 4 CPU cores

2. **Check container resource limits** in Coolify
3. **Monitor container logs** for memory/CPU issues

## Maintenance and Updates

### Backup Strategy

**Database Backup**:
- Volume: `izpbx_db`
- Create regular backups via Coolify's backup features

**Configuration Backup**:
- Volume: `izpbx_data`
- Contains FreePBX configurations and recordings

### Updates

**Container Updates**:
1. Change image tag in compose file
2. Redeploy via Coolify
3. Follow izPBX upgrade procedures

**FreePBX Module Updates**:
- Use FreePBX web interface: Admin → Module Admin

## Security Recommendations

1. **Change Default Passwords**:
   - MySQL passwords (in environment variables)
   - FreePBX admin password
   - Extension passwords

2. **Enable Fail2ban** (already configured):
   ```env
   FAIL2BAN_ENABLED=true
   FAIL2BAN_ASTERISK_ENABLED=true
   ```

3. **Configure Firewall**:
   - Only expose necessary ports
   - Use VPN for administrative access

4. **Regular Updates**:
   - Keep containers updated
   - Update FreePBX modules regularly

## Support and Resources

- **izPBX Documentation**: https://github.com/ugoviti/izpbx
- **FreePBX Wiki**: https://wiki.freepbx.org/
- **Coolify Documentation**: https://coolify.io/docs
- **Community Forums**: FreePBX Community Forums

This completes your izPBX deployment on Coolify! Your VoIP PBX system should now be fully functional and ready for production use.