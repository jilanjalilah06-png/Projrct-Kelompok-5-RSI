<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\WithdrawalController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\SellersController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\PetaniController;
use App\Http\Controllers\Api\MidtransCallbackController;
use App\Http\Controllers\Api\PlantingActivityController;
use App\Http\Controllers\Api\FarmerLandController;
use App\Http\Controllers\Api\PlantingScheduleController;

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
Route::post('/auth/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/auth/request-otp', [AuthController::class, 'requestOtp']);
Route::post('/auth/reset-password-otp', [AuthController::class, 'resetPasswordOtp']);
Route::post('/chatbot/message', [AuthController::class, 'chatbotMessage']);

// Public Routes - Midtrans Webhook Callback
Route::post('/payments/callback', [MidtransCallbackController::class, 'handle']);

// Public Route - Serve storage files with CORS (for Flutter Web)
Route::get('/file/{path}', function (string $path) {
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath)) {
        abort(404);
    }
    return response()->file($fullPath, [
        'Access-Control-Allow-Origin' => '*',
        'Cache-Control' => 'public, max-age=86400',
    ]);
})->where('path', '.*');

// Protected Routes
Route::middleware('auth:api')->group(function () {
    // Auth Routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::get('/auth/profile', [AuthController::class, 'profile']);
    Route::match(['put', 'post'], '/auth/profile', [AuthController::class, 'updateProfile']);
    Route::post('/auth/refresh', [AuthController::class, 'refresh']);
    Route::post('/auth/change-password', [AuthController::class, 'changePassword']);
    Route::get('/notifications', [AuthController::class, 'getNotifications']);
    Route::post('/notifications/mark-read', [AuthController::class, 'markAllNotificationsRead']);
    Route::post('/notifications/{id}/mark-read', [AuthController::class, 'markNotificationRead']);

    // Withdrawals
    Route::get('/withdrawals', [WithdrawalController::class, 'index']);
    Route::post('/withdrawals', [WithdrawalController::class, 'store']);

    // Products Routes
    Route::apiResource('products', ProductController::class);
    Route::get('/sellers/{sellerId}/products', [ProductController::class, 'sellerProducts']);
    Route::post('/products/{product}/note', [ProductController::class, 'sendReviewNote']);

    // Cart Routes
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'add']);
    Route::patch('/cart/items/{item}', [CartController::class, 'update']);
    Route::delete('/cart/items/{item}', [CartController::class, 'remove']);
    Route::post('/cart/clear', [CartController::class, 'clear']);

    // Categories Routes
    Route::apiResource('categories', CategoryController::class);

    // Orders Routes
    Route::apiResource('orders', OrderController::class);
    Route::post('/orders/{order}/payment', [OrderController::class, 'createPayment']);
    Route::post('/orders/{order}/simulate-payment', [OrderController::class, 'simulatePayment']);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    // Planting Activities Routes
    Route::get('/planting-activities', [PlantingActivityController::class, 'index']);
    Route::post('/planting-activities/sync', [PlantingActivityController::class, 'sync']);

    // Farmer Lands & Mapping Routes
    Route::get('/farmer-lands', [FarmerLandController::class, 'index']);
    Route::post('/farmer-lands', [FarmerLandController::class, 'store']);
    Route::delete('/farmer-lands/{land}', [FarmerLandController::class, 'destroy']);

    // Planting Schedules Routes
    Route::get('/planting-schedules', [PlantingScheduleController::class, 'index']);
    Route::post('/planting-schedules', [PlantingScheduleController::class, 'store']);
    Route::put('/planting-schedules/{schedule}', [PlantingScheduleController::class, 'update']);
    Route::delete('/planting-schedules/{schedule}', [PlantingScheduleController::class, 'destroy']);

    // Reviews Routes
    Route::apiResource('reviews', ReviewController::class);
    Route::get('/products/{product}/rating', [ReviewController::class, 'productRating']);

    // Sellers Routes
    Route::get('/sellers', [SellersController::class, 'index']);
    Route::get('/sellers/profile', [SellersController::class, 'profile']);
    Route::put('/sellers/profile', [SellersController::class, 'updateProfile']);
    Route::get('/sellers/statistics', [SellersController::class, 'statistics']);
    Route::get('/sellers/{seller}', [SellersController::class, 'show']);

    // Admin Routes
    Route::get('/admin/statistics', [AdminController::class, 'statistics']);
    Route::get('/admin/users', [AdminController::class, 'users']);
    Route::post('/admin/users/{user}/toggle', [AdminController::class, 'toggleStatus']);
    Route::post('/admin/users/{user}/verify', [AdminController::class, 'verifyUser']);
    Route::post('/admin/petani/{user}/toggle', [PetaniController::class, 'toggleStatus']);
    Route::get('/admin/activity-logs', [AdminController::class, 'getActivityLogs']);
    Route::get('/admin/reference-prices', [AdminController::class, 'getReferencePrices']);
    Route::post('/admin/reference-prices/update', [AdminController::class, 'updateReferencePrice']);
    Route::get('/admin/payouts/pending', [WithdrawalController::class, 'getPendingPayouts']);
    Route::post('/admin/payouts/process', [WithdrawalController::class, 'processPayout']);
});
