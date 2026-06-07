# AgriConnect Mobile (Kelompok 5 - RSI)

Aplikasi Flutter untuk manajemen pertanian yang menghubungkan petani dengan pembeli.

## Fitur Utama
- **Manajemen Jadwal Tanam**: Pencatatan rencana dan hasil tanam
- **Tracking Panen**: Dokumentasi hasil panen dengan foto
- **Catatan Biaya**: Pencatatan modal produksi
- **Stok Jual**: Penawaran produk (privat/publik)
- **Transaksi**: Riwayat penjualan dan pembeli
- **Offline-First**: Bekerja tanpa internet, sync otomatis saat online

## Teknologi
- **Frontend**: Flutter 3.11.1+
- **Database**: SQLite (sqflite)
- **Architecture**: Offline-first dengan sync pattern
- **Platform**: Android 8.0+, iOS, Web

## Setup Project

### Prerequisites
- Flutter 3.11.1 atau lebih baru
- Dart 3.7.0 atau lebih baru

### Installation

```bash
# Clone repository
git clone https://github.com/jilanjalilah06-png/Projrct-Kelompok-5-RSI.git
cd agriconnect_mobile

# Get dependencies
flutter pub get

# Run app
flutter run
```

## Project Structure

```
agriconnect_mobile/
├── lib/
│   ├── database/
│   │   ├── database_helper.dart      # SQLite helper & schema
│   │   └── DATABASE.md               # Database documentation
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── komoditas_model.dart
│   │   ├── jadwal_tanam_model.dart
│   │   ├── hasil_panen_model.dart
│   │   ├── stok_jual_model.dart
│   │   └── index.dart
│   ├── main.dart
│   └── ...
├── pubspec.yaml
└── README.md
```

## Database Schema
Database mencakup 10 tabel:
1. **users** - Data pengguna
2. **komoditas** - Master komoditas
3. **jadwal_tanam** - Rencana tanam
4. **hasil_panen** - Data panen
5. **biaya_produksi** - Catatan biaya
6. **harga_komoditas** - Referensi harga
7. **stok_jual** - Penawaran jual
8. **transaksi_jual** - Riwayat transaksi
9. **notifikasi_lokal** - Notifikasi jadwal
10. **sync_log** - Log sinkronisasi

Lihat [DATABASE.md](lib/database/DATABASE.md) untuk dokumentasi lengkap.

## Development

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test
```

## Status Project
- [x] Database Schema (Issue #29)
- [ ] Backend API Setup
- [ ] Frontend UI Development
- [ ] Integration Testing

Lihat [Issues](https://github.com/jilanjalilah06-png/Projrct-Kelompok-5-RSI/issues) untuk task lengkap.

## Team (Kelompok 5 - RSI)
Pengumpulan setiap tugas perorang

## Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Project Board](https://github.com/jilanjalilah06-png/Projrct-Kelompok-5-RSI/projects/1)
