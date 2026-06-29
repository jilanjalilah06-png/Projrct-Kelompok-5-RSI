# 🌾 AgriConnect Backend API

**Platform E-Commerce Pertanian Modern**  
Menghubungkan petani langsung dengan pembeli untuk hasil panen berkualitas tinggi.

---

## 📋 Dokumentasi Cepat

👉 **Mulai dari sini**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)

Dokumentasi tersedia dalam folder ini:

| File | Tujuan | Untuk Siapa |
|------|--------|-----------|
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Setup backend awal | Developer baru |
| [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) | Panduan integrasi BE-FE | Frontend developer |
| [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) | Konfigurasi environment | Semua developer |
| [INTEGRATION_CHECKLIST.md](INTEGRATION_CHECKLIST.md) | Checklist integrasi | QA/Testing |
| [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md) | Quick reference API | API tester |

---

## 🚀 Quick Start (5 Menit)

### 1. Setup Backend
```bash
cd C:\Users\ThinkPad\Downloads\ch1\be

# Install dependencies
composer install

# Generate keys
php artisan key:generate
php artisan jwt:secret

# Setup database
php artisan migrate
php artisan db:seed

# Start server
php artisan serve --port=8000
```

✅ Backend running di: `http://localhost:8000`

### 2. Setup Frontend
```bash
cd C:\Users\ThinkPad\Downloads\ch1\fe

# Install dependencies
flutter pub get

# Update API host di lib/core/constanst/api_constants.dart
# (sesuaikan dengan target device)

# Run app
flutter run -d windows
```

### 3. Test Integration
1. Register user baru di app
2. Login dengan credentials
3. Harus berhasil dan bisa akses protected features

---

## 🏗️ Arsitektur

### Backend
- **Framework**: Laravel 11
- **Authentication**: JWT (Tymon JWTAuth)
- **Database**: SQLite (dev) / MySQL (prod)
- **API Format**: REST JSON
- **CORS**: Enabled untuk semua origins

### Frontend
- **Framework**: Flutter (Dart)
- **HTTP Client**: package:http
- **State Management**: Provider
- **Target**: Android, iOS, Windows, Web

### Communication
```
Frontend (Flutter) 
    ↓↑ HTTP Requests/Responses
Backend (Laravel API)
    ↓↑ JSON Data
Database (SQLite/MySQL)
```

---

## 🔐 Authentication

**JWT Token-based Authentication**

1. User register/login
2. Backend mengembalikan JWT token
3. Frontend simpan token
4. Setiap request protected endpoints harus include token di header
5. Token auto-refresh sebelum expired

**Token Lifetime**: 60 menit (configurable di `.env`)

---

## 📦 API Endpoints

### Public Endpoints (Tanpa Token)
```
POST   /api/auth/register
POST   /api/auth/login
```

### Protected Endpoints (Dengan Token)
```
Auth
  GET    /api/auth/me
  POST   /api/auth/logout
  POST   /api/auth/refresh

Products
  GET    /api/products
  GET    /api/products/{id}
  POST   /api/products                    (Petani only)
  PUT    /api/products/{id}
  DELETE /api/products/{id}

Categories
  GET    /api/categories
  
Orders
  GET    /api/orders
  POST   /api/orders
  PATCH  /api/orders/{id}/status

Reviews
  GET    /api/reviews
  POST   /api/reviews
  GET    /api/products/{id}/rating

Sellers
  GET    /api/sellers
  GET    /api/sellers/{id}
  GET    /api/sellers/profile            (Petani only)
  PUT    /api/sellers/profile
```

**Detail**: Lihat [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)

---

## 👥 User Roles

### 1. **Pembeli** (Buyer)
- Browse dan beli produk
- Membuat order
- Memberikan review
- View order history

### 2. **Petani** (Farmer/Seller)
- Create/manage produk sendiri
- View order dari pembeli
- Update order status
- View shop profile & statistics

### 3. **Admin**
- Manage categories
- Moderate user accounts
- View system statistics
- System management

---

## 📁 Project Structure

```
be/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/    ← API Controllers
│   │   └── Middleware/
│   ├── Models/                 ← Database Models
│   └── Providers/
├── config/                     ← Configuration
│   ├── cors.php               ← CORS settings
│   ├── jwt.php                ← JWT settings
│   ├── auth.php               ← Auth settings
│   └── ...
├── database/
│   ├── migrations/            ← Database schemas
│   ├── seeders/               ← Test data
│   └── factories/
├── routes/
│   ├── api.php               ← API routes
│   └── ...
├── storage/
│   ├── logs/                 ← Application logs
│   └── app/
├── .env                      ← Environment variables
├── composer.json
└── artisan
```

---

## 🔨 Development Commands

### Artisan Commands
```bash
# Show all routes
php artisan route:list

# Run migrations
php artisan migrate

# Run seeders
php artisan db:seed

# Tinker (Interactive Shell)
php artisan tinker

# Cache clear
php artisan cache:clear

# Logs
php artisan logs

# Generate JWT secret
php artisan jwt:secret

# Test
php artisan test
```

### Database Commands
```bash
# Migrate + seed
php artisan migrate --seed

# Rollback migrations
php artisan migrate:rollback

# Fresh migration (reset + migrate + seed)
php artisan migrate:fresh --seed
```

---

## 📊 Database Schema

### Users Table
- id, name, email, password, phone, address, role
- avatar, is_verified, shop_name, shop_description
- timestamps

### Products Table
- id, seller_id, category_id, name, description, price, stock
- image, unit, is_active, timestamps

### Orders Table
- id, buyer_id, order_number, total_price, status
- shipping_address, notes, timestamps

### OrderItems Table
- id, order_id, product_id, quantity, unit_price, total_price

### Categories Table
- id, name, description, image, timestamps

### Reviews Table
- id, product_id, reviewer_id, rating, comment, timestamps

---

## 🧪 Testing

### Manual Testing (Postman/Insomnia)
Import requests dari [API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)

### Automated Testing
```bash
php artisan test
```

---

## 🐛 Troubleshooting

### "Connection refused" error
- ❌ Backend tidak running
- ✅ Run: `php artisan serve --port=8000`

### "CORS policy" error
- ❌ CORS tidak configured
- ✅ Sudah fixed di [config/cors.php](config/cors.php)

### "401 Unauthorized" error
- ❌ Token tidak valid/expired
- ✅ Refresh token atau re-login

### "422 Validation" error
- ❌ Data tidak sesuai validation rules
- ✅ Check error messages di response

**Lebih detail**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md#-common-integration-issues--solutions)

---

## 📝 Git Workflow

```bash
# Clone repo (sudah ada)
# Checkout branch fitur
git checkout -b feature/nama-fitur

# Buat changes
# Commit
git commit -m "feat: deskripsi"

# Push
git push origin feature/nama-fitur

# Create Pull Request
```

---

## 🔗 Useful Links

- **Laravel Docs**: https://laravel.com/docs
- **JWT Auth**: https://github.com/tymondesigns/jwt-auth
- **Flutter HTTP**: https://pub.dev/packages/http
- **Provider**: https://pub.dev/packages/provider

---

## 📞 Support

### Backend Issues
Lihat logs: `storage/logs/laravel.log`

### Frontend Issues
Run: `flutter logs`

### Integration Issues
Check: [INTEGRATION_CHECKLIST.md](INTEGRATION_CHECKLIST.md)

---

## 📄 License

AgriConnect © 2024

---

**Status**: ✅ Ready for Development  
**Last Updated**: 2024-01-15  
**Version**: v1.0.0

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
