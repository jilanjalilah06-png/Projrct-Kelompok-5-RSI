<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    const STATUS_PENDING = 'pending';
    const STATUS_CONFIRMED = 'confirmed';
    const STATUS_SHIPPED = 'shipped';
    const STATUS_DELIVERED = 'delivered';
    const STATUS_CANCELLED = 'cancelled';

    protected $fillable = [
        'buyer_id',
        'order_number',
        'total_price',
        'status',
        'shipping_address',
        'notes',
        'snap_token',
        'redirect_url',
        'payment_type',
        'payment_status',
        'delivery_proof',
        'buyer_review',
        'buyer_rating',
    ];

    protected $casts = [
        'total_price' => 'decimal:2',
    ];

    /**
     * Relationships
     */
    public function buyer()
    {
        return $this->belongsTo(User::class, 'buyer_id');
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * Scopes
     */
    public function scopeByStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function triggerPaymentSuccessNotificationsAndLogs()
    {
        $this->loadMissing('buyer', 'items.product.seller');

        // Send notification to buyer
        if ($this->buyer) {
            \App\Models\Notification::send(
                $this->buyer_id,
                'Pembayaran Berhasil',
                "Pembayaran untuk Pesanan #{$this->order_number} telah berhasil kami terima.",
                'order'
            );
        }

        // Send notifications to sellers
        $sellers = $this->items->map(function ($item) {
            return $item->product->seller ?? null;
        })->filter()->unique('id');

        foreach ($sellers as $seller) {
            \App\Models\Notification::send(
                $seller->id,
                'Pembayaran Diterima',
                "Pembayaran untuk Pesanan #{$this->order_number} telah diselesaikan oleh pembeli.",
                'order'
            );
        }

        // Log activity
        \App\Models\ActivityLog::log(
            $this->buyer->name ?? 'System',
            "Pembayaran untuk Pesanan #{$this->order_number} berhasil",
            'Keuangan'
        );
    }

    public function scopeCompleted($query)
    {
        return $query->whereIn('status', [self::STATUS_DELIVERED]);
    }
}
