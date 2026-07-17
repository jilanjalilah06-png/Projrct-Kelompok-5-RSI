<?php

namespace App\Http\Controllers\Api;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    /**
     * Get user orders
     */
    public function index(Request $request)
    {
        $user = auth()->user();

        if ($user->role === 'Admin') {
            $query = Order::query();
        } elseif ($user->role === 'Petani') {
            $query = Order::whereHas('items.product', function ($productQuery) use ($user) {
                $productQuery->where('seller_id', $user->id);
            });
        } else {
            $query = Order::where('buyer_id', $user->id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('order_number', 'like', "%{$search}%")
                  ->orWhereHas('buyer', function ($buyerQuery) use ($search) {
                      $buyerQuery->where('name', 'like', "%{$search}%");
                  })
                  ->orWhereHas('items.product', function ($productQuery) use ($search) {
                      $productQuery->where('name', 'like', "%{$search}%");
                  });
            });
        }

        $limit = $request->input('limit', 15);
        $page = $request->input('page', 1);
        $orders = $query->with('buyer', 'items.product', 'items.product.seller', 'items.product.category')
                       ->orderBy('created_at', 'desc')
                       ->skip(($page - 1) * $limit)
                       ->take($limit)
                       ->get();

        return response()->json([
            'success' => true,
            'data' => $orders,
        ]);
    }

    /**
     * Get single order
     */
    public function show(Order $order)
    {
        $user = auth()->user();
        $isSellerOrder = $user->role === 'Petani' && $order->items()
            ->whereHas('product', function ($query) use ($user) {
                $query->where('seller_id', $user->id);
            })
            ->exists();

        if ($order->buyer_id !== $user->id && $user->role !== 'Admin' && !$isSellerOrder) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->load('items.product.seller', 'items.product.category', 'buyer');

        return response()->json([
            'success' => true,
            'data' => $order,
        ]);
    }

    /**
     * Create order
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'shipping_address' => 'required|string',
            'notes' => 'nullable|string',
        ]);

        $totalPrice = 0;
        $orderItems = [];

        // Validate stock and calculate total
        foreach ($validated['items'] as $item) {
            $product = Product::findOrFail($item['product_id']);

            if ($product->stock < $item['quantity']) {
                return response()->json([
                    'success' => false,
                    'message' => "Product {$product->name} insufficient stock",
                ], 422);
            }

            $itemTotal = $product->price * $item['quantity'];
            $totalPrice += $itemTotal;

            $orderItems[] = [
                'product_id' => $product->id,
                'quantity' => $item['quantity'],
                'unit_price' => $product->price,
                'total_price' => $itemTotal,
            ];
        }

        // Create order
        $order = Order::create([
            'buyer_id' => auth()->id(),
            'order_number' => 'ORD-' . Str::upper(Str::random(10)),
            'total_price' => $totalPrice,
            'shipping_address' => $validated['shipping_address'],
            'notes' => $validated['notes'] ?? null,
            'payment_status' => 'pending',
        ]);

        // Create order items
        foreach ($orderItems as $item) {
            OrderItem::create(array_merge($item, ['order_id' => $order->id]));

            // Reduce product stock
            Product::find($item['product_id'])->decrement('stock', $item['quantity']);
        }

        // Remove checked out items from user's cart
        $cart = \App\Models\Cart::where('buyer_id', auth()->id())->first();
        if ($cart) {
            $productIds = collect($orderItems)->pluck('product_id');
            $cart->items()->whereIn('product_id', $productIds)->delete();
        }

        $order->load('items.product.seller', 'items.product.category');

        // Send notifications to sellers
        $sellers = $order->items->map(function ($item) {
            return $item->product->seller;
        })->filter()->unique('id');

        foreach ($sellers as $seller) {
            \App\Models\Notification::send(
                $seller->id,
                'Pesanan Masuk',
                "Ada pesanan baru #{$order->order_number} dari " . auth()->user()->name,
                'order'
            );
        }

        // Send notification to buyer
        \App\Models\Notification::send(
            auth()->id(),
            'Pesanan Dibuat',
            "Pesanan #{$order->order_number} berhasil dibuat. Silakan lakukan pembayaran.",
            'order'
        );

        // Log activity
        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Pesanan #{$order->order_number} dibuat",
            'Pesanan'
        );

        try {
            $this->generateMidtransPayment($order);
        } catch (\Exception $e) {
            \Log::error('Midtrans Snap Error for order ' . $order->order_number . ': ' . $e->getMessage());
            $order->update([
                'payment_type' => 'midtrans_simulation',
                'payment_status' => 'simulation_pending',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => $order,
            'snap_token' => $order->snap_token,
            'redirect_url' => $order->redirect_url,
        ], 201);
    }

    public function createPayment(Order $order)
    {
        if ($order->buyer_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        if (in_array($order->status, ['confirmed', 'shipped', 'delivered', 'cancelled'], true)) {
            return response()->json([
                'success' => false,
                'message' => "Cannot create payment for order with status {$order->status}",
            ], 422);
        }

        try {
            $order->load('items.product', 'buyer');
            $this->generateMidtransPayment($order);

            return response()->json([
                'success' => true,
                'message' => 'Payment URL generated successfully',
                'data' => $order->fresh()->load('items.product.seller', 'items.product.category'),
                'snap_token' => $order->snap_token,
                'redirect_url' => $order->redirect_url,
            ]);
        } catch (\Exception $e) {
            \Log::error('Midtrans Snap Retry Error for order ' . $order->order_number . ': ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Midtrans payment could not be generated: ' . $e->getMessage(),
            ], 422);
        }
    }

    public function simulatePayment(Order $order)
    {
        if ($order->buyer_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        if (in_array($order->status, ['confirmed', 'shipped', 'delivered', 'cancelled'], true)) {
            return response()->json([
                'success' => false,
                'message' => "Cannot simulate payment for order with status {$order->status}",
            ], 422);
        }

        $order->update([
            'status' => Order::STATUS_CONFIRMED,
            'payment_type' => 'midtrans_simulation',
            'payment_status' => 'settlement',
        ]);

        $order->triggerPaymentSuccessNotificationsAndLogs();

        $order->load('buyer', 'items.product.seller', 'items.product.category');

        return response()->json([
            'success' => true,
            'message' => 'Simulated Midtrans payment completed',
            'data' => $order,
        ]);
    }

    /**
     * Update order status (admin only)
     */
    public function updateStatus(Request $request, Order $order)
    {
        $user = auth()->user();

        // 1. Authorization & Validation checks based on role
        if ($user->role === 'Admin') {
            $validated = $request->validate([
                'status' => 'required|in:pending,confirmed,shipped,delivered,cancelled,accept,cancel,packing,dikirim,dalam perjalanan',
            ]);
        } elseif ($user->role === 'Pembeli') {
            if ($order->buyer_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }
            $validated = $request->validate([
                'status' => 'required|in:delivered',
                'delivery_proof' => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
                'buyer_review' => 'nullable|string',
                'buyer_rating' => 'nullable|integer|min:1|max:5',
            ]);
        } elseif ($user->role === 'Petani') {
            $hasSellerItem = $order->items()
                ->whereHas('product', function ($query) use ($user) {
                    $query->where('seller_id', $user->id);
                })
                ->exists();

            if (!$hasSellerItem) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized',
                ], 403);
            }

            // Petani CANNOT change status to delivered
            $validated = $request->validate([
                'status' => 'required|in:pending,confirmed,shipped,cancelled,accept,cancel,packing,dikirim,dalam perjalanan',
            ]);
        } else {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        // If cancelling, restore stock
        if (in_array($validated['status'], ['cancelled', 'cancel']) && !in_array($order->status, ['cancelled', 'cancel'])) {
            foreach ($order->items as $item) {
                $item->product->increment('stock', $item->quantity);
            }
        }

        if ($request->hasFile('delivery_proof')) {
            $path = $request->file('delivery_proof')->store('proofs', 'public');
            $validated['delivery_proof'] = $path;
        }

        $oldStatus = $order->status;
        $order->update($validated);

        if ($order->status === 'delivered' && $oldStatus !== 'delivered') {
            $sellersAmount = [];
            foreach ($order->items as $item) {
                $sellerId = $item->product->seller_id;
                $itemTotal = $item->total_price;
                if (!isset($sellersAmount[$sellerId])) {
                    $sellersAmount[$sellerId] = 0;
                }
                $sellersAmount[$sellerId] += $itemTotal;
            }

            foreach ($sellersAmount as $sellerId => $amount) {
                $netAmount = $amount * 0.94; // 94% ke Petani, 6% komisi Admin
                $seller = \App\Models\User::find($sellerId);
                if ($seller) {
                    $seller->increment('wallet_balance', $netAmount);
                }
            }
        }

        // Send notifications based on status change
        if (in_array($order->status, ['shipped', 'dikirim', 'dalam perjalanan'])) {
            \App\Models\Notification::send(
                $order->buyer_id,
                'Pesanan Dikirim',
                "Pesanan #{$order->order_number} sedang dalam perjalanan ke alamat Anda.",
                'shipping'
            );
        } elseif ($order->status === 'delivered') {
            \App\Models\Notification::send(
                $order->buyer_id,
                'Pesanan Diterima',
                "Pesanan #{$order->order_number} telah sampai di alamat tujuan.",
                'shipping'
            );
        } elseif (in_array($order->status, ['cancelled', 'cancel'])) {
            \App\Models\Notification::send(
                $order->buyer_id,
                'Pesanan Dibatalkan',
                "Pesanan #{$order->order_number} telah dibatalkan.",
                'order'
            );
            $sellers = $order->items->map(function ($item) {
                return $item->product->seller ?? null;
            })->filter()->unique('id');
            foreach ($sellers as $seller) {
                \App\Models\Notification::send(
                    $seller->id,
                    'Pesanan Dibatalkan',
                    "Pesanan #{$order->order_number} telah dibatalkan.",
                    'order'
                );
            }
        }

        // Log activity
        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Status Pesanan #{$order->order_number} diubah menjadi " . strtoupper($order->status),
            'Pesanan'
        );
        $order->load('buyer', 'items.product.seller', 'items.product.category');

        return response()->json([
            'success' => true,
            'message' => 'Order status updated',
            'data' => $order,
        ]);
    }

    /**
     * Cancel order
     */
    public function cancel(Order $order)
    {
        if ($order->buyer_id !== auth()->id() && auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        if (in_array($order->status, ['shipped', 'delivered', 'cancelled'])) {
            return response()->json([
                'success' => false,
                'message' => "Cannot cancel order with status {$order->status}",
            ], 422);
        }

        // Restore stock
        foreach ($order->items as $item) {
            $item->product->increment('stock', $item->quantity);
        }

        $order->update(['status' => 'cancelled']);

        // Send notifications
        \App\Models\Notification::send(
            $order->buyer_id,
            'Pesanan Dibatalkan',
            "Pesanan #{$order->order_number} telah dibatalkan.",
            'order'
        );

        $sellers = $order->items->map(function ($item) {
            return $item->product->seller ?? null;
        })->filter()->unique('id');

        foreach ($sellers as $seller) {
            \App\Models\Notification::send(
                $seller->id,
                'Pesanan Dibatalkan',
                "Pesanan #{$order->order_number} telah dibatalkan oleh pembeli.",
                'order'
            );
        }

        // Log activity
        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Pesanan #{$order->order_number} dibatalkan",
            'Pesanan'
        );

        return response()->json([
            'success' => true,
            'message' => 'Order cancelled successfully',
            'data' => $order,
        ]);
    }

    private function generateMidtransPayment(Order $order): void
    {
        $serverKey = config('midtrans.server_key');
        $clientKey = config('midtrans.client_key');

        if (
            empty($serverKey) ||
            empty($clientKey) ||
            str_contains($serverKey, 'xxxxxxxx') ||
            str_contains($clientKey, 'xxxxxxxx')
        ) {
            throw new \RuntimeException('Midtrans credentials are not configured');
        }

        \Midtrans\Config::$serverKey = $serverKey;
        \Midtrans\Config::$isProduction = (bool) config('midtrans.is_production');
        \Midtrans\Config::$isSanitized = (bool) config('midtrans.is_sanitized');
        \Midtrans\Config::$is3ds = (bool) config('midtrans.is_3ds');

        $order->loadMissing('items.product', 'buyer');

        $itemDetails = $order->items->map(function ($item) {
            return [
                'id' => (string) $item->product_id,
                'price' => (int) $item->unit_price,
                'quantity' => (int) $item->quantity,
                'name' => substr($item->product->name, 0, 50),
            ];
        })->values()->all();

        $params = [
            'transaction_details' => [
                'order_id' => $order->order_number,
                'gross_amount' => (int) $order->total_price,
            ],
            'item_details' => $itemDetails,
            'customer_details' => [
                'first_name' => $order->buyer->name,
                'email' => $order->buyer->email,
                'phone' => $order->buyer->phone,
            ],
            'callbacks' => [
                'finish' => config('app.url') . '/payment/finish',
            ],
            'notification_url' => config('app.url') . '/api/payments/callback',
        ];

        $midtransResponse = \Midtrans\Snap::createTransaction($params);

        $order->update([
            'snap_token' => $midtransResponse->token,
            'redirect_url' => $midtransResponse->redirect_url,
            'payment_status' => 'pending',
        ]);
    }
}
