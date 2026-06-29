<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            CategorySeeder::class,
            ProductSeeder::class,
        ]);

        // Auto-generate the registered users list in storage folder (synced to Windows host)
        try {
            $users = \App\Models\User::select('id', 'name', 'email', 'role', 'phone', 'address', 'shop_name', 'created_at')->get();
            file_put_contents(storage_path('registered_users.json'), json_encode($users, JSON_PRETTY_PRINT));
        } catch (\Exception $e) {
            // Ignore
        }
    }
}
