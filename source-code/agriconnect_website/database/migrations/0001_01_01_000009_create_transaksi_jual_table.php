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
        Schema::create('transaksi_jual', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('stok_jual_id');
            $table->string('nama_pembeli', 100);
            $table->string('kontak_pembeli', 100)->nullable();
            $table->decimal('jumlah_terjual', 10, 2);
            $table->string('satuan', 20)->default('kg');
            $table->decimal('harga_unit_rp', 15, 2);
            $table->decimal('total_rp', 15, 2)->comment('jumlah_terjual * harga_unit_rp');
            $table->date('tgl_transaksi');
            $table->text('catatan')->nullable();
            $table->timestamps();

            $table->foreign('stok_jual_id')->references('id')->on('stok_jual')->onDelete('restrict');
            $table->index('stok_jual_id');
            $table->index('tgl_transaksi');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('transaksi_jual');
    }
};
