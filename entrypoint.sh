#!/bin/bash
set -e

# Load .env
export $(grep -v '^#' /env/.env | xargs)

# Start PostgreSQL in background
sudo -u postgres pg_ctl -D /var/lib/pgsql/data -l /var/lib/pgsql/logfile start

# Create DB users and database if not exists
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${RT_DB_ADMIN}'" | grep -q 1 || \
  sudo -u postgres psql -c "CREATE USER ${RT_DB_ADMIN} WITH PASSWORD '${RT_DB_ADMIN_PASS}' CREATEDB CREATEROLE LOGIN;"
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${RT_DB_USER}'" | grep -q 1 || \
  sudo -u postgres psql -c "CREATE USER ${RT_DB_USER} WITH PASSWORD '${RT_DB_PASS}';"
sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "${RT_DB_NAME}" || \
  sudo -u postgres createdb -O ${RT_DB_USER} ${RT_DB_NAME}

# Configure RT
cat >/opt/rt6/etc/RT_SiteConfig.pm <<EOL
Set(\$rtname, '${RT_ORG}');
Set(\$Organization, '${RT_ORG}');
Set(\$WebDomain, '${RT_WEB_DOMAIN}');
Set(\$WebPort, '${RT_WEB_PORT}');
Set(\$WebPath, '${RT_WEB_PATH}');
Set(\$DatabaseUser, '${RT_DB_USER}');
Set(\$DatabasePassword, '${RT_DB_PASS}');
Set(\$DatabaseHost, 'localhost');
Set(\$DatabasePort, undef);
Set(\$DatabaseName, '${RT_DB_NAME}');
Set(\$DatabaseAdmin, '${RT_DB_ADMIN}');
Set(\$LogToSyslog, 'warning');
Set(\$LogToSTDERR, 'warning');
Set(%GnuPG, 'Enable' => '0');
Set(%SMIME, 'Enable' => '0');
1;
EOL

# Initialize RT DB and fulltext index
/opt/rt6/sbin/rt-setup-database --action init --prompt-for-database-password < /dev/null
/opt/rt6/sbin/rt-setup-fulltext-index --noask

# Fix permissions
make -C /opt/rt6 fixperms

# Start Nginx in foreground
exec /usr/sbin/nginx -g 'daemon off;'
