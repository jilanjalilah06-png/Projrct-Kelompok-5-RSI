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
        Schema::create('hasil_panen', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('jadwal_tanam_id')->nullable()->comment('Opsional, bisa dari jadwal atau mandiri');
            $table->unsignedBigInteger('komoditas_id');
            $table->date('tgl_panen');
            $table->decimal('jumlah', 10, 2);
            $table->string('satuan', 20)->default('kg');
            $table->enum('kualitas', ['premium', 'standar', 'afkir'])->default('standar');
            $table->string('foto_path', 500)->nullable()->comment('Path di Laravel Storage public/storage/panen/');
            $table->text('catatan')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('jadwal_tanam_id')->references('id')->on('jadwal_tanam')->onDelete('set null');
            $table->foreign('komoditas_id')->references('id')->on('komoditas')->onDelete('restrict');

            $table->index('user_id');
            $table->index('komoditas_id');
            $table->index('tgl_panen');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('hasil_panen');
    }
};
