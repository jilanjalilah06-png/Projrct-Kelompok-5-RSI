<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_name',
        'event',
        'category',
    ];

    public static function log($userName, $event, $category)
    {
        return self::create([
            'user_name' => $userName,
            'event' => $event,
            'category' => $category,
        ]);
    }
}
