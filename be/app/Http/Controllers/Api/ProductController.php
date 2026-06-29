<?php

namespace App\Http\Controllers\Api;

use App\Models\Product;
use App\Models\Category;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Get all products or filter by category
     */
    public function index(Request $request)
    {
        $query = Product::query()->active();

        if ($request->has('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where('name', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
        }

        if ($request->has('min_price') && $request->has('max_price')) {
            $query->whereBetween('price', [
                $request->min_price,
                $request->max_price,
            ]);
        }

        $products = $query->with('seller', 'category')
                         ->paginate($request->per_page ?? 15);

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
            'category_id' => 'required|exists:categories,id',
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'unit' => 'nullable|string|max:50',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('products', 'public');
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
        ]);

        $product->load('seller', 'category');

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
            'category_id' => 'sometimes|exists:categories,id',
            'name' => 'sometimes|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|numeric|min:0',
            'stock' => 'sometimes|integer|min:0',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'unit' => 'nullable|string|max:50',
            'is_active' => 'nullable|boolean',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('products', 'public');
            $validated['image'] = $imagePath;
        }

        $product->update($validated);
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
                          ->paginate(15);

        return response()->json([
            'success' => true,
            'data' => $products,
        ]);
    }
}
