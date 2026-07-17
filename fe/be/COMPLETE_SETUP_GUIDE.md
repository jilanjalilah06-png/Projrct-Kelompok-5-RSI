# AgriConnect Platform - Complete Setup Guide

## 🚀 Quick Start (5 minutes)

### Start Backend
```bash
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000
# Output: INFO  Server running on [http://0.0.0.0:8000]
```

### Start Frontend (in separate terminal/tab)
```bash
cd ch1/fe
flutter run
# Select your target platform: w (Windows), d (Chrome), a (Android), etc.
```

### Test Login
- **Email:** admin@agriconnect.com
- **Password:** password123
- **Role:** Admin

---

## 📋 What's Already Fixed

### ✅ Backend
- ✅ Database migrations completed and seeded with test data
- ✅ JWT authentication configured and verified working
- ✅ CORS enabled for cross-origin requests
- ✅ All API endpoints operational
- ✅ Test users created with proper roles

### ✅ Frontend
- ✅ Flutter app configured with Provider state management
- ✅ API service setup with JWT token handling
- ✅ Login screens for all roles (Admin, Petani, Pembeli)
- ✅ Role-based navigation implemented
- ✅ Auto-logout after 2 hours of inactivity

---

## 🔧 Configuration

### Backend Configuration

**File:** `ch1/be/.env`

Key settings (already configured):
```env
APP_NAME=AgriConnect
APP_URL=http://localhost:8000
DB_CONNECTION=sqlite
DB_DATABASE=database/database.sqlite
JWT_SECRET=Q5TwDY46odoKYbVmZnjU9gEXSj9XRKuErQiVstTrtl9BlBgggzNYvRcby7yhielx
JWT_ALGORITHM=HS256
```

### Frontend Configuration

**File:** `ch1/fe/lib/core/constanst/api_constants.dart`

Choose your setup:

```dart
// For Local PC / Desktop App
static const String _host = 'http://127.0.0.1:8000';

// For Android Emulator
static const String _host = 'http://10.0.2.2:8000';

// For iOS Simulator
static const String _host = 'http://127.0.0.1:8000';

// For Physical Device (replace with your PC IP)
static const String _host = 'http://192.168.1.5:8000';
```

**How to find PC IP for Physical Device:**

Windows (PowerShell):
```powershell
ipconfig
# Look for: IPv4 Address... : 192.168.x.x
```

macOS/Linux:
```bash
ifconfig
# Look for: inet 192.168.x.x
```

---

## 📱 Different Setup Scenarios

### Scenario 1: Desktop Testing (Windows/macOS/Linux)

```bash
# Terminal 1 - Backend
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 - Frontend (Windows)
cd ch1/fe
flutter run
# Select: w (Windows)
# OR: d (Chrome) for web

# Terminal 2 - Frontend (macOS)
cd ch1/fe
flutter run
# Select: m (macOS)

# Terminal 2 - Frontend (Linux)
cd ch1/fe
flutter run
# Select: l (Linux)
```

Login with:
- Email: `admin@agriconnect.com`
- Password: `password123`

---

### Scenario 2: Android Emulator

```bash
# Terminal 1 - Start emulator
flutter emulators
flutter emulators launch Pixel_4_API_30  # or your emulator name

# Terminal 2 - Backend
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 3 - Frontend
cd ch1/fe
# Update: lib/core/constanst/api_constants.dart
# Change _host to: 'http://10.0.2.2:8000'
flutter run
# Select: a (Android)
```

---

### Scenario 3: iOS Simulator (macOS only)

```bash
# Terminal 1 - Start simulator
open -a Simulator

# Terminal 2 - Backend
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 3 - Frontend
cd ch1/fe
# Ensure: lib/core/constanst/api_constants.dart
# _host = 'http://127.0.0.1:8000'
flutter run
# Select: i (iOS)
```

---

### Scenario 4: Physical Android Device

```bash
# Step 1: Enable USB Debugging on Phone
# Settings > Developer Options > Enable USB Debugging

# Step 2: Connect phone via USB

# Step 3: Terminal 1 - Check connection
flutter devices
# You should see your device listed

# Step 4: Terminal 2 - Backend
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000

# Step 5: Get your PC IP
ipconfig
# Note the IPv4 address (e.g., 192.168.1.5)

# Step 6: Terminal 3 - Update frontend
cd ch1/fe
# Edit: lib/core/constanst/api_constants.dart
# Change: static const String _host = 'http://192.168.1.5:8000';

# Step 7: Run app
flutter run -d <device_id>
```

Make sure:
- PC and phone are on **same WiFi network**
- Windows Firewall allows port 8000 (or temporarily disable it)

---

## 🧪 Test Accounts

All passwords: `password123`

### Administrators
| Email | Password | Role |
|-------|----------|------|
| admin@agriconnect.com | password123 | Admin |

### Sellers (Petani)
| Email | Password | Role |
|-------|----------|------|
| budi@agriconnect.com | password123 | Petani |
| siti@agriconnect.com | password123 | Petani |
| rahmat@agriconnect.com | password123 | Petani |
| dewi@agriconnect.com | password123 | Petani |

### Buyers (Pembeli)
| Email | Password | Role |
|-------|----------|------|
| aryo@email.com | password123 | Pembeli |
| lina@email.com | password123 | Pembeli |
| riko@email.com | password123 | Pembeli |

---

## 🔍 Testing the API Directly

### Test Login Endpoint

**Windows PowerShell:**
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

**Output (should look like):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "Admin User",
      "email": "admin@agriconnect.com",
      "role": "Admin"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

### Test with Token

Use the token from login in subsequent requests:

```powershell
$token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

Invoke-WebRequest -Uri "http://127.0.0.1:8000/api/auth/me" `
    -Headers @{ "Authorization" = "Bearer $token" } `
    -UseBasicParsing | Select-Object -ExpandProperty Content
```

---

## ⚠️ Common Issues & Solutions

### Issue: "Connection refused" Error in Flutter App

**Cause:** Backend not running or wrong URL

**Solution:**
```bash
# 1. Check backend is running
curl http://127.0.0.1:8000/api/auth/login

# 2. If not, start it
cd ch1/be
php artisan serve --host=0.0.0.0 --port=8000

# 3. Verify correct URL in api_constants.dart
# For desktop: http://127.0.0.1:8000
# For emulator: http://10.0.2.2:8000
# For device: http://<your-pc-ip>:8000
```

---

### Issue: "Invalid credentials" in Login

**Cause:** Wrong email or password

**Solution:**
```
Use exact credentials from Test Accounts section above
Email: admin@agriconnect.com (case-sensitive)
Password: password123
```

---

### Issue: Port 8000 Already in Use

**Cause:** Another process using port 8000

**Solution (Windows):**
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# Kill that process (replace PID with the process ID)
taskkill /PID 1234 /F

# Then start backend again
php artisan serve --host=0.0.0.0 --port=8000
```

---

### Issue: Physical Device Can't Connect to Backend

**Causes & Solutions:**

1. **Different networks:**
   ```
   ✓ Ensure PC and device on SAME WiFi
   ```

2. **Wrong IP address:**
   ```powershell
   # Get PC IP
   ipconfig
   # Update api_constants.dart with correct IP
   ```

3. **Firewall blocking:**
   ```
   ✓ Temporarily disable Windows Firewall
   OR
   ✓ Add port 8000 to firewall exceptions
   ```

---

### Issue: Android Emulator Can't Connect to Backend

**Cause:** Using localhost (127.0.0.1) in emulator

**Solution:**
```dart
// Android emulator sees host PC at 10.0.2.2
static const String _host = 'http://10.0.2.2:8000';
```

---

### Issue: Flutter Dependency Error

**Solution:**
```bash
cd ch1/fe
flutter clean
flutter pub get
flutter pub upgrade
```

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                 Flutter App (FE)                 │
│  ┌──────────────────────────────────────────┐   │
│  │  UI (Login, Dashboard, etc.)             │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  AuthController (Provider State Mgmt)    │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  AuthRepository (Business Logic)         │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  ApiService (HTTP + JWT Token)           │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────┬──────────────────────────┘
                      │
        HTTP Request (POST /api/auth/login)
        JWT Token in Authorization header
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│          Laravel API (BE)                        │
│  ┌──────────────────────────────────────────┐   │
│  │  API Routes (/api/auth/*, /api/...)      │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  AuthController (Validate, JWT Return)   │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  User Model (Database Queries)           │   │
│  └──────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────┐   │
│  │  SQLite Database                         │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## 📚 Key Features

### Authentication Flow
1. User enters email/password in Flutter app
2. App sends POST to backend `/api/auth/login`
3. Backend validates credentials against database
4. Backend returns JWT token + user data
5. App stores token and includes in all future requests
6. Protected endpoints require valid JWT token

### Role-Based Navigation
- **Admin:** Admin dashboard with system management
- **Petani (Seller):** Seller dashboard to manage shop and products
- **Pembeli (Buyer):** Buyer dashboard to browse and purchase

### Session Management
- Auto-logout after 2 hours of inactivity
- Manual logout option available
- Token refresh on each API call
- Secure token storage in app memory

---

## 🎯 Next Steps

1. ✅ Start backend server
2. ✅ Update Flutter app configuration if needed
3. ✅ Run Flutter app
4. ✅ Login with test account
5. ✅ Explore role-specific dashboards
6. ✅ Test API endpoints
7. ✅ Ready for production deployment!

---

## 📞 Support

If you encounter issues:
1. Check COMMON ISSUES section above
2. Verify backend is running: `curl http://127.0.0.1:8000/api/auth/login`
3. Check network connectivity between devices
4. Review error messages in Flutter console (`flutter run -v`)
5. Check Laravel logs: `storage/logs/laravel.log`
