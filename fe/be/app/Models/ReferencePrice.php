<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ReferencePrice extends Model
{
    protected $fillable = [
        'name',
        'min_price',
        'max_price',
        'note',
        'updated_by',
    ];
}
