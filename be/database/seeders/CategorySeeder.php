<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $categories = [
            [
                'name' => 'Padi & Gabah',
                'description' => 'Padi, gabah, dan produk padi-padian',
            ],
            [
                'name' => 'Sayuran',
                'description' => 'Berbagai macam sayuran segar',
            ],
            [
                'name' => 'Buah-Buahan',
                'description' => 'Buah-buahan segar berkualitas',
            ],
            [
                'name' => 'Daging & Unggas',
                'description' => 'Daging sapi, ayam, dan unggas lainnya',
            ],
            [
                'name' => 'Ikan & Seafood',
                'description' => 'Ikan segar dan produk seafood',
            ],
            [
                'name' => 'Susu & Produk Olahan',
                'description' => 'Susu dan produk olahan susu',
            ],
            [
                'name' => 'Bumbu & Rempah',
                'description' => 'Berbagai bumbu dan rempah-rempah',
            ],
            [
                'name' => 'Biji-Bijian',
                'description' => 'Kacang, biji-bijian, dan sejenisnya',
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
