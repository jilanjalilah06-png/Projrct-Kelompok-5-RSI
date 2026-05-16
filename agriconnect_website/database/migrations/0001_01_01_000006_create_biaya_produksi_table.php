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
        Schema::create('biaya_produksi', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('jadwal_tanam_id');
            $table->enum('kategori', ['bibit', 'pupuk', 'pestisida', 'tenaga_kerja', 'lainnya']);
            $table->string('nama_item', 150);
            $table->decimal('jumlah_rp', 15, 2);
            $table->text('catatan')->nullable();
            $table->timestamps();

            $table->foreign('jadwal_tanam_id')->references('id')->on('jadwal_tanam')->onDelete('cascade');
            $table->index('jadwal_tanam_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('biaya_produksi');
    }
};
