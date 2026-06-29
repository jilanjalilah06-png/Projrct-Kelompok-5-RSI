<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\User;
use App\Models\Category;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get all petani/sellers
        $sellers = User::where('role', 'Petani')->get();

        if ($sellers->isEmpty()) {
            return;
        }

        // Define extensive products for each seller - 30+ produk per seller
        $sellerProducts = [
            // Budi Santoso - Padi & Beras
            [
                ['name' => 'Padi Organik Premium', 'description' => 'Padi organik berkualitas tinggi tanpa pestisida', 'category_id' => 1, 'price' => 75000, 'stock' => 500, 'unit' => 'kg'],
                ['name' => 'Beras Putih Pilihan', 'description' => 'Beras putih pilihan grade A', 'category_id' => 1, 'price' => 65000, 'stock' => 300, 'unit' => 'kg'],
                ['name' => 'Beras Merah Organik', 'description' => 'Beras merah organik kaya nutrisi', 'category_id' => 1, 'price' => 55000, 'stock' => 200, 'unit' => 'kg'],
                ['name' => 'Gabah Premium', 'description' => 'Gabah premium siap giling', 'category_id' => 1, 'price' => 45000, 'stock' => 400, 'unit' => 'kg'],
            ],
            // Siti Nurhaliza - Sayuran (7 produk)
            [
                ['name' => 'Cabai Merah Segar', 'description' => 'Cabai merah segar langsung dari kebun', 'category_id' => 2, 'price' => 45000, 'stock' => 200, 'unit' => 'kg'],
                ['name' => 'Tomat Masak', 'description' => 'Tomat masak berkualitas', 'category_id' => 2, 'price' => 25000, 'stock' => 150, 'unit' => 'kg'],
                ['name' => 'Bayam Segar', 'description' => 'Bayam hijau segar tanpa pestisida', 'category_id' => 2, 'price' => 15000, 'stock' => 300, 'unit' => 'kg'],
                ['name' => 'Wortel Organik', 'description' => 'Wortel organik segar', 'category_id' => 2, 'price' => 18000, 'stock' => 250, 'unit' => 'kg'],
                ['name' => 'Kacang Panjang', 'description' => 'Kacang panjang segar', 'category_id' => 2, 'price' => 30000, 'stock' => 180, 'unit' => 'kg'],
                ['name' => 'Brokoli Segar', 'description' => 'Brokoli hijau segar berkualitas', 'category_id' => 2, 'price' => 35000, 'stock' => 120, 'unit' => 'kg'],
                ['name' => 'Kubis Hijau', 'description' => 'Kubis hijau segar tanpa pestisida', 'category_id' => 2, 'price' => 12000, 'stock' => 280, 'unit' => 'kg'],
            ],
            // Rahmat Hidayat - Buah-Buahan (7 produk)
            [
                ['name' => 'Mangga Harum Manis', 'description' => 'Mangga harum manis premium dari Jawa Timur', 'category_id' => 3, 'price' => 55000, 'stock' => 300, 'unit' => 'kg'],
                ['name' => 'Pisang Cavendish', 'description' => 'Pisang cavendish segar dan lezat', 'category_id' => 3, 'price' => 20000, 'stock' => 400, 'unit' => 'kg'],
                ['name' => 'Apel Merah Impor', 'description' => 'Apel merah segar dari Amerika', 'category_id' => 3, 'price' => 75000, 'stock' => 150, 'unit' => 'kg'],
                ['name' => 'Jeruk Mandarin', 'description' => 'Jeruk mandarin manis', 'category_id' => 3, 'price' => 35000, 'stock' => 200, 'unit' => 'kg'],
                ['name' => 'Pepaya Manis', 'description' => 'Pepaya manis lokal berkualitas', 'category_id' => 3, 'price' => 22000, 'stock' => 180, 'unit' => 'kg'],
                ['name' => 'Pir Hijau Segar', 'description' => 'Pir hijau segar manis', 'category_id' => 3, 'price' => 65000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Nanas Segar', 'description' => 'Nanas segar manis', 'category_id' => 3, 'price' => 18000, 'stock' => 250, 'unit' => 'kg'],
            ],
            // Dewi Lestari - Ikan & Seafood (6 produk)
            [
                ['name' => 'Ikan Lele Segar', 'description' => 'Ikan lele segar konsumsi', 'category_id' => 5, 'price' => 85000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Udang Segar', 'description' => 'Udang air tawar segar', 'category_id' => 5, 'price' => 120000, 'stock' => 60, 'unit' => 'kg'],
                ['name' => 'Ikan Patin', 'description' => 'Ikan patin segar berkualitas', 'category_id' => 5, 'price' => 50000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Ikan Gabus', 'description' => 'Ikan gabus segar air tawar', 'category_id' => 5, 'price' => 95000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Ikan Gurame', 'description' => 'Ikan gurame segar konsumsi', 'category_id' => 5, 'price' => 70000, 'stock' => 90, 'unit' => 'kg'],
                ['name' => 'Udang Besar Segar', 'description' => 'Udang besar segar premium', 'category_id' => 5, 'price' => 130000, 'stock' => 50, 'unit' => 'kg'],
            ],
            // Hendra Wijaya - Daging & Telur (6 produk)
            [
                ['name' => 'Daging Sapi Premium', 'description' => 'Daging sapi pilihan grade A', 'category_id' => 4, 'price' => 150000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Ayam Kampung Segar', 'description' => 'Ayam kampung segar hidup', 'category_id' => 4, 'price' => 65000, 'stock' => 120, 'unit' => 'kg'],
                ['name' => 'Telur Ayam Kampung', 'description' => 'Telur ayam kampung segar', 'category_id' => 4, 'price' => 28000, 'stock' => 300, 'unit' => 'kg'],
                ['name' => 'Daging Sapi Tanpa Lemak', 'description' => 'Daging sapi pilihan tanpa lemak', 'category_id' => 4, 'price' => 165000, 'stock' => 60, 'unit' => 'kg'],
                ['name' => 'Ayam Potong Premium', 'description' => 'Ayam potong premium berkualitas', 'category_id' => 4, 'price' => 55000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Telur Puyuh Segar', 'description' => 'Telur puyuh segar berkualitas', 'category_id' => 4, 'price' => 45000, 'stock' => 150, 'unit' => 'kg'],
            ],
            // Linda Kusuma - Tanaman & Bumbu (6 produk)
            [
                ['name' => 'Bunga Mawar Segar', 'description' => 'Bunga mawar segar untuk rangkaian', 'category_id' => 2, 'price' => 35000, 'stock' => 100, 'unit' => 'ikat'],
                ['name' => 'Tanaman Hias Bunga', 'description' => 'Tanaman hias bunga berkualitas', 'category_id' => 2, 'price' => 50000, 'stock' => 50, 'unit' => 'pot'],
                ['name' => 'Bunga Melati Segar', 'description' => 'Bunga melati segar harum', 'category_id' => 2, 'price' => 25000, 'stock' => 80, 'unit' => 'ikat'],
                ['name' => 'Bunga Anggrek Potong', 'description' => 'Bunga anggrek potong berkualitas', 'category_id' => 2, 'price' => 60000, 'stock' => 40, 'unit' => 'tangkai'],
                ['name' => 'Tanaman Obat Herbal', 'description' => 'Tanaman obat herbal segar', 'category_id' => 2, 'price' => 15000, 'stock' => 120, 'unit' => 'pot'],
                ['name' => 'Bunga Matahari Segar', 'description' => 'Bunga matahari segar cerah', 'category_id' => 2, 'price' => 30000, 'stock' => 70, 'unit' => 'tangkai'],
            ],
            // Bambang Suryanto - Telur (5 produk)
            [
                ['name' => 'Telur Ayam Segar', 'description' => 'Telur ayam segar setiap hari', 'category_id' => 4, 'price' => 26000, 'stock' => 400, 'unit' => 'kg'],
                ['name' => 'Telur Puyuh', 'description' => 'Telur puyuh segar berkualitas', 'category_id' => 4, 'price' => 45000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Telur Bebek Segar', 'description' => 'Telur bebek segar premium', 'category_id' => 4, 'price' => 32000, 'stock' => 150, 'unit' => 'kg'],
                ['name' => 'Telur Omega 3', 'description' => 'Telur ayam omega 3 berkualitas', 'category_id' => 4, 'price' => 35000, 'stock' => 120, 'unit' => 'kg'],
                ['name' => 'Telur Organik Alami', 'description' => 'Telur organik alami tanpa hormone', 'category_id' => 4, 'price' => 38000, 'stock' => 100, 'unit' => 'kg'],
            ],
            // Nur Hidayati - Buah Premium (7 produk)
            [
                ['name' => 'Strawberry Premium', 'description' => 'Strawberry segar premium', 'category_id' => 3, 'price' => 85000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Blueberry Segar', 'description' => 'Blueberry import segar', 'category_id' => 3, 'price' => 95000, 'stock' => 50, 'unit' => 'kg'],
                ['name' => 'Anggur Merah', 'description' => 'Anggur merah segar', 'category_id' => 3, 'price' => 60000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Alpukat Segar', 'description' => 'Alpukat segar berkualitas', 'category_id' => 3, 'price' => 45000, 'stock' => 120, 'unit' => 'kg'],
                ['name' => 'Kiwi Hijau Segar', 'description' => 'Kiwi hijau segar manis', 'category_id' => 3, 'price' => 55000, 'stock' => 90, 'unit' => 'kg'],
                ['name' => 'Lemon Segar', 'description' => 'Lemon segar asam berkualitas', 'category_id' => 3, 'price' => 38000, 'stock' => 110, 'unit' => 'kg'],
                ['name' => 'Persik Segar', 'description' => 'Persik segar manis import', 'category_id' => 3, 'price' => 70000, 'stock' => 70, 'unit' => 'kg'],
            ],
            // Gunawan Pratama - Kopi & Coklat (5 produk)
            [
                ['name' => 'Kopi Organik Lampung', 'description' => 'Kopi organik premium dari Lampung', 'category_id' => 7, 'price' => 120000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Kopi Arabika Pilihan', 'description' => 'Kopi arabika pilihan berkualitas', 'category_id' => 7, 'price' => 150000, 'stock' => 60, 'unit' => 'kg'],
                ['name' => 'Kopi Robusta Premium', 'description' => 'Kopi robusta premium kuat', 'category_id' => 7, 'price' => 90000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Kopi Specialty Grade', 'description' => 'Kopi specialty grade terbaik', 'category_id' => 7, 'price' => 180000, 'stock' => 40, 'unit' => 'kg'],
                ['name' => 'Biji Kakao Pilihan', 'description' => 'Biji kakao pilihan organik', 'category_id' => 7, 'price' => 140000, 'stock' => 50, 'unit' => 'kg'],
            ],
            // Ratih Handayani - Rempah-Rempah (7 produk)
            [
                ['name' => 'Vanilla Asli Bali', 'description' => 'Vanilla asli dari Bali berkualitas', 'category_id' => 7, 'price' => 200000, 'stock' => 30, 'unit' => 'kg'],
                ['name' => 'Lada Hitam Murni', 'description' => 'Lada hitam premium tanpa campuran', 'category_id' => 7, 'price' => 85000, 'stock' => 50, 'unit' => 'kg'],
                ['name' => 'Kunyit Segar', 'description' => 'Kunyit segar berkualitas', 'category_id' => 7, 'price' => 35000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Jahe Merah Organik', 'description' => 'Jahe merah organik berkualitas', 'category_id' => 7, 'price' => 45000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Kayu Manis Pilihan', 'description' => 'Kayu manis pilihan premium', 'category_id' => 7, 'price' => 95000, 'stock' => 40, 'unit' => 'kg'],
                ['name' => 'Pala Biji Asli', 'description' => 'Pala biji asli dari Banda', 'category_id' => 7, 'price' => 150000, 'stock' => 25, 'unit' => 'kg'],
                ['name' => 'Bawang Putih Pilihan', 'description' => 'Bawang putih pilihan berkualitas', 'category_id' => 7, 'price' => 50000, 'stock' => 120, 'unit' => 'kg'],
            ],
            // Rianto Setiawan - Seafood Premium (6 produk)
            [
                ['name' => 'Udang Besar Segar', 'description' => 'Udang besar air tawar segar', 'category_id' => 5, 'price' => 130000, 'stock' => 80, 'unit' => 'kg'],
                ['name' => 'Gurame Segar', 'description' => 'Ikan gurame segar konsumsi', 'category_id' => 5, 'price' => 70000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Ikan Mas Segar', 'description' => 'Ikan mas segar berkualitas', 'category_id' => 5, 'price' => 55000, 'stock' => 120, 'unit' => 'kg'],
                ['name' => 'Nila Segar', 'description' => 'Ikan nila segar konsumsi', 'category_id' => 5, 'price' => 40000, 'stock' => 150, 'unit' => 'kg'],
                ['name' => 'Lele Dumbo Segar', 'description' => 'Ikan lele dumbo segar premium', 'category_id' => 5, 'price' => 75000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Mujair Segar', 'description' => 'Ikan mujair segar konsumsi', 'category_id' => 5, 'price' => 45000, 'stock' => 110, 'unit' => 'kg'],
            ],
            // Susi Mulyani - Susu & Produk Olahan (7 produk)
            [
                ['name' => 'Susu Segar Murni', 'description' => 'Susu segar dari peternak lokal', 'category_id' => 6, 'price' => 22000, 'stock' => 200, 'unit' => 'liter'],
                ['name' => 'Keju Cheddar Lokal', 'description' => 'Keju cheddar buatan sendiri', 'category_id' => 6, 'price' => 90000, 'stock' => 40, 'unit' => 'kg'],
                ['name' => 'Yogurt Segar', 'description' => 'Yogurt segar homemade', 'category_id' => 6, 'price' => 28000, 'stock' => 150, 'unit' => 'kg'],
                ['name' => 'Mentega Tawar Lokal', 'description' => 'Mentega tawar buatan sendiri', 'category_id' => 6, 'price' => 85000, 'stock' => 50, 'unit' => 'kg'],
                ['name' => 'Keju Mozarella Segar', 'description' => 'Keju mozarella segar berkualitas', 'category_id' => 6, 'price' => 75000, 'stock' => 35, 'unit' => 'kg'],
                ['name' => 'Susu Kental Manis Homemade', 'description' => 'Susu kental manis buatan sendiri', 'category_id' => 6, 'price' => 32000, 'stock' => 100, 'unit' => 'kg'],
                ['name' => 'Krim Asam Segar', 'description' => 'Krim asam segar premium', 'category_id' => 6, 'price' => 40000, 'stock' => 60, 'unit' => 'kg'],
            ],
            // Widi Santoso - Madu & Produk Lebah (5 produk)
            [
                ['name' => 'Madu Murni Alami', 'description' => 'Madu murni dari lebah liar', 'category_id' => 7, 'price' => 180000, 'stock' => 30, 'unit' => 'kg'],
                ['name' => 'Madu dengan Propolis', 'description' => 'Madu dengan propolis murni', 'category_id' => 7, 'price' => 200000, 'stock' => 25, 'unit' => 'kg'],
                ['name' => 'Madu Pinus Premium', 'description' => 'Madu pinus premium berkualitas', 'category_id' => 7, 'price' => 220000, 'stock' => 20, 'unit' => 'kg'],
                ['name' => 'Propolis Murni', 'description' => 'Propolis murni anti inflamasi', 'category_id' => 7, 'price' => 250000, 'stock' => 15, 'unit' => 'kg'],
                ['name' => 'Royal Jelly Segar', 'description' => 'Royal jelly segar premium', 'category_id' => 7, 'price' => 300000, 'stock' => 10, 'unit' => 'kg'],
            ],
            // Yuni Wijayanti - Tahu & Tempe (6 produk)
            [
                ['name' => 'Tahu Putih Segar', 'description' => 'Tahu putih segar dibuat harian', 'category_id' => 8, 'price' => 12000, 'stock' => 500, 'unit' => 'kg'],
                ['name' => 'Tempe Organik', 'description' => 'Tempe organik dibuat setiap hari', 'category_id' => 8, 'price' => 15000, 'stock' => 300, 'unit' => 'kg'],
                ['name' => 'Tahu Goreng', 'description' => 'Tahu goreng siap saji', 'category_id' => 8, 'price' => 18000, 'stock' => 200, 'unit' => 'kg'],
                ['name' => 'Tahu Kuning', 'description' => 'Tahu kuning berkualitas', 'category_id' => 8, 'price' => 14000, 'stock' => 250, 'unit' => 'kg'],
                ['name' => 'Tempe Goreng', 'description' => 'Tempe goreng siap saji', 'category_id' => 8, 'price' => 18000, 'stock' => 180, 'unit' => 'kg'],
                ['name' => 'Tahu Sutra Premium', 'description' => 'Tahu sutra premium lembut', 'category_id' => 8, 'price' => 22000, 'stock' => 120, 'unit' => 'kg'],
            ],
        ];

        // Create products for each seller
        foreach ($sellers as $index => $seller) {
            if (isset($sellerProducts[$index])) {
                foreach ($sellerProducts[$index] as $product) {
                    Product::create(array_merge($product, [
                        'seller_id' => $seller->id,
                        'is_active' => true,
                    ]));
                }
            }
        }
    }
}
