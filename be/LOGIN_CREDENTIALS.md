# Login Credentials - AgriConnect Platform

> **Password untuk semua akun:** `password123`

---

## 👨‍💼 Administrator

| No | Nama | Email | Password | Role |
|---|---|---|---|---|
| 1 | Admin User | `admin@agriconnect.com` | `password123` | Admin |

---

## 👨‍🌾 Petani (Sellers) - 14 Petani

| No | Nama | Email | Password | Role | Shop Name | Spesialisasi |
|---|---|---|---|---|---|---|
| 1 | Budi Santoso | `budi@agriconnect.com` | `password123` | Petani | Tani Makmur | Padi & Beras |
| 2 | Siti Nurhaliza | `siti@agriconnect.com` | `password123` | Petani | Sayur Segar Siti | Sayuran |
| 3 | Rahmat Hidayat | `rahmat@agriconnect.com` | `password123` | Petani | Buah Organik Rahmat | Buah-Buahan |
| 4 | Dewi Lestari | `dewi@agriconnect.com` | `password123` | Petani | Seafood Segar Dewi | Ikan & Seafood |
| 5 | Hendra Wijaya | `hendra@agriconnect.com` | `password123` | Petani | Daging Berkualitas Hendra | Daging & Telur |
| 6 | Linda Kusuma | `linda@agriconnect.com` | `password123` | Petani | Bunga & Tanaman Hias Linda | Bunga & Tanaman |
| 7 | Bambang Suryanto | `bambang@agriconnect.com` | `password123` | Petani | Telur Ayam Segar Bambang | Telur Ayam |
| 8 | Nur Hidayati | `nur@agriconnect.com` | `password123` | Petani | Apel & Jeruk Nur | Buah Premium Import |
| 9 | Gunawan Pratama | `gunawan@agriconnect.com` | `password123` | Petani | Kopi Organik Gunawan | Kopi Organik |
| 10 | Ratih Handayani | `ratih@agriconnect.com` | `password123` | Petani | Vanilla & Rempah Ratih | Rempah-Rempah |
| 11 | Rianto Setiawan | `rianto@agriconnect.com` | `password123` | Petani | Udang & Ikan Rianto | Seafood Premium |
| 12 | Susi Mulyani | `susi@agriconnect.com` | `password123` | Petani | Susu & Keju Susi | Susu & Produk Olahan |
| 13 | Widi Santoso | `widi@agriconnect.com` | `password123` | Petani | Madu Murni Widi | Madu Alami |
| 14 | Yuni Wijayanti | `   ` | `password123` | Petani | Tahu & Tempe Yuni | Tahu & Tempe |

---

## 🛒 Pembeli (Buyers) - 15 Pembeli

| No | Nama | Email | Password | Role | Lokasi |
|---|---|---|---|---|---|
| 1 | Aryo Wicaksono | `aryo@email.com` | `password123` | Pembeli | Jakarta Selatan |
| 2 | Lina Wijaya | `lina@email.com` | `password123` | Pembeli | Tangerang |
| 3 | Riko Pratama | `riko@email.com` | `password123` | Pembeli | Bekasi |
| 4 | Eka Putri | `eka@email.com` | `password123` | Pembeli | Jakarta Barat |
| 5 | Fajar Hidayat | `fajar@email.com` | `password123` | Pembeli | Jakarta Timur |
| 6 | Gita Murni | `gita@email.com` | `password123` | Pembeli | Depok |
| 7 | Haris Dwianto | `haris@email.com` | `password123` | Pembeli | Bogor |
| 8 | Irma Sinta | `irma@email.com` | `password123` | Pembeli | Bandung |
| 9 | Joko Hermawan | `joko@email.com` | `password123` | Pembeli | Cirebon |
| 10 | Kirana Dewi | `kirana@email.com` | `password123` | Pembeli | Semarang |
| 11 | Lukman Hakim | `lukman@email.com` | `password123` | Pembeli | Yogyakarta |
| 12 | Mira Ananda | `mira@email.com` | `password123` | Pembeli | Surabaya |
| 13 | Nanda Permata | `nanda@email.com` | `password123` | Pembeli | Malang |
| 14 | Oscar Wijaya | `oscar@email.com` | `password123` | Pembeli | Medan |
| 15 | Puspita Sari | `puspita@email.com` | `password123` | Pembeli | Bali |

---

## 🔑 Master Password

Semua akun menggunakan password yang sama:

```
password123
```

---

## 📱 Cara Login

1. Buka aplikasi Flutter atau akses via browser
2. Pilih role yang sesuai (Admin, Petani, atau Pembeli)
3. Masukkan **email** dari tabel di atas
4. Masukkan **password**: `password123`
5. Klik Login

---

## 🎯 Panduan Penggunaan Per Role

### Admin (`admin@agriconnect.com`)
- Akses ke dashboard administratif
- Manajemen sistem keseluruhan
- Lihat semua pengguna, transaksi, dan data

### Petani (14 akun berbeda)
- Masing-masing petani memiliki spesialisasi unik
- Akses dashboard penjual
- Kelola produk dan toko sesuai spesialisasi
- Lihat pesanan dari pembeli
- Kelola inventaris

### Pembeli (15 akun berbeda)
- Dari berbagai lokasi Indonesia
- Akses dashboard pembeli
- Browse dan beli produk
- Lihat pesanan Anda
- Memberikan review produk

---

## 📊 Statistik Database

- **Total Akun:** 30 pengguna
  - 1 Admin
  - 14 Petani (Sellers)
  - 15 Pembeli (Buyers)
- **Total Produk:** 45+ produk
- **Total Kategori:** 8 kategori
- **Setiap Petani:** 2-5 produk spesifik sesuai toko mereka

---

## 🔐 Keamanan

- ⚠️ Kredensial ini **hanya untuk development/testing**
- ✅ Dalam production, gunakan hashed passwords
- ✅ Implement proper authentication & authorization
- ✅ Jangan hardcode credentials di kode production

---

## 🔄 Reset Credentials

Jika ingin reset semua akun dan membuat data baru:

```bash
cd ch1/be
php artisan migrate:fresh --seed
```

Ini akan:
- ✅ Drop semua tabel database
- ✅ Re-create dengan schema terbaru
- ✅ Seed dengan data test baru (akun di atas)
- ✅ Reset password ke `password123`

---

## ✅ Quick Copy-Paste

### Admin
```
Email: admin@agriconnect.com
Pass:  password123
```

### Petani (Sample)
```
Email: budi@agriconnect.com (Padi)
Email: siti@agriconnect.com (Sayuran)
Email: rahmat@agriconnect.com (Buah)
Email: dewi@agriconnect.com (Seafood)
Email: hendra@agriconnect.com (Daging)
Pass:  password123 (untuk semua)
```

### Pembeli (Sample)
```
Email: aryo@email.com
Email: lina@email.com
Email: riko@email.com
Email: eka@email.com
Pass:  password123 (untuk semua)
```

---

## 📝 Notes

- Semua akun sudah verified (`is_verified = true`)
- Email tidak perlu dikonfirmasi untuk login
- Token JWT berlaku 1 jam
- Sesi auto-logout setelah 2 jam inaktivitas
- Setiap petani memiliki produk yang berbeda-beda sesuai spesialisasi toko mereka
