#!/bin/bash
set -e

echo "🧩 Starting Request Tracker container..."

# Așteaptă baza de date
echo "⏳ Waiting for PostgreSQL at $RT_DB_HOST:$RT_DB_PORT..."
until pg_isready -h "$RT_DB_HOST" -p "$RT_DB_PORT" -U "$RT_DB_ADMIN" > /dev/null 2>&1; do
  sleep 2
done
echo "✅ Database is up!"

# Inițializează baza de date dacă nu există deja
if [ ! -f /opt/rt6/var/INITIALIZED ]; then
  echo "🚀 Initializing RT database..."
  cd /opt/rt6
  make initialize-database \
    DATABASE_USER="$RT_DB_ADMIN" \
    DATABASE_PASSWORD="$RT_DB_ADMIN_PASS" \
    DATABASE_HOST="$RT_DB_HOST"
  
  echo "🧠 Setting up fulltext index..."
  /opt/rt6/sbin/rt-setup-fulltext-index --noask || true

  echo "✅ RT database initialized!"
  touch /opt/rt6/var/INITIALIZED
else
  echo "ℹ️ RT database already initialized, skipping setup."
fi

# Repară permisiunile dacă e nevoie
make fixperms || true

# Pornește Apache
echo "🌐 Starting Apache..."
exec apache2ctl -D FOREGROUND
