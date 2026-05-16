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
        Schema::create('komoditas', function (Blueprint $table) {
            $table->id();
            $table->string('nama_komoditas', 100);
            $table->unsignedSmallInteger('siklus_hari_default')->default(90)->comment('Estimasi hari panen: padi=90, jagung=90, ubi=120-150');
            $table->string('satuan', 20)->default('kg')->comment('kg / ton / ikat');
            $table->text('deskripsi')->nullable();
            $table->boolean('active')->default(true);
            $table->timestamps();

            $table->index('nama_komoditas');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('komoditas');
    }
};
