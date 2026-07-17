<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\Category;
use App\Models\User;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $budi = User::where('email', 'budi@agriconnect.com')->first();
        if (!$budi) return;

        $berasCategory = Category::where('name', 'Beras')->first();
        $jagungCategory = Category::where('name', 'Jagung')->first();

        // 1. Beras Standar
        Product::updateOrCreate(
            ['seller_id' => $budi->id, 'name' => 'Beras Standar'],
            [
                'category_id' => $berasCategory->id,
                'description' => 'Beras standar kualitas baik',
                'price' => 12500,
                'stock' => 500,
                'unit' => 'kg',
                'is_active' => true,
                'status' => 'public',
            ]
        );

        // 2. Beras Premium
        Product::updateOrCreate(
            ['seller_id' => $budi->id, 'name' => 'Beras Premium'],
            [
                'category_id' => $berasCategory->id,
                'description' => 'Beras premium pulen pilihan',
                'price' => 15000,
                'stock' => 300,
                'unit' => 'kg',
                'is_active' => true,
                'status' => 'public',
            ]
        );

        // 3. Jagung Standar
        Product::updateOrCreate(
            ['seller_id' => $budi->id, 'name' => 'Jagung Standar'],
            [
                'category_id' => $jagungCategory->id,
                'description' => 'Jagung pakan ternak kualitas standar',
                'price' => 7000,
                'stock' => 1000,
                'unit' => 'kg',
                'is_active' => true,
                'status' => 'public',
            ]
        );

        // 4. Jagung Premium
        Product::updateOrCreate(
            ['seller_id' => $budi->id, 'name' => 'Jagung Premium Manis'],
            [
                'category_id' => $jagungCategory->id,
                'description' => 'Jagung manis pilihan',
                'price' => 9000,
                'stock' => 250,
                'unit' => 'kg',
                'is_active' => true,
                'status' => 'public',
            ]
        );
    }
}
