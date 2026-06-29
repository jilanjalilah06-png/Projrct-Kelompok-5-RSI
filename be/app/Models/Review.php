<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'product_id',
        'reviewer_id',
        'order_id',
        'rating',
        'comment',
    ];

    protected $casts = [
        'rating' => 'integer',
    ];

    /**
     * Relationships
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewer_id');
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * Scopes
     */
    public function scopeByRating($query, $rating)
    {
        return $query->where('rating', '>=', $rating);
    }

    public function scopeForProduct($query, $productId)
    {
        return $query->where('product_id', $productId);
    }
}
