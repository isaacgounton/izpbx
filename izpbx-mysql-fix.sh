#!/bin/bash
# MySQL Authentication Fix Script for izPBX
# This script ensures proper MySQL client authentication configuration

set -e

echo "==> Applying comprehensive MySQL authentication fixes..."

# Get MySQL password from environment
MYSQL_PASS="${MYSQL_PASSWORD:-}"
MYSQL_USR="${MYSQL_USER:-asterisk}"
MYSQL_SRV="${MYSQL_HOST:-db}"
MYSQL_PRT="${MYSQL_TCP_PORT:-3306}"

if [ -z "$MYSQL_PASS" ]; then
    echo "ERROR: MYSQL_PASSWORD environment variable is not set"
    exit 1
fi

# Create MySQL configuration directories if they don't exist
mkdir -p /etc/my.cnf.d
mkdir -p /root
mkdir -p /home/asterisk

# Create comprehensive MySQL client configuration in /etc/my.cnf.d/
echo "==> Creating global MySQL client configuration..."
cat > /etc/my.cnf.d/zz-global-mysql-fix.cnf <<EOF
[client]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}
socket=/run/mariadb/mysql.sock

[mysql]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}

[mysqldump]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}

[mysqladmin]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}
EOF

chmod 644 /etc/my.cnf.d/zz-global-mysql-fix.cnf

# Create root user MySQL defaults file
echo "==> Creating /root/.my.cnf..."
cat > /root/.my.cnf <<EOF
[client]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}
socket=/run/mariadb/mysql.sock
EOF

chmod 600 /root/.my.cnf

# Create asterisk user MySQL defaults file
echo "==> Creating /home/asterisk/.my.cnf..."
cat > /home/asterisk/.my.cnf <<EOF
[client]
user=${MYSQL_USR}
password=${MYSQL_PASS}
host=${MYSQL_SRV}
port=${MYSQL_PRT}
socket=/run/mariadb/mysql.sock
EOF

chmod 600 /home/asterisk/.my.cnf
chown -R asterisk:asterisk /home/asterisk 2>/dev/null || true

# Export MySQL environment variables
export MYSQL_USER="${MYSQL_USR}"
export MYSQL_PASSWORD="${MYSQL_PASS}"
export MYSQL_HOST="${MYSQL_SRV}"
export MYSQL_TCP_PORT="${MYSQL_PRT}"
export MYSQL_PWD="${MYSQL_PASS}"

# Create wrapper script for mysql command to ensure proper authentication
echo "==> Creating mysql command wrapper..."
cat > /usr/local/bin/mysql-wrapper <<'WRAPPER_EOF'
#!/bin/bash
# Wrapper to ensure mysql command always uses correct credentials

# If no --defaults-file specified and no -u/--user specified, use our defaults
if ! echo "$@" | grep -qE '(--defaults-file|--defaults-extra-file|-u|--user)'; then
    exec /usr/bin/mysql --defaults-file=/etc/my.cnf.d/zz-global-mysql-fix.cnf "$@"
else
    exec /usr/bin/mysql "$@"
fi
WRAPPER_EOF

chmod +x /usr/local/bin/mysql-wrapper

echo "==> MySQL authentication fixes applied successfully"
echo "    User: ${MYSQL_USR}"
echo "    Host: ${MYSQL_SRV}"
echo "    Port: ${MYSQL_PRT}"
