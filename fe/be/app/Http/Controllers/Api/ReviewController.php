<?php

namespace App\Http\Controllers\Api;

use App\Models\Review;
use App\Models\Order;
use App\Models\Product;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /**
     * Get reviews for product
     */
    public function index(Request $request)
    {
        $query = Review::query();

        if ($request->has('product_id')) {
            $query->where('product_id', $request->product_id);
        }

        $limit = $request->input('limit', 15);
        $page = $request->input('page', 1);
        $reviews = $query->with('reviewer', 'product')
                        ->orderBy('created_at', 'desc')
                        ->skip(($page - 1) * $limit)
                        ->take($limit)
                        ->get();

        return response()->json([
            'success' => true,
            'data' => $reviews,
        ]);
    }

    /**
     * Create review
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'order_id' => 'nullable|exists:orders,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500',
        ]);

        // Verify user has purchased this product
        $order = isset($validated['order_id'])
            ? Order::findOrFail($validated['order_id'])
            : Order::where('buyer_id', auth()->id())
                ->where('status', Order::STATUS_DELIVERED)
                ->whereHas('items', function ($query) use ($validated) {
                    $query->where('product_id', $validated['product_id']);
                })
                ->latest()
                ->first();

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Product can be reviewed after a delivered order exists',
            ], 422);
        }

        if ($order->buyer_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $hasProduct = $order->items()
                           ->where('product_id', $validated['product_id'])
                           ->exists();

        if (!$hasProduct) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found in this order',
            ], 422);
        }

        // Check if already reviewed
        $existingReview = Review::where('product_id', $validated['product_id'])
                               ->where('reviewer_id', auth()->id())
                               ->where('order_id', $validated['order_id'])
                               ->first();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'You already reviewed this product in this order',
            ], 422);
        }

        $review = Review::create([
            'product_id' => $validated['product_id'],
            'reviewer_id' => auth()->id(),
            'order_id' => $validated['order_id'],
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
        ]);

        $review->load('reviewer', 'product');

        return response()->json([
            'success' => true,
            'message' => 'Review created successfully',
            'data' => $review,
        ], 201);
    }

    /**
     * Update review
     */
    public function update(Request $request, Review $review)
    {
        if ($review->reviewer_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'rating' => 'sometimes|integer|min:1|max:5',
            'comment' => 'nullable|string|max:500',
        ]);

        $review->update($validated);
        $review->load('reviewer', 'product');

        return response()->json([
            'success' => true,
            'message' => 'Review updated successfully',
            'data' => $review,
        ]);
    }

    /**
     * Delete review
     */
    public function destroy(Review $review)
    {
        if ($review->reviewer_id !== auth()->id() && auth()->user()->role !== 'Admin') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review deleted successfully',
        ]);
    }

    /**
     * Get product average rating
     */
    public function productRating(Product $product)
    {
        $reviews = $product->reviews();
        $avgRating = $reviews->avg('rating');
        $totalReviews = $reviews->count();

        return response()->json([
            'success' => true,
            'data' => [
                'product_id' => $product->id,
                'average_rating' => round($avgRating, 2),
                'total_reviews' => $totalReviews,
            ],
        ]);
    }
}
