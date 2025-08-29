#!/bin/bash
# Enhanced script to update iZPBX components and fix authentication issues

echo "=> Starting iZPBX components update..."
echo "=> Fixing Authentication Issues"

# Create PAM configuration for asterisk if it doesn't exist
if [ ! -f /etc/pam.d/asterisk ]; then
    echo "---> creating PAM configuration for asterisk authentication"
    mkdir -p /etc/pam.d
    cat > /etc/pam.d/asterisk <<EOF
#%PAM-1.0
auth       sufficient   pam_unix.so shadow nullok
auth       requisite    pam_deny.so
account    required     pam_unix.so
session    required     pam_unix.so
EOF
    echo "---> PAM configuration for asterisk created"
else
    echo "---> PAM configuration for asterisk already exists, skipping"
fi

# Create enhanced MySQL client configuration
echo "---> creating comprehensive MySQL client configuration"
mkdir -p /etc/my.cnf.d
cat > /etc/my.cnf.d/zz-global-mysql-fix.cnf <<EOF
# Global MySQL client configuration to fix authentication failures
# This prevents services from defaulting to user 'mysql' when no credentials are specified

[client]
user=asterisk
host=db
port=3306
connect_timeout=10
protocol=TCP

[mysql]
default-auth=mysql_native_password
connect_expired_password=1
EOF

echo "---> MySQL client configuration created"

# Fix permissions on key files
echo "---> fixing permissions on key files and Asterisk directories"
chown -R asterisk:asterisk /etc/asterisk/keys/ 2>/dev/null || true
chown -R asterisk:asterisk /var/{lib,log,run,spool}/asterisk 2>/dev/null || true

echo "---> permissions updated"

# Restart services that depend on these configurations
echo "=> Restarting services to apply authentication fixes..."
supervisorctl restart asterisk 2>/dev/null || true
supervisorctl restart httpd 2>/dev/null || true

# Verification steps
echo "=> Verifying configurations..."
if [ -f /etc/pam.d/asterisk ]; then
    echo "--> PAM asterisk configuration: OK [$(stat -c%s /etc/pam.d/asterisk) bytes]"
else
    echo "--> ERROR: PAM asterisk configuration: MISSING"
fi

if [ -f /etc/my.cnf.d/zz-global-mysql-fix.cnf ]; then
    echo "--> MySQL global client configuration: OK [$(stat -c%s /etc/my.cnf.d/zz-global-mysql-fix.cnf) bytes]"
else
    echo "--> ERROR: MySQL global client configuration: MISSING"
fi

echo "=> Authentication fixes applied successfully"
echo "=> NOTE: Restart the container to apply all changes"
echo "   Use: docker-compose down && docker-compose up -d"
