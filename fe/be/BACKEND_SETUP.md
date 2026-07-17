# Backend Setup & Connection Guide

## Status: ✅ Backend Fully Operational

### Prerequisites
- PHP 8.2+
- Composer installed
- SQLite or MySQL
- Laravel 11+

### Quick Start (If Already Set Up)

```bash
cd ch1/be

# 1. Install dependencies (if needed)
composer install

# 2. Generate app key (if needed)
php artisan key:generate

# 3. Run migrations and seed database
php artisan migrate:fresh --seed

# 4. Start the server
php artisan serve --host=0.0.0.0 --port=8000
```

### Server URL
- **Desktop/Emulator**: http://127.0.0.1:8000
- **Physical Device**: http://<YOUR-PC-IP>:8000 (e.g., http://192.168.1.5:8000)
- Find your PC IP: Run `ipconfig` in terminal, look for IPv4 address under your network adapter

### Test Login Endpoint

Using PowerShell:
```powershell
$body = @{
    email = "admin@agriconnect.com"
    password = "password123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json" `
    -UseBasicParsing | Select-Object -ExpandProperty Content
```

Using cURL (Git Bash/WSL):
```bash
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@agriconnect.com","password":"password123"}'
```

### Test Credentials

| Role  | Email | Password |
|-------|-------|----------|
| Admin | admin@agriconnect.com | password123 |
| Petani | budi@agriconnect.com | password123 |
| Pembeli | aryo@email.com | password123 |

### Database Setup

The database is already seeded with test data:
- 1 Admin user
- 4 Petani (Sellers) with shops
- 3 Pembeli (Buyers)
- Sample categories and products

To reset database:
```bash
php artisan migrate:fresh --seed
```

### Configuration Files

- **Database**: `config/database.php` (SQLite by default in `.env`)
- **JWT Auth**: `config/jwt.php` (Secret in `.env`)
- **CORS**: `config/cors.php` (Allows all origins)
- **Auth**: `config/auth.php` (JWT guard for API)

### Environment Variables (.env)

Key variables already configured:
```
APP_NAME=AgriConnect
APP_URL=http://localhost:8000
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
JWT_SECRET=Q5TwDY46odoKYbVmZnjU9gEXSj9XRKuErQiVstTrtl9BlBgggzNYvRcby7yhielx
JWT_ALGORITHM=HS256
```

### API Endpoints

**Public Endpoints:**
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user (returns JWT token)

**Protected Endpoints (require JWT in Authorization header):**
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user profile
- `POST /api/auth/refresh` - Refresh JWT token
- `GET/POST /api/products` - Product CRUD
- `GET/POST /api/categories` - Category CRUD
- `GET/POST /api/orders` - Order CRUD
- `GET/POST /api/reviews` - Review CRUD

### CORS Configuration

CORS is enabled for all origins, methods, and headers. This allows the Flutter app to communicate with the backend.

### Troubleshooting

**Port Already in Use:**
```bash
# Find process using port 8000
netstat -ano | findstr :8000

# Kill the process
taskkill /PID <PID> /F

# Then start server again
php artisan serve --host=0.0.0.0 --port=8000
```

**Database File Not Found:**
```bash
# The database file is created automatically at:
database/database.sqlite

# If it doesn't exist, Laravel will create it on first migration
```

**JWT Token Invalid:**
- Ensure `JWT_SECRET` is set in `.env`
- If changed, regenerate: `php artisan jwt:secret`

### Next Steps

Once backend is running:
1. Note your PC's IP address (for physical device testing)
2. Update Flutter app's `api_constants.dart` with correct backend URL
3. Run Flutter app and test login with credentials above
