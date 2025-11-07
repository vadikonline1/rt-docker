#!/bin/bash
set -e

# Load env variables
export $(grep -v '^#' /opt/rt6/.env | xargs)

# Wait for Postgres to be ready
until pg_isready -h $POSTGRES_HOST -U $POSTGRES_USER > /dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

# Initialize database if not already done
if [ ! -f "${RT_PREFIX}/var/db_initialized" ]; then
    echo "Initializing RT database..."
    ${RT_PREFIX}/sbin/rt-setup-database --action init --datadir ${RT_PREFIX}/var/attachments \
        --dba $POSTGRES_USER --prompt-for-dba-password 0 \
        --dbname $POSTGRES_DB --dbhost $POSTGRES_HOST --dbuser $POSTGRES_USER --dbpass $POSTGRES_PASSWORD
    touch ${RT_PREFIX}/var/db_initialized
fi

# Start RT server
exec ${RT_PREFIX}/sbin/rt-server --port $RT_WEB_PORT
