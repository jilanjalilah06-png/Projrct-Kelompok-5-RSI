<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('planting_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('schedule_name');
            $table->date('activity_date');
            $table->string('title');
            $table->text('note')->nullable();
            $table->unsignedBigInteger('cost')->default(0);
            $table->timestamps();

            $table->index(['user_id', 'schedule_name']);
            $table->index('activity_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('planting_activities');
    }
};
