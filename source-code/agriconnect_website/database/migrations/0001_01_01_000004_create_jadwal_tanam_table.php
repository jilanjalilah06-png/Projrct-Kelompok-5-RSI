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
        Schema::create('jadwal_tanam', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('komoditas_id');
            $table->date('tgl_tanam');
            $table->decimal('luas_lahan_ha', 8, 2)->nullable();
            $table->date('tgl_panen_estimasi')->comment('tgl_tanam + siklus_hari_default');
            $table->date('tgl_panen_aktual')->nullable()->comment('Bisa diubah pengguna');
            $table->enum('status', ['aktif', 'selesai', 'batal'])->default('aktif');
            $table->text('catatan')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('komoditas_id')->references('id')->on('komoditas')->onDelete('restrict');

            $table->index('user_id');
            $table->index('komoditas_id');
            $table->index('status');
            $table->index('tgl_tanam');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jadwal_tanam');
    }
};
