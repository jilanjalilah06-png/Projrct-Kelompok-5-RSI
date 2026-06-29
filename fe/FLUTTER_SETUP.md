# Flutter Frontend Setup & Connection Guide

## Status: ✅ Frontend Configured & Ready

### Prerequisites
- Flutter SDK 3.11.4+ installed
- Dart 3.11.4+ (comes with Flutter)
- Backend API running on http://127.0.0.1:8000 (or your PC's IP)
- IDE: VS Code, Android Studio, or Xcode

### Quick Start

```bash
cd ch1/fe

# 1. Get dependencies
flutter pub get

# 2. Update API endpoint in code (see Configuration section)

# 3. Run app
flutter run
```

### Configuration

#### Step 1: Update API Constants

File: `lib/core/constanst/api_constants.dart`

**For Desktop App (Windows/macOS/Linux):**
```dart
static const String _host = 'http://127.0.0.1:8000';
```

**For Android Emulator:**
```dart
static const String _host = 'http://10.0.2.2:8000';
```

**For iOS Simulator:**
```dart
static const String _host = 'http://127.0.0.1:8000';
```

**For Physical Device:**
First, find your PC's IP:
```bash
# Windows (PowerShell)
ipconfig
# Look for IPv4 Address under your network adapter

# macOS/Linux
ifconfig
# Look for inet address
```

Then update:
```dart
static const String _host = 'http://192.168.1.5:8000';  // Replace with your IP
```

#### Step 2: Verify Backend is Running

Backend should be running on the configured URL:
```bash
# Check if backend is accessible
curl http://127.0.0.1:8000/api/auth/login
# Or from browser: http://127.0.0.1:8000/api/auth/login
```

### Running the App

**Desktop (Windows/macOS/Linux):**
```bash
flutter run
# Then press 'd' for chrome, 'w' for windows, 'm' for macos
```

**Android Emulator:**
```bash
# First ensure emulator is running
flutter emulators
flutter run

# Or with specific device
flutter devices
flutter run -d <device_id>
```

**iOS Simulator (macOS only):**
```bash
open -a Simulator
flutter run
```

**Physical Device (Android/iOS):**
```bash
# Enable USB debugging on device
flutter devices
flutter run -d <device_id>
```

### Test Login

Use these credentials to test the app:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@agriconnect.com | password123 |
| Petani (Seller) | budi@agriconnect.com | password123 |
| Pembeli (Buyer) | aryo@email.com | password123 |

**Steps:**
1. Launch the app
2. Select your role (Admin, Petani, or Pembeli)
3. Enter email and password from table above
4. Click Login
5. You should be logged in and redirected to the role-specific dashboard

### Key Files

**API Communication:**
- `lib/data/services/api_service.dart` - HTTP client with JWT token handling
- `lib/data/repositories/auth_repository.dart` - Authentication logic
- `lib/presentation/controllers/auth_controller.dart` - State management

**Configuration:**
- `lib/core/constanst/api_constants.dart` - Backend URL and endpoints
- `pubspec.yaml` - Dependencies

**Pages:**
- `lib/presentation/pages/shared/user_login_screen.dart` - Login UI
- `lib/presentation/pages/admin/` - Admin dashboard
- `lib/presentation/pages/petani/` - Petani/Seller dashboard
- `lib/presentation/pages/pembeli/` - Pembeli/Buyer dashboard

### Dependencies

Main packages used:
- `provider: ^6.1.5+1` - State management
- `http: ^1.2.2` - HTTP client
- `google_fonts: ^6.2.1` - Custom fonts
- `cupertino_icons: ^1.0.8` - iOS-style icons

Install/Update:
```bash
flutter pub get
flutter pub upgrade
```

### How Authentication Works

1. **Login Request:**
   - User enters email and password
   - App sends POST to `/api/auth/login`
   - Backend validates and returns JWT token + user data

2. **Token Storage:**
   - Token stored in `ApiService._token`
   - Token added to all subsequent requests in Authorization header: `Bearer <token>`

3. **Session Management:**
   - Auto-logout after 2 hours of inactivity
   - Token refreshed on every API call
   - Can manually logout via `/api/auth/logout`

4. **Role-Based Navigation:**
   - Login response includes user role
   - App routes to role-specific dashboard:
     - Admin → Admin dashboard
     - Petani → Seller dashboard
     - Pembeli → Buyer dashboard

### Troubleshooting

**"Connection refused" Error:**
- ✓ Backend is not running or wrong URL in `api_constants.dart`
- Solution: Start backend with `php artisan serve --host=0.0.0.0 --port=8000`

**"Invalid credentials" Error:**
- ✓ Check email and password are correct
- Solution: Use test credentials from table above

**CORS Error in Browser Console:**
- ✓ Backend CORS not configured (unlikely, already configured)
- Solution: Backend has `CORS::class` middleware enabled

**Blank Page or Crash:**
- ✓ Dependency issue
- Solution: Run `flutter pub get` and `flutter clean`

**Slow Login:**
- ✓ Network latency or slow backend
- Solution: Check PC IP is correct, ensure devices on same network

**Android Emulator Cannot Connect to Backend:**
- ✓ Using wrong IP (127.0.0.1 doesn't work in emulator)
- Solution: Use `http://10.0.2.2:8000` in `api_constants.dart`

### Development Workflow

```bash
# Watch for changes and rebuild
flutter run

# Run with detailed logging
flutter run -v

# Run tests
flutter test

# Build APK for Android
flutter build apk --release

# Build for other platforms
flutter build ios
flutter build windows
flutter build web
```

### Network Requirements

For **physical device** to connect to backend:
1. Both PC and device must be on **same WiFi network**
2. Find PC's IP: `ipconfig` (look for IPv4 address like 192.168.x.x)
3. Update `api_constants.dart` with that IP
4. Ensure Windows Firewall allows port 8000:
   - Or disable firewall for testing
   - Or configure firewall rule for port 8000

### Next Steps

1. ✓ Update `api_constants.dart` with correct backend URL
2. ✓ Ensure backend is running
3. ✓ Run `flutter pub get` to install dependencies
4. ✓ Run `flutter run` to start the app
5. ✓ Login with test credentials
6. ✓ Test role-specific dashboards
