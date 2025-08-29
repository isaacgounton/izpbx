#!/bin/bash
# Script to update iZPBX components and fix authentication issues

echo "=> Fixing Authentication Issues"

# Create PAM configuration for asterisk if it doesn't exist
if [ ! -f /etc/pam.d/asterisk ]; then
    echo "#%PAM-1.0
auth       sufficient   pam_unix.so shadow nullok
auth       requisite    pam_deny.so
account    required     pam_unix.so
session    required     pam_unix.so" > /etc/pam.d/asterisk
    echo "=> Created PAM configuration for asterisk"
fi

# Ensure MySQL client has proper default configuration
echo "# MySQL client configuration to prevent authentication failures
[client]
user=${MYSQL_USER}
password=${MYSQL_PASSWORD}
host=${MYSQL_SERVER:-db}
port=${APP_PORT_MYSQL:-3306}
database=${MYSQL_DATABASE}
default-character-set=utf8" > /etc/my.cnf

echo "=> Created MySQL client configuration"

# Fix permissions on key files
chown -R asterisk:asterisk /etc/asterisk/keys/ 2>/dev/null || true
chown -R asterisk:asterisk /var/{lib,log,run,spool}/asterisk 2>/dev/null || true

echo "=> Updated permissions"

# Restart services that depend on these configurations
echo "=> Restarting services..."
supervisorctl restart asterisk 2>/dev/null || true
supervisorctl restart httpd 2>/dev/null || true

echo "=> Authentication fixes applied successfully"
