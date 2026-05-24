# AgriConnect Database Schema Documentation

## Overview
AgriConnect is a web platform for farmers and agricultural extension workers. This document describes the complete database schema using Laravel migrations.

**Platform**: Web (Laravel 12, PHP 8.2+)  
**Database**: MySQL 8.0+  
**Engine**: InnoDB  
**Charset**: utf8mb4_unicode_ci  
**Version**: 1.2 | May 2026

---

## Database Tables

### 1. Users
Stores all system users (farmers, extension workers, and admins)

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key, Auto-increment |
| nama | VARCHAR(100) | User's full name |
| email | VARCHAR(150) | Unique email address |
| no_hp | VARCHAR(20) | Phone number |
| lokasi | VARCHAR(200) | Location/Address (nullable) |
| role | ENUM('user','admin') | User role (default: 'user') |
| active | BOOLEAN | Account status (default: 1) |
| password | VARCHAR(255) | Bcrypt hashed password |
| remember_token | VARCHAR(100) | Remember-me token (nullable) |
| email_verified_at | TIMESTAMP | Email verification timestamp (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |
| deleted_at | TIMESTAMP | Soft delete timestamp (nullable) |

**Indexes**: role, active, email  
**Soft Deletes**: Yes (30-day recovery)

---

### 2. Komoditas (Commodity Master)
Master data for all commodity types managed by admins

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| nama_komoditas | VARCHAR(100) | Commodity name (e.g., "Padi", "Jagung") |
| siklus_hari_default | SMALLINT UNSIGNED | Default harvest cycle in days (e.g., 90 for padi) |
| satuan | VARCHAR(20) | Unit of measurement (kg, ton, ikat) |
| deskripsi | TEXT | Description (nullable) |
| active | BOOLEAN | Active status (default: 1) |
| timestamps | TIMESTAMP | created_at, updated_at |

**Indexes**: nama_komoditas  
**Sample Data**:
- Padi: 90 days (kg)
- Jagung: 90 days (kg)
- Ubi: 135 days (kg)

---

### 3. Jadwal_Tanam (Planting Schedule)
Tracks planting schedules per farmer with estimated and actual harvest dates

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| user_id | BIGINT UNSIGNED | FK to users (ON DELETE CASCADE) |
| komoditas_id | BIGINT UNSIGNED | FK to komoditas (ON DELETE RESTRICT) |
| tgl_tanam | DATE | Planting date |
| luas_lahan_ha | DECIMAL(8,2) | Land area in hectares (nullable) |
| tgl_panen_estimasi | DATE | Estimated harvest date (calculated) |
| tgl_panen_aktual | DATE | Actual harvest date (user-modifiable, nullable) |
| status | ENUM('aktif','selesai','batal') | Schedule status (default: 'aktif') |
| catatan | TEXT | Notes (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |
| deleted_at | TIMESTAMP | Soft delete (nullable) |

**Indexes**: user_id, komoditas_id, status, tgl_tanam  
**Soft Deletes**: Yes

---

### 4. Hasil_Panen (Harvest Results)
Records actual harvest results per event

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| user_id | BIGINT UNSIGNED | FK to users (ON DELETE CASCADE) |
| jadwal_tanam_id | BIGINT UNSIGNED | FK to jadwal_tanam (optional, nullable) |
| komoditas_id | BIGINT UNSIGNED | FK to komoditas (ON DELETE RESTRICT) |
| tgl_panen | DATE | Harvest date |
| jumlah | DECIMAL(10,2) | Quantity harvested |
| satuan | VARCHAR(20) | Unit (kg, ton, etc.) |
| kualitas | ENUM('premium','standar','afkir') | Quality grade (default: 'standar') |
| foto_path | VARCHAR(500) | Photo path (storage/panen/) (nullable) |
| catatan | TEXT | Notes (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |
| deleted_at | TIMESTAMP | Soft delete (nullable) |

**Indexes**: user_id, komoditas_id, tgl_panen  
**Soft Deletes**: Yes

---

### 5. Biaya_Produksi (Production Costs)
Tracks production costs per planting schedule (private data)

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| jadwal_tanam_id | BIGINT UNSIGNED | FK to jadwal_tanam (ON DELETE CASCADE) |
| kategori | ENUM | 'bibit','pupuk','pestisida','tenaga_kerja','lainnya' |
| nama_item | VARCHAR(150) | Item name/description |
| jumlah_rp | DECIMAL(15,2) | Cost in Rupiah |
| catatan | TEXT | Notes (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |

**Indexes**: jadwal_tanam_id

---

### 6. Harga_Komoditas (Commodity Prices)
Price history reference (updated manually by admin)

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| komoditas_id | BIGINT UNSIGNED | FK to komoditas (ON DELETE RESTRICT) |
| harga_rp | DECIMAL(15,2) | Price per unit (kg/ton) |
| satuan | VARCHAR(20) | Unit (default: 'kg') |
| tgl_berlaku | DATE | Effective date |
| tren | ENUM('naik','turun','stabil') | Price trend (default: 'stabil') |
| updated_by | BIGINT UNSIGNED | FK to users (admin) |
| catatan | TEXT | Notes (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |

**Indexes**: komoditas_id, tgl_berlaku

---

### 7. Stok_Jual (Sales Inventory)
Inventory for published sales by farmers

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| user_id | BIGINT UNSIGNED | FK to users (ON DELETE CASCADE) |
| komoditas_id | BIGINT UNSIGNED | FK to komoditas (ON DELETE RESTRICT) |
| jumlah_tersedia | DECIMAL(10,2) | Available quantity |
| satuan | VARCHAR(20) | Unit (default: 'kg') |
| harga_tawar_rp | DECIMAL(15,2) | Asking price |
| deskripsi | TEXT | Description (nullable) |
| lokasi_jual | VARCHAR(200) | Sales location (nullable) |
| foto_path | VARCHAR(500) | Product photo (nullable) |
| publik | BOOLEAN | Public visibility (default: 0) |
| tgl_tersedia | DATE | Available date |
| timestamps | TIMESTAMP | created_at, updated_at |
| deleted_at | TIMESTAMP | Soft delete (nullable) |

**Indexes**: user_id, komoditas_id, publik, tgl_tersedia  
**Soft Deletes**: Yes  
**Note**: Updated via Eloquent Observers when transactions occur

---

### 8. Transaksi_Jual (Sales Transactions)
Records all sales transactions; updates stok_jual via Observer

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| stok_jual_id | BIGINT UNSIGNED | FK to stok_jual (ON DELETE RESTRICT) |
| nama_pembeli | VARCHAR(100) | Buyer's name |
| kontak_pembeli | VARCHAR(100) | Buyer contact (nullable) |
| jumlah_terjual | DECIMAL(10,2) | Quantity sold |
| satuan | VARCHAR(20) | Unit (default: 'kg') |
| harga_unit_rp | DECIMAL(15,2) | Unit price |
| total_rp | DECIMAL(15,2) | Total (jumlah_terjual × harga_unit_rp) |
| tgl_transaksi | DATE | Transaction date |
| catatan | TEXT | Notes (nullable) |
| timestamps | TIMESTAMP | created_at, updated_at |

**Indexes**: stok_jual_id, tgl_transaksi

---

### 9. Activity_Log (System Activity Log)
Monitors system activities for auditing and debugging

| Column | Type | Notes |
|--------|------|-------|
| id | BIGINT UNSIGNED | Primary Key |
| user_id | BIGINT UNSIGNED | FK to users (nullable, NULL = system/scheduler) |
| aksi | VARCHAR(100) | Action type (login, create_panen, update_harga, etc.) |
| model | VARCHAR(100) | Model name (nullable) |
| model_id | BIGINT UNSIGNED | Model ID (nullable) |
| deskripsi | TEXT | Description (nullable) |
| ip_address | VARCHAR(45) | User's IP address (nullable) |
| user_agent | VARCHAR(500) | Browser user agent (nullable) |
| created_at | TIMESTAMP | Log timestamp |

**Indexes**: user_id, aksi, (model, model_id)

---

### 10. Password_Reset_Tokens (Laravel Breeze)
Temporary tokens for password reset functionality

| Column | Type | Notes |
|--------|------|-------|
| email | VARCHAR(150) | Primary Key, email address |
| token | VARCHAR(255) | Reset token |
| created_at | TIMESTAMP | Token creation time (nullable) |

---

### 11. Sessions (Laravel Session Storage)
Database session driver for session management

| Column | Type | Notes |
|--------|------|-------|
| id | VARCHAR(255) | Primary Key, session ID |
| user_id | BIGINT UNSIGNED | FK to users (nullable) |
| ip_address | VARCHAR(45) | Client IP (nullable) |
| user_agent | TEXT | Browser info (nullable) |
| payload | LONGTEXT | Serialized session data |
| last_activity | INT | Last activity timestamp |

**Indexes**: user_id, last_activity

---

### 12. Jobs & Failed_Jobs (Laravel Queue)
Database queue driver for background jobs

**jobs** table:
- id, queue, payload, attempts, reserved_at, available_at, created_at

**failed_jobs** table:
- id, uuid, connection, queue, payload, exception, failed_at

---

## Initial Data

### Komoditas Seeder
```sql
INSERT INTO komoditas (nama_komoditas, siklus_hari_default, satuan, deskripsi)
VALUES
  ('Padi',  90,  'kg',  'Tanaman padi sawah / ladang'),
  ('Jagung', 90,  'kg',  'Jagung pipilan / tongkol'),
  ('Ubi',   135, 'kg',  'Ubi kayu / singkong (estimasi 120-150 hari)');
```

### Admin User Seeder
```sql
INSERT INTO users (nama, email, no_hp, lokasi, role, active, password)
VALUES ('Admin AgriConnect', 'admin@agriconnect.id', '08000000000', 'Pusat', 'admin', 1, 
  '$2y$12$...');
-- Password: Admin@1234 (CHANGE IMMEDIATELY on production)
```

---

## Laravel Implementation Notes

1. **Migrations**: All tables created via `php artisan migrate`
2. **Soft Delete**: Implemented on users, jadwal_tanam, hasil_panen, stok_jual
3. **Indexes**: Added for performance (user_id, komoditas_id, dates)
4. **Eloquent Observers**: 
   - TransaksiJual Observer: Deducts stok_jual.jumlah_tersedia on new transaction
   - JadwalTanam Observer: Calculates tgl_panen_estimasi
5. **Authorization Policies**:
   - HasilPanenPolicy
   - JadwalPolicy
   - StokJualPolicy
   - BiayaPolicy
6. **Backups**: `php artisan schedule:run` → mysqldump agriconnect_db

---

## Database Connection
Configured in `.env`:
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agriconnect_db
DB_USERNAME=root
DB_PASSWORD=
```

---

## Related Models
- `App\Models\User`
- `App\Models\Komoditas`
- `App\Models\JadwalTanam`
- `App\Models\HasilPanen`
- `App\Models\BiayaProduksi`
- `App\Models\HargaKomoditas`
- `App\Models\StokJual`
- `App\Models\TransaksiJual`
- `App\Models\ActivityLog`

---

Generated: May 2026
