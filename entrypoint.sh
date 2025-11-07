#!/bin/bash
set -e

# Load .env
export $(grep -v '^#' /opt/rt6/.env | xargs)

# Replace variables in template
envsubst < /opt/rt6/etc/RT_SiteConfig.pm.template > /opt/rt6/etc/RT_SiteConfig.pm

# Initialize database if needed
if [ ! -f /opt/rt6/var/db_initialized ]; then
    make initialize-database
    touch /opt/rt6/var/db_initialized
fi

# Start FastCGI RT server
exec /opt/rt6/sbin/rt-server.fcgi -d
