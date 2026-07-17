<?php

namespace App\Http\Controllers\Api;

use App\Models\Product;
use App\Models\Category;
use App\Models\ReferencePrice;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ProductController extends Controller
{
    private function applyReferencePriceLogic($validated, $categoryName, $productName)
    {
        $nameLower = strtolower($productName);
        $isPremium = str_contains($nameLower, 'premium') || str_contains($nameLower, 'grade a') || str_contains($nameLower, 'organik');
        $refName = $categoryName . ' ' . ($isPremium ? 'Premium' : 'Standar');
        
        $refPrice = ReferencePrice::where('name', $refName)->first();
        if ($refPrice) {
            if ($validated['price'] < $refPrice->min_price) {
                $validated['status'] = 'ditolak';
                $validated['is_active'] = false;
            } elseif ($validated['price'] > $refPrice->max_price) {
                $validated['status'] = 'tinjau';
                $validated['is_active'] = false;
            } else {
                $validated['status'] = 'public';
                $validated['is_active'] = true;
            }
        } else {
            // fallback
            $validated['status'] = 'tinjau';
            $validated['is_active'] = false;
        }
        return $validated;
    }
    /**
     * Get all products or filter by category
     */
    public function index(Request $request)
    {
        $query = Product::query();

        // Admin can see all products, other users (or guests) only see active products
        $user = auth('api')->user();
        if (!$user || $user->role !== 'Admin') {
            $query->active();
        }

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('seller_id')) {
            $query->where('seller_id', $request->seller_id);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        if ($request->has('min_price') && $request->has('max_price')) {
            $query->whereBetween('price', [
                $request->min_price,
                $request->max_price,
            ]);
        }

        $limit = $request->input('limit', $request->input('per_page', 15));
        $page = $request->input('page', 1);
        $products = $query->with('seller', 'category')
                         ->skip(($page - 1) * $limit)
                         ->take($limit)
                         ->get();

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }

    /**
     * Get single product
     */
    public function show(Product $product)
    {
        $product->load('seller', 'category', 'reviews.reviewer');

        return response()->json([
            'success' => true,
            'data' => $product,
        ]);
    }

    /**
     * Create product (sellers only)
     */
    public function store(Request $request)
    {
        if (auth()->user()->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'Only farmers (Petani) can create products',
            ], 403);
        }

        $validated = $request->validate([
            'category_id' => [
                'required',
                Rule::exists('categories', 'id')->whereIn('name', ['Beras', 'Jagung']),
            ],
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'unit' => 'nullable|string|max:50',
            'status' => 'nullable|string|in:tinjau,public,ditolak',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('products', 'public');
        }

        $category = Category::find($validated['category_id']);
        if (auth()->user()->role !== 'Admin') {
            $validated = $this->applyReferencePriceLogic($validated, $category->name, $validated['name']);
        } else {
            $validated['status'] = $validated['status'] ?? 'public';
            $validated['is_active'] = $validated['status'] === 'public';
        }

        $product = Product::create([
            'seller_id' => auth()->id(),
            'category_id' => $validated['category_id'],
            'name' => $validated['name'],
            'description' => $validated['description'] ?? null,
            'price' => $validated['price'],
            'stock' => $validated['stock'],
            'image' => $imagePath,
            'unit' => $validated['unit'] ?? 'kg',
            'is_active' => $validated['is_active'],
            'status' => $validated['status'],
        ]);

        $product->load('seller', 'category');
        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Produk {$product->name} ditambahkan",
            'Produk'
        );

        return response()->json([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product,
        ], 201);
    }

    /**
     * Update product
     */
    public function update(Request $request, Product $product)
    {
        if ($product->seller_id !== auth()->id() && auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'category_id' => [
                'sometimes',
                Rule::exists('categories', 'id')->whereIn('name', ['Beras', 'Jagung']),
            ],
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|numeric|min:0',
            'stock' => 'sometimes|integer|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'unit' => 'nullable|string|max:50',
            'is_active' => 'nullable|boolean',
            'status' => 'sometimes|string|in:tinjau,public,ditolak',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('products', 'public');
            $validated['image'] = $imagePath;
        }

        if (auth()->user()->role !== 'Admin') {
            // Petani update -> re-eval logic
            $tempCatId = $validated['category_id'] ?? $product->category_id;
            $tempName = $validated['name'] ?? $product->name;
            $category = Category::find($tempCatId);
            $validated['price'] = $validated['price'] ?? $product->price;
            $validated = $this->applyReferencePriceLogic($validated, $category->name, $tempName);
        } else {
            // Admin update
            if (isset($validated['status'])) {
                $validated['is_active'] = ($validated['status'] === 'public');
            } elseif (isset($validated['is_active'])) {
                $validated['status'] = $validated['is_active'] ? 'public' : 'tinjau';
            }
        }

        $product->update($validated);

        // Send notification to seller if admin changes status
        if (auth()->user()->role === 'Admin') {
            $statusMsg = '';
            if (isset($validated['status'])) {
                if ($validated['status'] === 'public') {
                    $statusMsg = "ditolak"; // just placeholder, but let's check
                    \App\Models\Notification::send(
                        $product->seller_id,
                        "Produk Disetujui",
                        "Produk {$product->name} telah disetujui dan ditayangkan oleh Admin.",
                        "promo" // maps to NotificationKind.promo/sale/order
                    );
                } elseif ($validated['status'] === 'ditolak') {
                    \App\Models\Notification::send(
                        $product->seller_id,
                        "Produk Ditolak",
                        "Produk {$product->name} ditolak oleh Admin.",
                        "promo"
                    );
                }
            }
        }

        \App\Models\ActivityLog::log(
            auth()->user()->name,
            "Stok/Harga {$product->name} diperbarui",
            'Produk'
        );
        $product->load('seller', 'category');

        return response()->json([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product,
        ]);
    }

    /**
     * Delete product
     */
    public function destroy(Product $product)
    {
        if ($product->seller_id !== auth()->id() && auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully',
        ]);
    }

    /**
     * Get seller products
     */
    public function sellerProducts($sellerId)
    {
        $products = Product::where('seller_id', $sellerId)
                          ->with('category')
                          ->get();

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }

    /**
     * Send review note for product
     */
    public function sendReviewNote(Request $request, Product $product)
    {
        if (auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        $validated = $request->validate([
            'note' => 'required|string',
        ]);

        \App\Models\Notification::send(
            $product->seller_id,
            "Catatan Review Produk: " . $product->name,
            $validated['note'],
            "promo" // Maps to NotificationKind.promo/sale/order
        );

        return response()->json([
            'success' => true,
            'message' => 'Catatan berhasil dikirim ke petani.',
        ]);
    }
}
