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
        Schema::create('harga_komoditas', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('komoditas_id');
            $table->decimal('harga_rp', 15, 2)->comment('Harga per kg/ton sesuai satuan komoditas');
            $table->string('satuan', 20)->default('kg');
            $table->date('tgl_berlaku');
            $table->enum('tren', ['naik', 'turun', 'stabil'])->default('stabil');
            $table->unsignedBigInteger('updated_by')->comment('FK ke users.id (admin)');
            $table->text('catatan')->nullable();
            $table->timestamps();

            $table->foreign('komoditas_id')->references('id')->on('komoditas')->onDelete('restrict');
            $table->foreign('updated_by')->references('id')->on('users')->onDelete('restrict');

            $table->index('komoditas_id');
            $table->index('tgl_berlaku');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('harga_komoditas');
    }
};
