<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\SellersController;
use App\Http\Controllers\Api\ChatbotController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Public Routes - Authentication
Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Chatbot Route
Route::post('/chatbot/message', [ChatbotController::class, 'sendMessage']);

// Protected Routes
Route::middleware('auth:api')->group(function () {
    // Auth Routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/profile', [AuthController::class, 'updateProfile']);
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);

    // Products Routes
    Route::apiResource('products', ProductController::class);
    Route::get('/sellers/{sellerId}/products', [ProductController::class, 'sellerProducts']);

    // Categories Routes
    Route::apiResource('categories', CategoryController::class);

    // Orders Routes
    Route::apiResource('orders', OrderController::class);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    // Reviews Routes
    Route::apiResource('reviews', ReviewController::class);
    Route::get('/products/{product}/rating', [ReviewController::class, 'productRating']);

    // Sellers Routes
    Route::get('/sellers', [SellersController::class, 'index']);
    Route::get('/sellers/profile', [SellersController::class, 'profile']);
    Route::put('/sellers/profile', [SellersController::class, 'updateProfile']);
    Route::get('/sellers/statistics', [SellersController::class, 'statistics']);
    Route::get('/sellers/{seller}', [SellersController::class, 'show']);
});
