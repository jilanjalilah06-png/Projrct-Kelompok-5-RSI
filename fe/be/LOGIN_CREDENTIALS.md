# Login Credentials - AgriConnect

> Akun yang ada saat ini adalah kombinasi dari **seed** dan **registrasi manual**.
> Password akun seed: `password123`. Password akun manual tidak diketahui.

## Admin

| Nama | Email | Password |
|---|---|---|
| Admin User | `admin@agriconnect.com` | `password123` |

## Petani

| No | Nama | Email | Keterangan |
|---|---|---|---|
| 1 | Ridho Gustama | `cape@gmail.com` | Registrasi manual |
| 2 | Jilan Jalilah | `jilan@gmail.com` | Registrasi manual |
| 3 | Jopan Maurizt Latue | `jopanlatue@gmail.com` | Registrasi manual |

## Pembeli

| No | Nama | Email | Keterangan |
|---|---|---|---|
| 1 | zilan | `zizi@gmail.com` | Registrasi manual |
| 2 | Jopanmaurizt | `jopanm3@gmail.com` | Registrasi manual |
| 3 | Natasya Novelia Adinda | `natasyanovelia35@gmail.com` | Registrasi manual |

## Ringkasan Database Saat Ini

- Total akun: **7 pengguna**
  - Admin: 1 (seed)
  - Petani: 3 (registrasi manual)
  - Pembeli: 3 (registrasi manual)
- Kategori: **2**, yaitu `Beras` dan `Jagung`
- Produk seed: **4** (dijalankan jika `budi@agriconnect.com` ada di DB)
  - Beras Standar — Rp 12.500/kg (stok: 500)
  - Beras Premium — Rp 15.000/kg (stok: 300)
  - Jagung Standar — Rp 7.000/kg (stok: 1.000)
  - Jagung Premium Manis — Rp 9.000/kg (stok: 250)
- Order demo: **0** *(OrderSeeder kosong)*

## Midtrans

Isi `.env` backend dengan key sandbox/production asli:

```env
APP_URL=https://domain-publik-backend-anda
MIDTRANS_SERVER_KEY=SB-Mid-server-isi_key_asli
MIDTRANS_CLIENT_KEY=SB-Mid-client-isi_key_asli
MIDTRANS_IS_PRODUCTION=false
MIDTRANS_IS_3DS=true
```

Untuk development lokal, gunakan URL publik seperti ngrok untuk `APP_URL` agar callback Midtrans dapat mencapai:

```text
POST {APP_URL}/api/payments/callback
```

Reset database:

```bash
cd be
php artisan migrate:fresh --seed
```
