<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Product;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $cart = Cart::firstOrCreate(['buyer_id' => $user->id]);
        $cart->load('items.product');

        return response()->json([
            'success' => true,
            'data' => $cart,
        ]);
    }

    public function add(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $user = auth()->user();
        $cart = Cart::firstOrCreate(['buyer_id' => $user->id]);

        $product = Product::findOrFail($validated['product_id']);
        $qty = $validated['quantity'] ?? 1;

        $cartItem = $cart->items()->where('product_id', $product->id)->first();
        if ($cartItem) {
            $cartItem->quantity += $qty;
            $cartItem->unit_price = $product->price;
            $cartItem->total_price = $cartItem->quantity * $product->price;
            $cartItem->save();
        } else {
            $cartItem = $cart->items()->create([
                'product_id' => $product->id,
                'quantity' => $qty,
                'unit_price' => $product->price,
                'total_price' => $qty * $product->price,
            ]);
        }

        $cart->load('items.product');

        return response()->json([
            'success' => true,
            'message' => 'Item added to cart',
            'data' => $cart,
        ]);
    }

    public function remove(Request $request, CartItem $item)
    {
        $user = auth()->user();
        $cart = Cart::where('buyer_id', $user->id)->first();
        if (!$cart || $item->cart_id !== $cart->id) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        $item->delete();

        $cart->load('items.product');

        return response()->json(['success' => true, 'data' => $cart]);
    }

    public function update(Request $request, CartItem $item)
    {
        $validated = $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $user = auth()->user();
        $cart = Cart::where('buyer_id', $user->id)->first();
        if (!$cart || $item->cart_id !== $cart->id) {
            return response()->json(['success' => false, 'message' => 'Not found'], 404);
        }

        $item->quantity = $validated['quantity'];
        $item->unit_price = $item->product->price;
        $item->total_price = $item->quantity * $item->product->price;
        $item->save();

        $cart->load('items.product');

        return response()->json(['success' => true, 'data' => $cart]);
    }

    public function clear()
    {
        $user = auth()->user();
        $cart = Cart::where('buyer_id', $user->id)->first();
        if ($cart) {
            $cart->items()->delete();
        }

        return response()->json(['success' => true]);
    }
}
