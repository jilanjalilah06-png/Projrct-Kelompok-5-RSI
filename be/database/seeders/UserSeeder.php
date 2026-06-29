<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    private function demoPasswordHash(): string
    {
        return Hash::make('password123', [
            'rounds' => (int) env('BCRYPT_ROUNDS', 8),
        ]);
    }

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Admin user
        User::create([
            'name' => 'Admin User',
            'email' => 'admin@agriconnect.com',
            'password' => $this->demoPasswordHash(),
            'phone' => '081234567890',
            'address' => 'Jakarta Pusat',
            'role' => 'Admin',
            'is_verified' => true,
        ]);

        // Petani (Sellers) - 15 petani
        $petani_data = [
            [
                'name' => 'Budi Santoso',
                'email' => 'budi@agriconnect.com',
                'phone' => '082123456789',
                'address' => 'Karawang, Jawa Barat',
                'shop_name' => 'Tani Makmur',
                'shop_description' => 'Menjual padi organik berkualitas tinggi',
            ],
            [
                'name' => 'Siti Nurhaliza',
                'email' => 'siti@agriconnect.com',
                'phone' => '083234567890',
                'address' => 'Bandung, Jawa Barat',
                'shop_name' => 'Sayur Segar Siti',
                'shop_description' => 'Sayuran segar langsung dari kebun',
            ],
            [
                'name' => 'Rahmat Hidayat',
                'email' => 'rahmat@agriconnect.com',
                'phone' => '084345678901',
                'address' => 'Yogyakarta',
                'shop_name' => 'Buah Organik Rahmat',
                'shop_description' => 'Buah-buahan organik tanpa pestisida',
            ],
            [
                'name' => 'Dewi Lestari',
                'email' => 'dewi@agriconnect.com',
                'phone' => '085456789012',
                'address' => 'Surabaya, Jawa Timur',
                'shop_name' => 'Seafood Segar Dewi',
                'shop_description' => 'Ikan dan seafood segar setiap hari',
            ],
            [
                'name' => 'Hendra Wijaya',
                'email' => 'hendra@agriconnect.com',
                'phone' => '089567890234',
                'address' => 'Medan, Sumatera Utara',
                'shop_name' => 'Daging Berkualitas Hendra',
                'shop_description' => 'Daging sapi dan ayam premium',
            ],
            [
                'name' => 'Linda Kusuma',
                'email' => 'linda@agriconnect.com',
                'phone' => '081234567901',
                'address' => 'Bogor, Jawa Barat',
                'shop_name' => 'Bunga & Tanaman Hias Linda',
                'shop_description' => 'Bunga segar dan tanaman hias berkualitas',
            ],
            [
                'name' => 'Bambang Suryanto',
                'email' => 'bambang@agriconnect.com',
                'phone' => '082345678901',
                'address' => 'Semarang, Jawa Tengah',
                'shop_name' => 'Telur Ayam Segar Bambang',
                'shop_description' => 'Telur ayam segar setiap hari',
            ],
            [
                'name' => 'Nur Hidayati',
                'email' => 'nur@agriconnect.com',
                'phone' => '083456789012',
                'address' => 'Malang, Jawa Timur',
                'shop_name' => 'Apel & Jeruk Nur',
                'shop_description' => 'Buah apel dan jeruk impor berkualitas',
            ],
            [
                'name' => 'Gunawan Pratama',
                'email' => 'gunawan@agriconnect.com',
                'phone' => '084567890123',
                'address' => 'Lampung',
                'shop_name' => 'Kopi Organik Gunawan',
                'shop_description' => 'Kopi organik premium dari Lampung',
            ],
            [
                'name' => 'Ratih Handayani',
                'email' => 'ratih@agriconnect.com',
                'phone' => '085678901234',
                'address' => 'Bali',
                'shop_name' => 'Vanilla & Rempah Ratih',
                'shop_description' => 'Vanilla dan rempah-rempah pilihan dari Bali',
            ],
            [
                'name' => 'Rianto Setiawan',
                'email' => 'rianto@agriconnect.com',
                'phone' => '086789012345',
                'address' => 'Cirebon, Jawa Barat',
                'shop_name' => 'Udang & Ikan Rianto',
                'shop_description' => 'Udang dan ikan air tawar segar',
            ],
            [
                'name' => 'Susi Mulyani',
                'email' => 'susi@agriconnect.com',
                'phone' => '087890123456',
                'address' => 'Tasikmalaya, Jawa Barat',
                'shop_name' => 'Susu & Keju Susi',
                'shop_description' => 'Susu segar dan produk keju homemade',
            ],
            [
                'name' => 'Widi Santoso',
                'email' => 'widi@agriconnect.com',
                'phone' => '088901234567',
                'address' => 'Banyuwangi, Jawa Timur',
                'shop_name' => 'Madu Murni Widi',
                'shop_description' => 'Madu murni alami tanpa bahan kimia',
            ],
            [
                'name' => 'Yuni Wijayanti',
                'email' => 'yuni@agriconnect.com',
                'phone' => '089012345678',
                'address' => 'Klaten, Jawa Tengah',
                'shop_name' => 'Tahu & Tempe Yuni',
                'shop_description' => 'Tahu dan tempe segar dibuat setiap hari',
            ],
        ];

        foreach ($petani_data as $data) {
            User::create(array_merge($data, [
                'password' => $this->demoPasswordHash(),
                'role' => 'Petani',
                'is_verified' => true,
            ]));
        }

        // Pembeli (Buyers) - 15 pembeli
        $pembeli_data = [
            ['name' => 'Aryo Wicaksono', 'email' => 'aryo@email.com', 'phone' => '086567890123', 'address' => 'Jakarta Selatan'],
            ['name' => 'Lina Wijaya', 'email' => 'lina@email.com', 'phone' => '087678901234', 'address' => 'Tangerang'],
            ['name' => 'Riko Pratama', 'email' => 'riko@email.com', 'phone' => '088789012345', 'address' => 'Bekasi'],
            ['name' => 'Eka Putri', 'email' => 'eka@email.com', 'phone' => '081122334455', 'address' => 'Jakarta Barat'],
            ['name' => 'Fajar Hidayat', 'email' => 'fajar@email.com', 'phone' => '082233445566', 'address' => 'Jakarta Timur'],
            ['name' => 'Gita Murni', 'email' => 'gita@email.com', 'phone' => '083344556677', 'address' => 'Depok'],
            ['name' => 'Haris Dwianto', 'email' => 'haris@email.com', 'phone' => '084455667788', 'address' => 'Bogor'],
            ['name' => 'Irma Sinta', 'email' => 'irma@email.com', 'phone' => '085566778899', 'address' => 'Bandung'],
            ['name' => 'Joko Hermawan', 'email' => 'joko@email.com', 'phone' => '086677889900', 'address' => 'Cirebon'],
            ['name' => 'Kirana Dewi', 'email' => 'kirana@email.com', 'phone' => '087788990011', 'address' => 'Semarang'],
            ['name' => 'Lukman Hakim', 'email' => 'lukman@email.com', 'phone' => '088899001122', 'address' => 'Yogyakarta'],
            ['name' => 'Mira Ananda', 'email' => 'mira@email.com', 'phone' => '089900112233', 'address' => 'Surabaya'],
            ['name' => 'Nanda Permata', 'email' => 'nanda@email.com', 'phone' => '081011223344', 'address' => 'Malang'],
            ['name' => 'Oscar Wijaya', 'email' => 'oscar@email.com', 'phone' => '082122334455', 'address' => 'Medan'],
            ['name' => 'Puspita Sari', 'email' => 'puspita@email.com', 'phone' => '083233445566', 'address' => 'Bali'],
        ];

        foreach ($pembeli_data as $data) {
            User::create(array_merge($data, [
                'password' => $this->demoPasswordHash(),
                'role' => 'Pembeli',
                'is_verified' => true,
            ]));
        }
    }
}
