#!/bin/bash
set -e

echo "=== AgriConnect Backend Startup ==="

# Generate app key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Cache config & routes for performance
echo "Caching config..."
php artisan config:cache
php artisan route:cache

echo "Starting Apache..."
exec apache2-foreground
