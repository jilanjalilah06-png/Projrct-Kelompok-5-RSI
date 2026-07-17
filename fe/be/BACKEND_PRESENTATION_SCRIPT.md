# Skrip Presentasi Backend AgriConnect

## Tujuan
Menyediakan naskah presentasi yang jelas untuk menjelaskan bagian backend AgriConnect kepada tim, stakeholder, atau saat demo.

---

## 1. Pembukaan

**Slide 1: Judul & Konteks**
- "Selamat datang, saya akan mempresentasikan arsitektur backend AgriConnect."
- "AgriConnect adalah platform e-commerce pertanian yang menghubungkan petani, pembeli, dan admin melalui API modern."
- "Bagian backend dibangun dengan Laravel 11 dan didesain untuk mendukung autentikasi JWT, manajemen produk, pesanan, kategori, dan review."

> Catatan: Sampaikan bahwa backend adalah tulang punggung aplikasi, menyediakan data dan otorisasi untuk semua layar di aplikasi Flutter.

---

## 2. Tujuan Backend

**Slide 2: Fungsi Utama Backend**
- "Melayani request dari aplikasi frontend dan mengembalikan data JSON.
- Melakukan autentikasi dan otorisasi user.
- Mengelola produk, kategori, pesanan, dan review.
- Menyimpan data di database dan menjaga integritas transaksi."

> Catatan: Tekankan bahwa backend juga menangani role-based access control antara pembeli, petani, dan admin.

---

## 3. Teknologi & Stack

**Slide 3: Teknologi Utama**
- Laravel 11 sebagai framework backend.
- PHP 8.x.
- JWT Authentication memakai package `tymon/jwt-auth`.
- Database SQLite untuk pengembangan, MySQL untuk produksi.
- REST API dengan format JSON.
- CORS diaktifkan untuk memungkinkan komunikasi dengan frontend Flutter.

> Catatan: Jelaskan mengapa Laravel dipilih: kecepatan pengembangan, struktur modular, dan ekosistem package.

---

## 4. Arsitektur API

**Slide 4: Struktur API**
- Endpoint publik: registrasi dan login.
- Endpoint protected: akses data user, product, category, order, review.
- JWT dipakai pada header Authorization.
- Token di-refresh sebelum kadaluarsa.

Contoh endpoint:
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/products`
- `POST /api/products`
- `POST /api/orders`

> Catatan: Tunjukkan bahwa semua komunikasi antara frontend dan backend menggunakan HTTP dan JSON.

---

## 5. Role dan Akses

**Slide 5: Role Pengguna**
- **Pembeli**: mencari produk, membuat order, memberi review.
- **Petani**: mengelola produk sendiri, melihat order, memperbarui status pesanan.
- **Admin**: mengelola kategori, pengguna, dan memantau sistem.

> Catatan: Data role ini penting untuk menjelaskan bagaimana otorisasi dipisahkan di backend.

---

## 6. Alur Data

**Slide 6: Data Flow**
- Frontend mengirim request login.
- Backend memvalidasi kredensial dan mengeluarkan token JWT.
- Frontend menyimpan token dan menggunakannya pada request berikutnya.
- Backend menerima token, memeriksa hak akses, lalu memproses request.

> Catatan: Gunakan ilustrasi sederhana: Frontend → Backend → Database → Backend → Frontend.

---

## 7. Struktur Proyek

**Slide 7: Folder Backend**
- `app/Http/Controllers/Api/` → kontroler API.
- `app/Models/` → model data.
- `config/` → konfigurasi JWT, CORS, database.
- `database/migrations/` → skema tabel.
- `database/seeders/` → data awal.
- `routes/api.php` → definisi rute API.

> Catatan: Berikan gambaran singkat tentang bagaimana setiap bagian bekerja dalam sebuah request.

---

## 8. Setup & Demo

**Slide 8: Cara Menjalankan Backend**
- `cd be`
- `composer install`
- `php artisan key:generate`
- `php artisan jwt:secret`
- `php artisan migrate --seed`
- `php artisan serve --port=8000`

"Setelah backend berjalan, frontend Flutter dapat terhubung ke `http://127.0.0.1:8000`."

> Catatan: Jelaskan bahwa API endpoint dapat diuji langsung dengan Postman atau curl.

---

## 9. Integrasi dengan Frontend

**Slide 9: Integrasi BE-FE**
- Frontend menargetkan endpoint backend yang sama.
- Frontend menyertakan token JWT di setiap request protected.
- Backend mengembalikan data yang siap ditampilkan di aplikasi.
- Media seperti produk dan review dikelola oleh backend.

> Catatan: Sampaikan bahwa hubungan BE-FE mendukung skenario real-time sederhana melalui request/response.

---

## 10. Kesimpulan dan Q&A

**Slide 10: Ringkasan**
- Backend AgriConnect: Laravel + JWT + REST API.
- Menangani user auth, produk, order, kategori, dan review.
- Dirancang untuk integrasi lancar dengan aplikasi Flutter.
- Siap digunakan untuk demo dan pengembangan lebih lanjut.

**Tanya Jawab**
- Siapkan jawaban untuk: "Bagaimana otentikasi bekerja?", "Bagaimana frontend memanggil API?", "Apa perbedaan role user?".

---

## Tips Presentasi
- Gunakan bahasa yang sederhana dan fokus pada manfaat backend.
- Tekankan bahwa backend menjaga keamanan, konsistensi data, dan alur bisnis.
- Jika ingin, sertakan demo singkat login atau request API menggunakan Postman.
- Tutup dengan call-to-action: "Selanjutnya, kita bisa lanjut ke integrasi frontend atau fitur tambahan seperti notification dan payment."
