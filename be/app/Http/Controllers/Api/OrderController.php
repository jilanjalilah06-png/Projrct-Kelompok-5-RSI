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
        $query = Order::where('buyer_id', auth()->id());

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $orders = $query->with('items.product', 'items.product.seller')
                       ->orderBy('created_at', 'desc')
                       ->paginate(15);

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
        if ($order->buyer_id !== auth()->id() && auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $order->load('items.product.seller', 'buyer');

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
        ]);

        // Create order items
        foreach ($orderItems as $item) {
            OrderItem::create(array_merge($item, ['order_id' => $order->id]));

            // Reduce product stock
            Product::find($item['product_id'])->decrement('stock', $item['quantity']);
        }

        $order->load('items.product.seller');

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => $order,
        ], 201);
    }

    /**
     * Update order status (admin only)
     */
    public function updateStatus(Request $request, Order $order)
    {
        if (auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can update order status',
            ], 403);
        }

        $validated = $request->validate([
            'status' => 'required|in:pending,confirmed,shipped,delivered,cancelled',
        ]);

        // If cancelling, restore stock
        if ($validated['status'] === 'cancelled' && $order->status !== 'cancelled') {
            foreach ($order->items as $item) {
                $item->product->increment('stock', $item->quantity);
            }
        }

        $order->update($validated);

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

        return response()->json([
            'success' => true,
            'message' => 'Order cancelled successfully',
            'data' => $order,
        ]);
    }
}
