<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlantingActivity extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'schedule_name',
        'activity_date',
        'title',
        'note',
        'cost',
    ];

    protected $casts = [
        'activity_date' => 'date:Y-m-d',
        'cost' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
