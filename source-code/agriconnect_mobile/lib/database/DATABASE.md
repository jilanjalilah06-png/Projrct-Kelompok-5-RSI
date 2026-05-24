# AgriConnect Database Documentation

## 📋 Struktur Database

Database SQLite lokal menyimpan data offline-first dengan kemampuan sync ke server. Semua data disimpan dengan ISO 8601 datetime format.

### Dependency
```yaml
dependencies:
  sqflite: ^2.3.3
  path: ^1.9.0
  sqflite_common_ffi: ^2.3.3  # untuk unit test desktop
```

---

## 📊 Skema Tabel

### 1. **USERS** - Data Akun Pengguna
Menyimpan data pengguna yang sedang login
```
id, nama, email, no_hp, lokasi, role, active, created_at, updated_at, synced_at
```

### 2. **KOMODITAS** - Master Data Komoditas
Data referensi komoditas (disync dari server)
```
id, nama_komoditas, siklus_hari_default, satuan, deskripsi, active, updated_at, synced_at
```

### 3. **JADWAL_TANAM** - Rencana Tanam
Catatan jadwal tanam untuk setiap lahan/musim
```
id, server_id, user_id, komoditas_id, tgl_tanam, luas_lahan_ha, 
tgl_panen_estimasi, tgl_panen_aktual, status, catatan, 
is_deleted, created_at, updated_at, synced_at, is_dirty
```

### 4. **HASIL_PANEN** - Data Panen Aktual
Catatan hasil panen dengan foto dan kualitas
```
id, server_id, user_id, jadwal_tanam_id, komoditas_id, tgl_panen, 
jumlah, satuan, kualitas, foto_path, foto_server_path, catatan, 
is_deleted, created_at, updated_at, synced_at, is_dirty
```

### 5. **BIAYA_PRODUKSI** - Pencatatan Biaya
Kategori: bibit | pupuk | pestisida | tenaga_kerja | lainnya
```
id, server_id, jadwal_tanam_id, kategori, nama_item, jumlah_rp, 
catatan, created_at, updated_at, synced_at, is_dirty
```

### 6. **HARGA_KOMODITAS** - Harga Referensi (Read-Only)
Data harga dari server untuk analisis
```
id, komoditas_id, harga_rp, satuan, tgl_berlaku, tren, catatan, 
updated_at, synced_at
```

### 7. **STOK_JUAL** - Penawaran Jual
Stok komoditas yang ditawarkan (privat/publik)
```
id, server_id, user_id, komoditas_id, jumlah_tersedia, satuan, 
harga_tawar_rp, deskripsi, lokasi_jual, foto_path, foto_server_path, 
publik, tgl_tersedia, is_deleted, created_at, updated_at, synced_at, is_dirty
```

### 8. **TRANSAKSI_JUAL** - Riwayat Transaksi
Catatan penjualan
```
id, server_id, stok_jual_id, nama_pembeli, kontak_pembeli, jumlah_terjual, 
satuan, harga_unit_rp, total_rp, tgl_transaksi, catatan, 
created_at, updated_at, synced_at, is_dirty
```

### 9. **NOTIFIKASI_LOKAL** - Notifikasi Jadwal
Jadwal notifikasi H-7 / H-1 sebelum panen
```
id, jadwal_tanam_id, tipe, judul, pesan, tgl_kirim, sudah_dikirim, created_at
```

### 10. **SYNC_LOG** - Log Sinkronisasi
Riwayat operasi offline/online
```
id, tabel, operasi, record_id, status, error_msg, created_at, synced_at
```

---

## 🚀 Cara Menggunakan

### 1. Inisialisasi Database
```dart
import 'package:agriconnect_mobile/database/database_helper.dart';

void main() {
  // Database akan otomatis diinisialisasi saat pertama kali diakses
  runApp(MyApp());
}
```

### 2. Insert Data
```dart
import 'package:agriconnect_mobile/models/index.dart';

final dbHelper = DatabaseHelper.instance;

// Contoh insert jadwal tanam
var jadwal = JadwalTanamModel(
  userId: 1,
  komoditasId: 1,
  tglTanam: '2026-05-15',
  tglPanenEstimasi: '2026-08-13',
  createdAt: DateTime.now().toIso8601String(),
  updatedAt: DateTime.now().toIso8601String(),
);

int id = await dbHelper.insert('jadwal_tanam', jadwal.toMap());
```

### 3. Query Data
```dart
// Ambil semua jadwal aktif user
List<Map<String, dynamic>> jadwals = 
  await dbHelper.getJadwalAktif(userId: 1);

// Konversi ke model
List<JadwalTanamModel> jadwalList = 
  jadwals.map((j) => JadwalTanamModel.fromMap(j)).toList();
```

### 4. Update Data
```dart
await dbHelper.update(
  'jadwal_tanam',
  {'status': 'selesai', 'is_dirty': 1},
  where: 'id = ?',
  whereArgs: [jadwalId],
);
```

### 5. Soft Delete (recommended)
```dart
// Tandai record sebagai terhapus tanpa menghapus fisik
await dbHelper.softDelete('jadwal_tanam', jadwalId);
```

### 6. Hard Delete (careful)
```dart
// Hapus record secara fisik dari database
await dbHelper.hardDelete('jadwal_tanam', jadwalId);
```

---

## 🔄 Offline-First Sync Pattern

### is_dirty Flag
- `is_dirty = 1` → Record belum disink ke server, perlu dikirim
- `is_dirty = 0` → Record sudah disink ke server

### server_id
- `NULL` → Record lokal belum pernah disink
- `integer` → ID record di MySQL server setelah sync berhasil

### Workflow Sync
```dart
// 1. Ambil data yang perlu disink
List<Map> dirtyRecords = await dbHelper.getDirtyRecords('jadwal_tanam');

// 2. Kirim ke server (contoh: POST API)
for (var record in dirtyRecords) {
  try {
    var response = await api.post('/jadwal-tanam', record);
    int serverId = response['id'];
    
    // 3. Tandai sudah disink
    await dbHelper.markSynced('jadwal_tanam', record['id'], serverId);
  } catch (e) {
    // Catat error di sync_log
    print('Sync failed: $e');
  }
}
```

---

## 📸 Foto & File Lokal

### Menyimpan Path Foto
```dart
final panenModel = HasilPanenModel(
  userId: 1,
  komoditasId: 1,
  jadwalTanamId: 1,
  tglPanen: '2026-08-13',
  jumlah: 500.0,
  fotoPath: '/path/to/local/photo.jpg',  // Path lokal
  fotoServerPath: null,                   // Diisi setelah upload
  // ...
);
```

### Workflow Upload Foto
1. Simpan file ke direktori lokal: `/data/user/{userId}/fotos/`
2. Isi `foto_path` dengan path lokal
3. Saat sync: upload file ke server, dapatkan URL
4. Isi `foto_server_path` dengan URL dari server
5. Set `is_dirty = 0`

---

## 📊 Query Khusus yang Tersedia

### 1. Jadwal Aktif
```dart
List<Map> activeSchedules = await dbHelper.getJadwalAktif(userId);
// Returns: jadwal dengan status "aktif" dan not deleted, joined dengan komoditas
```

### 2. Ringkasan Keuangan
```dart
Map<String, dynamic>? summary = await dbHelper.getRingkasanKeuangan(jadwalId);
// Returns: {total_modal, total_pendapatan, keuntungan_bersih}
```

### 3. Harga Terbaru
```dart
List<Map> latestPrices = await dbHelper.getHargaTerbaru();
// Returns: harga komoditas terbaru dengan nama komoditas
```

### 4. Records Belum Disink
```dart
List<Map> dirty = await dbHelper.getDirtyRecords('jadwal_tanam');
// Returns: semua record dengan is_dirty = 1
```

---

## 🔑 Foreign Keys & Constraints

Semua foreign keys diaktifkan dengan `PRAGMA foreign_keys = ON`

- **jadwal_tanam.user_id** → users.id (CASCADE DELETE)
- **jadwal_tanam.komoditas_id** → komoditas.id (RESTRICT DELETE)
- **hasil_panen.user_id** → users.id (CASCADE DELETE)
- **hasil_panen.jadwal_tanam_id** → jadwal_tanam.id (SET NULL)
- **hasil_panen.komoditas_id** → komoditas.id (RESTRICT DELETE)
- **biaya_produksi.jadwal_tanam_id** → jadwal_tanam.id (CASCADE DELETE)
- **stok_jual.user_id** → users.id (CASCADE DELETE)
- **stok_jual.komoditas_id** → komoditas.id (RESTRICT DELETE)
- **transaksi_jual.stok_jual_id** → stok_jual.id (RESTRICT DELETE)

---

## ⚡ Performance Tips

### Indexes
Database sudah memiliki indexes untuk field yang sering diquery:
- `idx_jadwal_user` - query by user
- `idx_jadwal_status` - filter by status
- `idx_panen_tgl` - sort by harvest date
- `idx_stok_publik` - filter public stok
- `idx_sync_status` - find pending syncs

### Pagination
```dart
List<Map> page1 = await dbHelper.queryAll(
  'jadwal_tanam',
  limit: 10,
  offset: 0,
);

List<Map> page2 = await dbHelper.queryAll(
  'jadwal_tanam',
  limit: 10,
  offset: 10,
);
```

### Batch Operations
```dart
final db = await dbHelper.database;
await db.transaction((txn) async {
  await txn.insert('jadwal_tanam', data1);
  await txn.insert('jadwal_tanam', data2);
  await txn.update('komoditas', data3, where: 'id = ?', whereArgs: [1]);
});
```

---

## 🔐 Database Security

### Tidak ada data sensitif di SQLite lokal
- Password tersimpan di secure storage (flutter_secure_storage)
- Token API disimpan di memory atau secure storage
- Database bersifat offline-first, sync hanya data non-sensitif

### Enkripsi (Optional)
Untuk production, gunakan `sqflite_sqlcipher`:
```yaml
dependencies:
  sqflite_sqlcipher: ^2.2.0
```

---

## 📝 Database Upgrade

### Menambah kolom baru (v1 → v2)
```dart
// Di method _onUpgrade:
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE hasil_panen ADD COLUMN cuaca TEXT');
  }
}

// Kemudian ubah _dbVersion = 2
```

---

## 🆘 Troubleshooting

### Database locked
- Tutup semua connection sebelum upload: `await dbHelper.close()`
- Hindari concurrent writes di transaction

### Foreign key constraint failed
- Pastikan record parent sudah ada sebelum insert child
- Gunakan `is_dirty = 0` untuk mark as synced

### Foto tidak terupload
- Periksa path file lokal valid
- Pastikan user memiliki permission READ_EXTERNAL_STORAGE / WRITE_EXTERNAL_STORAGE
- Upload file terpisah dari database sync

---

## 📚 Contoh Implementasi Lengkap

```dart
// lib/services/jadwal_service.dart
import 'package:agriconnect_mobile/database/database_helper.dart';
import 'package:agriconnect_mobile/models/index.dart';

class JadwalService {
  final dbHelper = DatabaseHelper.instance;

  // Buat jadwal tanam baru
  Future<int> createJadwal(JadwalTanamModel jadwal) async {
    return await dbHelper.insert('jadwal_tanam', jadwal.toMap());
  }

  // Ambil jadwal aktif user
  Future<List<JadwalTanamModel>> getJadwalAktif(int userId) async {
    final results = await dbHelper.getJadwalAktif(userId);
    return results.map((j) => JadwalTanamModel.fromMap(j)).toList();
  }

  // Update status jadwal
  Future<void> updateStatus(int jadwalId, String newStatus) async {
    await dbHelper.update(
      'jadwal_tanam',
      {
        'status': newStatus,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [jadwalId],
    );
  }

  // Hapus jadwal
  Future<void> deleteJadwal(int jadwalId) async {
    await dbHelper.softDelete('jadwal_tanam', jadwalId);
  }
}
```

---

## 📞 Version & Support
- **Database Version**: 1.2
- **Last Updated**: May 2026
- **Supported**: Flutter 3.11.1+
- **Platforms**: Android 8.0+, iOS 11+, Web, Windows, macOS, Linux

