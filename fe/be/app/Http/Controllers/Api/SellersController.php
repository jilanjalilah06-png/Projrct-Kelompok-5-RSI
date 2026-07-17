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

        $limit = $request->input('limit', $request->input('per_page', 15));
        $page = $request->input('page', 1);
        $sellers = $query->withCount('products')
                        ->skip(($page - 1) * $limit)
                        ->take($limit)
                        ->get();

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
    public function statistics(Request $request)
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

        // Optional month filter
        $targetDate = now();
        $isFiltered = false;
        if ($request->has('month') && !empty($request->month)) {
            // e.g. "Juli 2026" or "July 2026"
            $monthStr = $request->month;
            // Map Indonesian month names to English for strtotime/Carbon parsing
            $idToEn = [
                'januari' => 'january', 'februari' => 'february', 'maret' => 'march',
                'april' => 'april', 'mei' => 'may', 'juni' => 'june',
                'juli' => 'july', 'agustus' => 'august', 'september' => 'september',
                'oktober' => 'october', 'november' => 'november', 'desember' => 'december'
            ];
            $lowerMonth = strtolower($monthStr);
            foreach ($idToEn as $id => $en) {
                $lowerMonth = str_replace($id, $en, $lowerMonth);
            }
            try {
                $targetDate = \Illuminate\Support\Carbon::parse($lowerMonth);
                $isFiltered = true;
            } catch (\Exception $e) {
                $targetDate = now();
            }
        }

        // Get completed/delivered orders that contain this seller's products
        $completedOrdersQuery = \App\Models\Order::whereIn('status', ['delivered', 'completed', 'selesai'])
            ->whereHas('items.product', function ($query) use ($user) {
                $query->where('seller_id', $user->id);
            });

        if ($isFiltered) {
            $completedOrdersQuery->whereBetween('created_at', [
                $targetDate->copy()->startOfMonth(),
                $targetDate->copy()->endOfMonth()
            ]);
        }

        $completedOrders = $completedOrdersQuery->with(['items.product' => function ($query) use ($user) {
                $query->where('seller_id', $user->id);
            }])
            ->get();

        $totalOrders = $completedOrders->count();

        // Calculate gross revenue (sum of item total price for this seller's items in successful orders)
        $totalRevenue = 0;
        foreach ($completedOrders as $order) {
            foreach ($order->items as $item) {
                if ($item->product && $item->product->seller_id == $user->id) {
                    $totalRevenue += $item->total_price;
                }
            }
        }

        // Net revenue (94% of gross)
        $netRevenue = $totalRevenue * 0.94;

        // Calculate 6 months sales data for chart relative to targetDate
        $chartData = [];
        // Fetch orders for the entire 6 month range to calculate chart accurately
        $chartOrders = \App\Models\Order::whereIn('status', ['delivered', 'completed', 'selesai'])
            ->whereHas('items.product', function ($query) use ($user) {
                $query->where('seller_id', $user->id);
            })
            ->whereBetween('created_at', [
                $targetDate->copy()->subMonths(5)->startOfMonth(),
                $targetDate->copy()->endOfMonth()
            ])
            ->with(['items.product' => function ($query) use ($user) {
                $query->where('seller_id', $user->id);
            }])
            ->get();

        for ($i = 5; $i >= 0; $i--) {
            $monthStart = $targetDate->copy()->subMonths($i)->startOfMonth();
            $monthEnd = $targetDate->copy()->subMonths($i)->endOfMonth();

            $monthGross = 0;
            foreach ($chartOrders as $order) {
                if ($order->created_at >= $monthStart && $order->created_at <= $monthEnd) {
                    foreach ($order->items as $item) {
                        if ($item->product && $item->product->seller_id == $user->id) {
                            $monthGross += $item->total_price;
                        }
                    }
                }
            }
            $chartData[] = $monthGross;
        }

        return response()->json([
            'success' => true,
            'data' => [
                'total_products' => $totalProducts,
                'active_products' => $activeProducts,
                'total_orders' => $totalOrders,
                'total_revenue' => (double)$totalRevenue,
                'net_revenue' => (double)$netRevenue,
                'chart_data' => $chartData,
            ],
        ]);
    }
}
