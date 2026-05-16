<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Komoditas;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Seed Komoditas (Master Data)
        Komoditas::create([
            'nama_komoditas' => 'Padi',
            'siklus_hari_default' => 90,
            'satuan' => 'kg',
            'deskripsi' => 'Tanaman padi sawah / ladang',
            'active' => true,
        ]);

        Komoditas::create([
            'nama_komoditas' => 'Jagung',
            'siklus_hari_default' => 90,
            'satuan' => 'kg',
            'deskripsi' => 'Jagung pipilan / tongkol',
            'active' => true,
        ]);

        Komoditas::create([
            'nama_komoditas' => 'Ubi',
            'siklus_hari_default' => 135,
            'satuan' => 'kg',
            'deskripsi' => 'Ubi kayu / singkong (estimasi 120-150 hari)',
            'active' => true,
        ]);

        // Seed Admin User
        User::create([
            'nama' => 'Admin AgriConnect',
            'email' => 'admin@agriconnect.id',
            'no_hp' => '08000000000',
            'lokasi' => 'Pusat',
            'role' => 'admin',
            'active' => true,
            'password' => Hash::make('Admin@1234'),
            'email_verified_at' => now(),
        ]);
    }
}
