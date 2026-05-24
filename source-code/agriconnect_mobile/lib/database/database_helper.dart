// ============================================================
// AgriConnect - Database Schema (SQLite / Flutter)
// Package   : sqflite ^2.3.3  +  path ^1.9.0
// Platform  : Flutter (Android 8.0+)
// Versi SRS : 1.2 | May 2026
// File      : lib/database/database_helper.dart
// ============================================================
//
// DEPENDENCY (pubspec.yaml):
//   dependencies:
//     sqflite: ^2.3.3
//     path: ^1.9.0
//     sqflite_common_ffi: ^2.3.3   # untuk unit test desktop
// ============================================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  // ── Versi database: increment saat ada perubahan schema ──
  static const int _dbVersion = 1;
  static const String _dbName = 'agriconnect_local.db';

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  // Aktifkan foreign key support di SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // ============================================================
  // BUAT SEMUA TABEL
  // ============================================================
  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {

      // ----------------------------------------------------------
      // 1. USERS  (data akun yang sedang login, disimpan lokal)
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id              INTEGER PRIMARY KEY,          -- sama dengan server ID
          nama            TEXT    NOT NULL,
          email           TEXT    NOT NULL UNIQUE,
          no_hp           TEXT    NOT NULL,
          lokasi          TEXT,
          role            TEXT    NOT NULL DEFAULT "user",
          active          INTEGER NOT NULL DEFAULT 1,
          created_at      TEXT    NOT NULL,
          updated_at      TEXT    NOT NULL,
          synced_at       TEXT                          -- waktu terakhir sync ke server
        )
      ''');

      // ----------------------------------------------------------
      // 2. KOMODITAS  (master data, di-sync dari server)
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS komoditas (
          id                    INTEGER PRIMARY KEY,
          nama_komoditas        TEXT    NOT NULL,
          siklus_hari_default   INTEGER NOT NULL DEFAULT 90,
          satuan                TEXT    NOT NULL DEFAULT "kg",
          deskripsi             TEXT,
          active                INTEGER NOT NULL DEFAULT 1,
          updated_at            TEXT    NOT NULL,
          synced_at             TEXT
        )
      ''');

      // ----------------------------------------------------------
      // 3. JADWAL_TANAM
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS jadwal_tanam (
          id                    INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id             INTEGER UNIQUE,         -- ID dari server setelah sync
          user_id               INTEGER NOT NULL,
          komoditas_id          INTEGER NOT NULL,
          tgl_tanam             TEXT    NOT NULL,       -- ISO 8601: YYYY-MM-DD
          luas_lahan_ha         REAL,
          tgl_panen_estimasi    TEXT    NOT NULL,
          tgl_panen_aktual      TEXT,
          status                TEXT    NOT NULL DEFAULT "aktif",
                                                        -- aktif | selesai | batal
          catatan               TEXT,
          is_deleted            INTEGER NOT NULL DEFAULT 0,  -- soft delete lokal
          created_at            TEXT    NOT NULL,
          updated_at            TEXT    NOT NULL,
          synced_at             TEXT,
          is_dirty              INTEGER NOT NULL DEFAULT 1,  -- 1 = belum sync
          FOREIGN KEY (user_id)      REFERENCES users(id)     ON DELETE CASCADE,
          FOREIGN KEY (komoditas_id) REFERENCES komoditas(id) ON DELETE RESTRICT
        )
      ''');

      // ----------------------------------------------------------
      // 4. HASIL_PANEN
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS hasil_panen (
          id                INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id         INTEGER UNIQUE,
          user_id           INTEGER NOT NULL,
          jadwal_tanam_id   INTEGER,
          komoditas_id      INTEGER NOT NULL,
          tgl_panen         TEXT    NOT NULL,
          jumlah            REAL    NOT NULL,
          satuan            TEXT    NOT NULL DEFAULT "kg",
          kualitas          TEXT    NOT NULL DEFAULT "standar",
                                                        -- premium | standar | afkir
          foto_path         TEXT,                       -- path lokal file foto
          foto_server_path  TEXT,                       -- path di server setelah upload
          catatan           TEXT,
          is_deleted        INTEGER NOT NULL DEFAULT 0,
          created_at        TEXT    NOT NULL,
          updated_at        TEXT    NOT NULL,
          synced_at         TEXT,
          is_dirty          INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (user_id)        REFERENCES users(id)        ON DELETE CASCADE,
          FOREIGN KEY (jadwal_tanam_id) REFERENCES jadwal_tanam(id) ON DELETE SET NULL,
          FOREIGN KEY (komoditas_id)   REFERENCES komoditas(id)    ON DELETE RESTRICT
        )
      ''');

      // ----------------------------------------------------------
      // 5. BIAYA_PRODUKSI
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS biaya_produksi (
          id                INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id         INTEGER UNIQUE,
          jadwal_tanam_id   INTEGER NOT NULL,
          kategori          TEXT    NOT NULL,
                                                        -- bibit|pupuk|pestisida|tenaga_kerja|lainnya
          nama_item         TEXT    NOT NULL,
          jumlah_rp         REAL    NOT NULL,
          catatan           TEXT,
          created_at        TEXT    NOT NULL,
          updated_at        TEXT    NOT NULL,
          synced_at         TEXT,
          is_dirty          INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (jadwal_tanam_id) REFERENCES jadwal_tanam(id) ON DELETE CASCADE
        )
      ''');

      // ----------------------------------------------------------
      // 6. HARGA_KOMODITAS  (read-only, di-sync dari server)
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS harga_komoditas (
          id            INTEGER PRIMARY KEY,
          komoditas_id  INTEGER NOT NULL,
          harga_rp      REAL    NOT NULL,
          satuan        TEXT    NOT NULL DEFAULT "kg",
          tgl_berlaku   TEXT    NOT NULL,
          tren          TEXT    NOT NULL DEFAULT "stabil",
                                                        -- naik | turun | stabil
          catatan       TEXT,
          updated_at    TEXT    NOT NULL,
          synced_at     TEXT,
          FOREIGN KEY (komoditas_id) REFERENCES komoditas(id) ON DELETE RESTRICT
        )
      ''');

      // ----------------------------------------------------------
      // 7. STOK_JUAL
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS stok_jual (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id       INTEGER UNIQUE,
          user_id         INTEGER NOT NULL,
          komoditas_id    INTEGER NOT NULL,
          jumlah_tersedia REAL    NOT NULL,
          satuan          TEXT    NOT NULL DEFAULT "kg",
          harga_tawar_rp  REAL    NOT NULL,
          deskripsi       TEXT,
          lokasi_jual     TEXT,
          foto_path       TEXT,
          foto_server_path TEXT,
          publik          INTEGER NOT NULL DEFAULT 0,   -- 0=privat, 1=publik
          tgl_tersedia    TEXT    NOT NULL,
          is_deleted      INTEGER NOT NULL DEFAULT 0,
          created_at      TEXT    NOT NULL,
          updated_at      TEXT    NOT NULL,
          synced_at       TEXT,
          is_dirty        INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (user_id)      REFERENCES users(id)     ON DELETE CASCADE,
          FOREIGN KEY (komoditas_id) REFERENCES komoditas(id) ON DELETE RESTRICT
        )
      ''');

      // ----------------------------------------------------------
      // 8. TRANSAKSI_JUAL
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS transaksi_jual (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          server_id       INTEGER UNIQUE,
          stok_jual_id    INTEGER NOT NULL,
          nama_pembeli    TEXT    NOT NULL,
          kontak_pembeli  TEXT,
          jumlah_terjual  REAL    NOT NULL,
          satuan          TEXT    NOT NULL DEFAULT "kg",
          harga_unit_rp   REAL    NOT NULL,
          total_rp        REAL    NOT NULL,             -- computed: jumlah * harga_unit
          tgl_transaksi   TEXT    NOT NULL,
          catatan         TEXT,
          created_at      TEXT    NOT NULL,
          updated_at      TEXT    NOT NULL,
          synced_at       TEXT,
          is_dirty        INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (stok_jual_id) REFERENCES stok_jual(id) ON DELETE RESTRICT
        )
      ''');

      // ----------------------------------------------------------
      // 9. NOTIFIKASI_LOKAL  (jadwal H-7 / H-1, disimpan lokal)
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS notifikasi_lokal (
          id              INTEGER PRIMARY KEY AUTOINCREMENT,
          jadwal_tanam_id INTEGER NOT NULL,
          tipe            TEXT    NOT NULL,             -- h7 | h1 | pemupukan
          judul           TEXT    NOT NULL,
          pesan           TEXT    NOT NULL,
          tgl_kirim       TEXT    NOT NULL,             -- tanggal notif dijadwalkan
          sudah_dikirim   INTEGER NOT NULL DEFAULT 0,
          created_at      TEXT    NOT NULL,
          FOREIGN KEY (jadwal_tanam_id) REFERENCES jadwal_tanam(id) ON DELETE CASCADE
        )
      ''');

      // ----------------------------------------------------------
      // 10. SYNC_LOG  (log operasi offline ↔ online)
      // ----------------------------------------------------------
      await txn.execute('''
        CREATE TABLE IF NOT EXISTS sync_log (
          id          INTEGER PRIMARY KEY AUTOINCREMENT,
          tabel       TEXT    NOT NULL,
          operasi     TEXT    NOT NULL,                 -- insert | update | delete
          record_id   INTEGER NOT NULL,
          status      TEXT    NOT NULL DEFAULT "pending",
                                                        -- pending | success | failed
          error_msg   TEXT,
          created_at  TEXT    NOT NULL,
          synced_at   TEXT
        )
      ''');

      // ----------------------------------------------------------
      // INDEX untuk performa query
      // ----------------------------------------------------------
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_jadwal_user      ON jadwal_tanam(user_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_jadwal_komoditas ON jadwal_tanam(komoditas_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_jadwal_status    ON jadwal_tanam(status)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_panen_user       ON hasil_panen(user_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_panen_tgl        ON hasil_panen(tgl_panen)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_biaya_jadwal     ON biaya_produksi(jadwal_tanam_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_harga_komoditas  ON harga_komoditas(komoditas_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_stok_publik      ON stok_jual(publik)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_transaksi_stok   ON transaksi_jual(stok_jual_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_notif_tgl        ON notifikasi_lokal(tgl_kirim)');
      await txn.execute('CREATE INDEX IF NOT EXISTS idx_sync_status      ON sync_log(status)');

      // ----------------------------------------------------------
      // SEED: Master Komoditas default
      // ----------------------------------------------------------
      final now = DateTime.now().toIso8601String();
      await txn.insert('komoditas', {
        'id': 1, 'nama_komoditas': 'Padi',  'siklus_hari_default': 90,
        'satuan': 'kg', 'deskripsi': 'Tanaman padi sawah / ladang',
        'active': 1, 'updated_at': now, 'synced_at': now,
      });
      await txn.insert('komoditas', {
        'id': 2, 'nama_komoditas': 'Jagung', 'siklus_hari_default': 90,
        'satuan': 'kg', 'deskripsi': 'Jagung pipilan / tongkol',
        'active': 1, 'updated_at': now, 'synced_at': now,
      });
      await txn.insert('komoditas', {
        'id': 3, 'nama_komoditas': 'Ubi',   'siklus_hari_default': 135,
        'satuan': 'kg', 'deskripsi': 'Ubi kayu / singkong',
        'active': 1, 'updated_at': now, 'synced_at': now,
      });
    });
  }

  // ============================================================
  // MIGRATION: tambah tabel / kolom saat versi naik
  // ============================================================
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Contoh upgrade v1 → v2:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE hasil_panen ADD COLUMN cuaca TEXT');
    // }
  }

  // ============================================================
  // HELPER CRUD UMUM
  // ============================================================

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  /// Soft delete: set is_deleted = 1 & is_dirty = 1
  Future<int> softDelete(String table, int id) async {
    final db = await database;
    return db.update(
      table,
      {
        'is_deleted': 1,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> hardDelete(String table, int id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // ============================================================
  // QUERY KHUSUS
  // ============================================================

  /// Ambil semua jadwal aktif milik user (tidak terhapus)
  Future<List<Map<String, dynamic>>> getJadwalAktif(int userId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT jt.*, k.nama_komoditas, k.siklus_hari_default
      FROM jadwal_tanam jt
      JOIN komoditas k ON k.id = jt.komoditas_id
      WHERE jt.user_id = ? AND jt.status = "aktif" AND jt.is_deleted = 0
      ORDER BY jt.tgl_panen_estimasi ASC
    ''', [userId]);
  }

  /// Total modal & keuntungan per jadwal tanam
  Future<Map<String, dynamic>?> getRingkasanKeuangan(int jadwalId) async {
    final db = await database;
    final biaya = await db.rawQuery('''
      SELECT COALESCE(SUM(jumlah_rp), 0) AS total_modal
      FROM biaya_produksi
      WHERE jadwal_tanam_id = ?
    ''', [jadwalId]);
    final transaksi = await db.rawQuery('''
      SELECT COALESCE(SUM(tj.total_rp), 0) AS total_pendapatan
      FROM transaksi_jual tj
      JOIN stok_jual sj ON sj.id = tj.stok_jual_id
      JOIN hasil_panen hp ON hp.jadwal_tanam_id = ?
      WHERE sj.user_id = hp.user_id
    ''', [jadwalId]);
    if (biaya.isEmpty || transaksi.isEmpty) return null;
    final modal      = (biaya.first['total_modal']      as num).toDouble();
    final pendapatan = (transaksi.first['total_pendapatan'] as num).toDouble();
    return {
      'total_modal'      : modal,
      'total_pendapatan' : pendapatan,
      'keuntungan_bersih': pendapatan - modal,
    };
  }

  /// Harga referensi terbaru per komoditas
  Future<List<Map<String, dynamic>>> getHargaTerbaru() async {
    final db = await database;
    return db.rawQuery('''
      SELECT hk.*, k.nama_komoditas
      FROM harga_komoditas hk
      JOIN komoditas k ON k.id = hk.komoditas_id
      WHERE hk.id IN (
        SELECT MAX(id) FROM harga_komoditas GROUP BY komoditas_id
      )
      ORDER BY k.nama_komoditas ASC
    ''');
  }

  /// Data belum tersync (is_dirty = 1) untuk sync queue
  Future<List<Map<String, dynamic>>> getDirtyRecords(String table) async {
    final db = await database;
    return db.query(table, where: 'is_dirty = 1');
  }

  /// Tandai record sudah tersync
  Future<void> markSynced(String table, int localId, int serverId) async {
    final db = await database;
    await db.update(
      table,
      {
        'server_id': serverId,
        'is_dirty' : 0,
        'synced_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}

// ============================================================
// CATATAN PENGEMBANGAN FLUTTER
// ============================================================
// • Gunakan DatabaseHelper.instance (singleton) di seluruh app
// • Sync dua arah: Flutter → Laravel API (POST) | Laravel → Flutter (GET)
// • is_dirty = 1  → record perlu dikirim ke server
// • server_id     → ID record di MySQL server
// • Notifikasi jadwal H-7/H-1: gunakan flutter_local_notifications
//   jadwalkan dari tabel notifikasi_lokal saat app dibuka
// • Semua tanggal simpan sebagai TEXT ISO 8601 (YYYY-MM-DD atau
//   YYYY-MM-DDTHH:MM:SS.mmm)
// • Pagination: gunakan LIMIT + OFFSET di queryAll()
// • Model class: buat di lib/models/ dengan fromMap() & toMap()
//   Contoh: lib/models/jadwal_tanam_model.dart
// ============================================================
