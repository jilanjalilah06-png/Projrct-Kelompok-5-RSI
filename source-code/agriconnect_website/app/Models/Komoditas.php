<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Komoditas extends Model
{
    protected $table = 'komoditas';

    protected $fillable = [
        'nama_komoditas',
        'siklus_hari_default',
        'satuan',
        'deskripsi',
        'active',
    ];

    protected $casts = [
        'siklus_hari_default' => 'integer',
        'active' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
