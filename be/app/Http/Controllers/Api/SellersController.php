<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class SellersController extends Controller
{
    /**
     * Get all sellers (Petani)
     */
    public function index(Request $request)
    {
        $query = User::petani()->verified();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'like', "%{$search}%")
                  ->orWhere('shop_name', 'like', "%{$search}%");
        }

        $sellers = $query->withCount('products')
                        ->paginate($request->per_page ?? 15);

        return response()->json([
            'success' => true,
            'data' => $sellers,
        ]);
    }

    /**
     * Get single seller with products
     */
    public function show(User $seller)
    {
        if ($seller->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'User is not a seller',
            ], 404);
        }

        $seller->load('products');

        return response()->json([
            'success' => true,
            'data' => $seller,
        ]);
    }

    /**
     * Get current seller profile (for Petani)
     */
    public function profile()
    {
        if (auth()->user()->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'Only sellers can access this endpoint',
            ], 403);
        }

        $seller = auth()->user()->load('products');

        return response()->json([
            'success' => true,
            'data' => $seller,
        ]);
    }

    /**
     * Update seller profile
     */
    public function updateProfile(Request $request)
    {
        if (auth()->user()->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'Only sellers can update profile',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string',
            'address' => 'nullable|string',
            'shop_name' => 'sometimes|string|max:255',
            'shop_description' => 'nullable|string',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($request->hasFile('avatar')) {
            $avatarPath = $request->file('avatar')->store('avatars', 'public');
            $validated['avatar'] = $avatarPath;
        }

        auth()->user()->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => auth()->user(),
        ]);
    }

    /**
     * Get seller statistics
     */
    public function statistics()
    {
        if (auth()->user()->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'Only sellers can access this endpoint',
            ], 403);
        }

        $user = auth()->user();
        $totalProducts = $user->products()->count();
        $activeProducts = $user->products()->active()->count();
        $totalOrders = $user->products()
                           ->with('orderItems')
                           ->get()
                           ->sum(function($product) {
                               return $product->orderItems->count();
                           });

        $totalRevenue = $user->products()
                            ->with('orderItems')
                            ->get()
                            ->sum(function($product) {
                                return $product->orderItems->sum('total_price');
                            });

        return response()->json([
            'success' => true,
            'data' => [
                'total_products' => $totalProducts,
                'active_products' => $activeProducts,
                'total_orders' => $totalOrders,
                'total_revenue' => $totalRevenue,
            ],
        ]);
    }
}
