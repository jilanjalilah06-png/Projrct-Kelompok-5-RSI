<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('phone')->nullable();
            $table->text('address')->nullable();
            $table->enum('role', ['Admin', 'Petani', 'Pembeli'])->default('Pembeli');
            $table->string('avatar')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->string('shop_name')->nullable();
            $table->text('shop_description')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'phone',
                'address',
                'role',
                'avatar',
                'is_verified',
                'shop_name',
                'shop_description',
            ]);
        });
    }
};
