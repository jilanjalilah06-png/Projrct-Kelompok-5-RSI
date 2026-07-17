<?php

namespace App\Http\Controllers\Api;

use App\Models\Category;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class CategoryController extends Controller
{
    /**
     * Get all categories
     */
    public function index()
    {
        $categories = Category::withCount('products')->get();

        return response()->json([
            'success' => true,
            'data' => $categories,
        ]);
    }

    /**
     * Get single category with products
     */
    public function show(Category $category)
    {
        $category->load('products');

        return response()->json([
            'success' => true,
            'data' => $category,
        ]);
    }

    /**
     * Create category (admin only)
     */
    public function store(Request $request)
    {
        if (auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can create categories',
            ], 403);
        }

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:categories', Rule::in(['Beras', 'Jagung'])],
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('categories', 'public');
        }

        $category = Category::create([
            'name' => $validated['name'],
            'description' => $validated['description'] ?? null,
            'image' => $imagePath,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Category created successfully',
            'data' => $category,
        ], 201);
    }

    /**
     * Update category (admin only)
     */
    public function update(Request $request, Category $category)
    {
        if (auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can update categories',
            ], 403);
        }

        $validated = $request->validate([
            'name' => ['sometimes', 'string', Rule::unique('categories', 'name')->ignore($category->id), Rule::in(['Beras', 'Jagung'])],
            'description' => 'nullable|string',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('categories', 'public');
            $validated['image'] = $imagePath;
        }

        $category->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Category updated successfully',
            'data' => $category,
        ]);
    }

    /**
     * Delete category (admin only)
     */
    public function destroy(Category $category)
    {
        if (auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can delete categories',
            ], 403);
        }

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted successfully',
        ]);
    }
}
