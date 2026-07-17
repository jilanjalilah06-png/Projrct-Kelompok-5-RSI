<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 1. Admin
        User::updateOrCreate(
            ['email' => 'admin@agriconnect.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('password123'),
                'phone' => '081234567890',
                'address' => 'Jakarta Pusat',
                'role' => 'Admin',
                'is_verified' => true,
                'is_active' => true,
            ]
        );
    }
}
