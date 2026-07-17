<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Models\Order;
use App\Models\Product;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    private function isAdmin()
    {
        return auth()->check() && auth()->user()->role === 'Admin';
    }

    /**
     * Get admin dashboard statistics
     */
    public function statistics()
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $totalPetani = User::where('role', 'Petani')->count();
        $totalPembeli = User::where('role', 'Pembeli')->count();
        $activeUsers = User::where('is_active', true)->count();
        $totalProducts = Product::active()->count();
        $totalStock = Product::active()->sum('stock');
        $totalOrders = Order::count();
        $totalRevenue = Order::where('status', '!=', 'cancelled')->sum('total_price');

        $unverifiedPetaniCount = User::where('role', 'Petani')->where('is_verified', false)->count();
        $pendingOrdersCount = Order::whereIn('status', ['pending', 'processing'])->count();
        $pendingPayoutsCount = User::where('role', 'Petani')->where('wallet_balance', '>', 0)->count();

        $recentOrders = Order::with('buyer')
            ->orderBy('created_at', 'desc')
            ->take(4)
            ->get()
            ->map(function ($order) {
                return [
                    'user' => $order->buyer->name ?? 'Pembeli',
                    'action' => 'Order ' . $order->order_number,
                    'role' => 'Pembeli',
                    'time' => $order->created_at->diffForHumans(),
                    'status' => $this->activityStatus($order->status),
                ];
            });

        $recentProducts = Product::with('seller')
            ->orderBy('updated_at', 'desc')
            ->take(3)
            ->get()
            ->map(function ($product) {
                return [
                    'user' => $product->seller->name ?? 'Petani',
                    'action' => 'Update produk ' . $product->name,
                    'role' => 'Petani',
                    'time' => $product->updated_at->diffForHumans(),
                    'status' => 'Sukses',
                ];
            });

        $transactions = Order::select(
            DB::raw('DATE_FORMAT(created_at, "%b") as label'),
            DB::raw('SUM(total_price) as value'),
            DB::raw('MIN(created_at) as min_created_at')
        )
        ->where('created_at', '>=', now()->subMonths(6))
        ->groupBy(DB::raw('DATE_FORMAT(created_at, "%b")'))
        ->orderBy('min_created_at', 'asc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total_petani' => $totalPetani,
                'total_pembeli' => $totalPembeli,
                'active_users' => $activeUsers,
                'total_products' => $totalProducts,
                'total_stock' => (int) $totalStock,
                'total_orders' => $totalOrders,
                'total_revenue' => (float) $totalRevenue,
                'recent_activity' => $recentOrders->concat($recentProducts)->take(7)->values(),
                'transactions' => $transactions,
                'unverified_petani_count' => $unverifiedPetaniCount,
                'pending_orders_count' => $pendingOrdersCount,
                'pending_payouts_count' => $pendingPayoutsCount,
            ]
        ]);
    }

    private function activityStatus(string $status): string
    {
        return match ($status) {
            'pending' => 'Pending',
            'cancelled' => 'Gagal',
            default => 'Sukses',
        };
    }

    /**
     * Get all users
     */
    public function users(Request $request)
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $query = User::query();

        if ($request->has('role') && $request->role !== 'Semua Role') {
            $query->where('role', $request->role);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $users,
        ]);
    }

    /**
     * Toggle user status
     */
    public function toggleStatus(Request $request, User $user)
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        if ($user->id === auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot toggle status of current logged in admin.',
            ], 400);
        }

        $user->is_active = !$user->is_active;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'User status updated successfully',
            'data' => $user,
        ]);
    }

    /**
     * Verify user registration
     */
    public function verifyUser(Request $request, User $user)
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $user->is_verified = true;
        $user->is_active = true;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'User verified successfully',
            'data' => $user,
        ]);
    }

    /**
     * Get admin activity logs
     */
    public function getActivityLogs()
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $logs = \App\Models\ActivityLog::orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $logs,
        ]);
    }

    /**
     * Get reference prices (Accessible by Admin and Petani)
     */
    public function getReferencePrices(Request $request)
    {
        $query = \App\Models\ReferencePrice::query();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'like', "%{$search}%");
        }

        $prices = $query->orderBy('name', 'asc')->get();

        return response()->json([
            'success' => true,
            'data' => $prices,
        ]);
    }

    /**
     * Update reference price (Admin only)
     */
    public function updateReferencePrice(Request $request)
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $validated = $request->validate([
            'name' => 'required|string|exists:reference_prices,name',
            'min_price' => 'required|integer|min:0',
            'max_price' => 'required|integer|min:0',
            'note' => 'nullable|string',
        ]);

        $refPrice = \App\Models\ReferencePrice::where('name', $validated['name'])->firstOrFail();
        $refPrice->update([
            'min_price' => $validated['min_price'],
            'max_price' => $validated['max_price'],
            'note' => $validated['note'] ?? $refPrice->note,
            'updated_by' => auth()->user()->name,
        ]);

        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Harga Referensi {$refPrice->name} diperbarui ke Rp " . number_format($refPrice->min_price, 0, ',', '.') . " - Rp " . number_format($refPrice->max_price, 0, ',', '.'),
            'Komoditas'
        );

        return response()->json([
            'success' => true,
            'message' => 'Reference price updated successfully',
            'data' => $refPrice,
        ]);
    }
}
