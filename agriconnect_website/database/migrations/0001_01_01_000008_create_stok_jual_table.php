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
        Schema::create('stok_jual', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('komoditas_id');
            $table->decimal('jumlah_tersedia', 10, 2);
            $table->string('satuan', 20)->default('kg');
            $table->decimal('harga_tawar_rp', 15, 2);
            $table->text('deskripsi')->nullable();
            $table->string('lokasi_jual', 200)->nullable();
            $table->string('foto_path', 500)->nullable();
            $table->boolean('publik')->default(false)->comment('1 = tampil di halaman publik');
            $table->date('tgl_tersedia');
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('komoditas_id')->references('id')->on('komoditas')->onDelete('restrict');

            $table->index('user_id');
            $table->index('komoditas_id');
            $table->index('publik');
            $table->index('tgl_tersedia');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stok_jual');
    }
};
