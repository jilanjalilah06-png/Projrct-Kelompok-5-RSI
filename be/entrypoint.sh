#!/bin/sh
# Entrypoint for AgriConnect Backend. Database admin is available on phpMyAdmin port 8080.
set -e

# Wait for MySQL database to be ready
echo "Waiting for database connection..."
php -r "
\$host = getenv('DB_HOST') ?: 'db';
\$port = getenv('DB_PORT') ?: '3306';
\$db   = getenv('DB_DATABASE') ?: 'agriconnect';
\$user = getenv('DB_USERNAME') ?: 'agriconnect_user';
\$pass = getenv('DB_PASSWORD') ?: 'secret';
\$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
for (\$i = 0; \$i < 60; \$i++) {
    try {
        new PDO(\$dsn, \$user, \$pass);
        exit(0);
    } catch (PDOException \$e) {
        echo \"Waiting for database to be ready...\n\";
        sleep(2);
    }
}
exit(1);
"

# Run migrations
echo "Running migrations..."
php artisan migrate --force
php artisan storage:link || true
chmod 777 storage/registered_users.json || true

# Run seeders only if users table is empty (to avoid duplicate entry error with sql import)
echo "Checking if database needs seeding..."
php -r "
\$host = getenv('DB_HOST') ?: 'db';
\$port = getenv('DB_PORT') ?: '3306';
\$db   = getenv('DB_DATABASE') ?: 'agriconnect';
\$user = getenv('DB_USERNAME') ?: 'agriconnect_user';
\$pass = getenv('DB_PASSWORD') ?: 'secret';
\$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
try {
    \$pdo = new PDO(\$dsn, \$user, \$pass);
    \$stmt = \$pdo->query('SELECT COUNT(*) FROM users');
    \$count = \$stmt->fetchColumn();
    if (\$count == 0) {
        echo \"Database is empty. Running seeders...\n\";
        passthru('php artisan db:seed --force');
    } else {
        echo \"Database already has data. Skipping seeders.\n\";
    }
} catch (PDOException \$e) {
    echo \"Failed to check database status, running seeders anyway: \" . \$e->getMessage() . \"\n\";
    passthru('php artisan db:seed --force');
}
"

# Keep documented demo accounts fast enough for local Docker development.
echo "Refreshing demo account password hashes..."
php -r "
\$host = getenv('DB_HOST') ?: 'db';
\$port = getenv('DB_PORT') ?: '3306';
\$db   = getenv('DB_DATABASE') ?: 'agriconnect';
\$user = getenv('DB_USERNAME') ?: 'agriconnect_user';
\$pass = getenv('DB_PASSWORD') ?: 'secret';
\$rounds = (int) (getenv('BCRYPT_ROUNDS') ?: 8);
\$emails = [
    'admin@agriconnect.com',
    'budi@agriconnect.com',
    'siti@agriconnect.com',
    'rahmat@agriconnect.com',
    'dewi@agriconnect.com',
    'hendra@agriconnect.com',
    'linda@agriconnect.com',
    'bambang@agriconnect.com',
    'nur@agriconnect.com',
    'gunawan@agriconnect.com',
    'ratih@agriconnect.com',
    'rianto@agriconnect.com',
    'susi@agriconnect.com',
    'widi@agriconnect.com',
    'yuni@agriconnect.com',
    'aryo@email.com',
    'lina@email.com',
    'riko@email.com',
    'eka@email.com',
    'fajar@email.com',
    'gita@email.com',
    'haris@email.com',
    'irma@email.com',
    'joko@email.com',
    'kirana@email.com',
    'lukman@email.com',
    'mira@email.com',
    'nanda@email.com',
    'oscar@email.com',
    'puspita@email.com',
];

try {
    \$dsn = \"mysql:host=\$host;port=\$port;dbname=\$db\";
    \$pdo = new PDO(\$dsn, \$user, \$pass);
    \$hash = password_hash('password123', PASSWORD_BCRYPT, ['cost' => \$rounds]);
    \$placeholders = implode(',', array_fill(0, count(\$emails), '?'));
    \$stmt = \$pdo->prepare(\"UPDATE users SET password = ? WHERE email IN (\$placeholders)\");
    \$stmt->execute(array_merge([\$hash], \$emails));
    echo \"Demo password hashes refreshed with bcrypt cost \$rounds.\n\";
} catch (PDOException \$e) {
    echo \"Failed to refresh demo account passwords: \" . \$e->getMessage() . \"\n\";
}
"

# Execute the main container command (CMD from Dockerfile)
echo "Executing: $@"
exec "$@"
