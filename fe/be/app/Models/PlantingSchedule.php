<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlantingSchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'plant',
        'land',
        'start_date',
        'harvest_date',
        'harvest_end_date',
        'status',
    ];

    protected $casts = [
        'start_date' => 'date:Y-m-d',
        'harvest_date' => 'date:Y-m-d',
        'harvest_end_date' => 'date:Y-m-d',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
