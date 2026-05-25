# AGRICONNECT - Login & Register Setup Guide

## Overview
Sistem login dan register telah berhasil ditambahkan ke aplikasi AGRICONNECT Flutter. Berikut ini adalah panduan lengkap untuk menggunakan dan mengembangkan fitur authentication.

## File yang Telah Dibuat

### 1. Screens (UI)
- **`lib/screens/login_screen.dart`** - Halaman login dengan validasi form
- **`lib/screens/register_screen.dart`** - Halaman register dengan pilihan role (Petani/Pedagang)
- **`lib/screens/home_screen.dart`** - Halaman home (placeholder)

### 2. Services (Business Logic)
- **`lib/services/auth_service.dart`** - Service untuk komunikasi dengan backend API
  - `login(email, password)` - Login user
  - `register(nama, email, noHp, password, role)` - Register user baru
  - `logout(token)` - Logout user
  - `verifyToken(token)` - Verifikasi token

- **`lib/services/token_service.dart`** - Service untuk menyimpan/mengambil token lokal
  - `saveToken(token)` - Simpan token ke database lokal
  - `getToken()` - Ambil token dari database lokal
  - `deleteToken()` - Hapus token
  - `hasToken()` - Cek apakah token ada

### 3. Main App
- **`lib/main.dart`** - Updated dengan routing ke login, register, dan home screens

## Dependencies yang Ditambahkan

```yaml
http: ^1.1.0  # Untuk HTTP requests ke backend
```

## Cara Menggunakan

### 1. Login Screen
```dart
// User memasukkan email dan password
// Aplikasi akan:
// - Validasi input
// - Send request ke backend (127.0.0.1:8000/login)
// - Simpan token ke local database
// - Navigate ke halaman berikutnya
```

**Endpoint Backend:** `POST /login`
```json
{
  "email": "user@email.com",
  "password": "password123"
}
```

### 2. Register Screen
```dart
// User mengisi form:
// - Nama Lengkap
// - Email
// - No. HP
// - Role (Petani/Pedagang)
// - Password (min 8 karakter)
// - Confirm Password
```

**Endpoint Backend:** `POST /register`
```json
{
  "nama": "Nama User",
  "email": "user@email.com",
  "no_hp": "08123456789",
  "password": "password123",
  "role": "petani"
}
```

## Fitur-Fitur

✅ **Login Screen:**
- Email validation
- Password visibility toggle
- Loading indicator
- Error message display
- Navigate ke Register page
- Forgot password link (placeholder)

✅ **Register Screen:**
- Nama field validation
- Email validation
- No. HP validation
- Role selection dropdown (Petani/Pedagang)
- Password strength requirement (min 8 chars)
- Password confirmation match
- Loading indicator
- Error message display
- Navigate ke Login page

✅ **Authentication Service:**
- HTTP requests ke backend
- Timeout handling (10 detik)
- Error handling
- Token management
- User verification

✅ **Token Service:**
- Simpan token ke SQLite database lokal
- Retrieve token
- Delete token
- Check token existence

## Konfigurasi Backend URL

Saat ini backend dikonfigurasi di `lib/services/auth_service.dart`:
```dart
static const String baseUrl = 'http://127.0.0.1:8000';
```

Jika backend berada di host/port berbeda, ubah URL ini.

## Next Steps

### 1. Setup Authentication State Management
Untuk production, tambahkan state management (Provider, Bloc, atau Riverpod):

```dart
// Contoh dengan Provider
class AuthProvider extends ChangeNotifier {
  String? _token;
  UserModel? _user;

  bool get isAuthenticated => _token != null;
  
  Future<void> login(String email, String password) async {
    // ...
  }
}
```

### 2. Setup Navigation Guard
Untuk auto-redirect ke login jika token tidak ada:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasToken = await TokenService.hasToken();
  
  runApp(MyApp(initialRoute: hasToken ? '/home' : '/login'));
}
```

### 3. Uncomment Navigation di Login Screen
Saat ini navigasi ke home page di-comment. Uncomment ketika home page ready:

```dart
// Di lib/screens/login_screen.dart, baris ~48
Navigator.of(context).pushReplacementNamed('/home');
```

### 4. Implementasi Logout
Update home screen dengan logout logic:

```dart
Future<void> _handleLogout() async {
  final token = await TokenService.getToken();
  if (token != null) {
    await AuthService().logout(token: token);
    await TokenService.deleteToken();
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
```

### 5. Tambahkan Validasi di Home Screen
Cek token saat app dibuka:

```dart
@override
void initState() {
  super.initState();
  _verifyToken();
}

Future<void> _verifyToken() async {
  final token = await TokenService.getToken();
  if (token != null) {
    final result = await AuthService().verifyToken(token: token);
    if (!result['success']) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
```

## Testing

### 1. Login Test
1. Buka aplikasi
2. Klik tombol "Daftar" untuk pergi ke register page
3. Isi form register
4. Klik "Buat Akun"
5. Jika berhasil, akan redirect ke login page
6. Gunakan kredensial yang baru dibuat untuk login
7. Cek di browser bahwa user berhasil terdaftar di `127.0.0.1:8000/register`

### 2. Error Handling Test
- Test dengan email tidak valid
- Test dengan password kosong
- Test dengan no. HP kurang dari 10 digit
- Test koneksi server gagal (matikan backend server)

## Struktur Database

### Tokens Table (SQLite)
```
id (INTEGER PRIMARY KEY)
token (TEXT)
user_id (INTEGER)
created_at (TEXT)
```

## Important Notes

⚠️ **Keamanan:**
- Jangan commit token ke version control
- Implementasi refresh token mechanism untuk production
- Hash password di backend (pastikan sudah dilakukan)
- Gunakan HTTPS untuk production

⚠️ **Backend Requirements:**
- Server harus berjalan di `127.0.0.1:8000`
- Endpoints: `/login`, `/register`, `/logout`, `/user` harus tersedia
- Response harus dalam JSON format

## Troubleshooting

### "Gagal terhubung ke server"
- Pastikan backend sedang berjalan
- Cek URL backend di `auth_service.dart`
- Pastikan emulator/device bisa akses localhost

### "Registrasi gagal"
- Cek format data yang dikirim
- Pastikan email belum terdaftar
- Lihat response dari backend di Android Studio console

### Token tidak tersimpan
- Pastikan `token_service.dart` terinisialisasi dengan benar
- Cek permissions di `AndroidManifest.xml` untuk database access

## Support

Untuk pertanyaan lebih lanjut, silakan lihat:
- Flutter documentation: https://flutter.dev/docs
- HTTP package: https://pub.dev/packages/http
- SQLite dengan sqflite: https://pub.dev/packages/sqflite
