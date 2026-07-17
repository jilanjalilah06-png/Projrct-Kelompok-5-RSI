<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
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
                'name' => 'Beras',
                'description' => 'Produk beras siap jual dari petani lokal',
            ],
            [
                'name' => 'Jagung',
                'description' => 'Produk jagung siap jual dari petani lokal',
            ],
        ];

        Product::whereHas('category', function ($query) {
            $query->whereNotIn('name', ['Beras', 'Jagung']);
        })->delete();

        Category::whereNotIn('name', ['Beras', 'Jagung'])->delete();

        foreach ($categories as $category) {
            Category::updateOrCreate(
                ['name' => $category['name']],
                ['description' => $category['description']]
            );
        }
    }
}
