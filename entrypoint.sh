#!/bin/bash
set -e

# Load .env
export $(grep -v '^#' /env/.env | xargs)

# Initialize PostgreSQL if not done
if [ ! -f "/var/lib/pgsql/data/postgresql.conf" ]; then
    postgresql-setup --initdb
    systemctl enable postgresql
    systemctl start postgresql
fi

# Create DB users if not exists
sudo -u postgres psql -c "CREATE USER ${RT_DB_ADMIN} WITH PASSWORD '${RT_DB_ADMIN_PASS}' CREATEDB CREATEROLE LOGIN;" || true
sudo -u postgres psql -c "CREATE USER ${RT_DB_USER} WITH PASSWORD '${RT_DB_PASS}';" || true
sudo -u postgres psql -c "CREATE DATABASE ${RT_DB_NAME} OWNER ${RT_DB_USER};" || true

# Configure pg_hba.conf
echo "host    ${RT_DB_NAME}   ${RT_DB_USER}   0.0.0.0/0   md5" >> /var/lib/pgsql/data/pg_hba.conf
echo "host    ${RT_DB_NAME}   ${RT_DB_ADMIN}  0.0.0.0/0   md5" >> /var/lib/pgsql/data/pg_hba.conf
systemctl reload postgresql

# Generate RT configuration
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

# Initialize RT DB
/opt/rt6/sbin/rt-setup-database --action init --prompt-for-database-password < /dev/null
/opt/rt6/sbin/rt-setup-fulltext-index --noask

# Fix permissions
make -C /opt/rt6 fixperms

# Start RT’s web server
exec /usr/sbin/nginx -g 'daemon off;'
