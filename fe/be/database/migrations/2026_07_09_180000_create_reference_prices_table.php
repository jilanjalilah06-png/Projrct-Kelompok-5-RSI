<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('reference_prices', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->integer('min_price');
            $table->integer('max_price');
            $table->text('note')->nullable();
            $table->string('updated_by')->nullable();
            $table->timestamps();
        });

        // Seed initial data
        DB::table('reference_prices')->insert([
            [
                'name' => 'Beras Premium',
                'min_price' => 18000,
                'max_price' => 20000,
                'note' => 'Hasil pantauan pasar induk',
                'updated_by' => 'Admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Beras Standar',
                'min_price' => 14500,
                'max_price' => 16000,
                'note' => 'Hasil pantauan pasar induk',
                'updated_by' => 'Admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Jagung Premium',
                'min_price' => 10000,
                'max_price' => 12000,
                'note' => 'Pembaruan berkala',
                'updated_by' => 'Admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Jagung Standar',
                'min_price' => 8000,
                'max_price' => 9500,
                'note' => 'Pembaruan berkala',
                'updated_by' => 'Admin',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reference_prices');
    }
};
