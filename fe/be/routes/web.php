<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// Route to handle Midtrans finish redirect and forward users to frontend
Route::get('/payment/finish', function (Request $request) {
    $frontend = env('FRONTEND_URL') ?: (config('app.url') ?: 'http://localhost:53536');
    $orderId = $request->query('order_id', '');
    $status = $request->query('status_code', $request->query('transaction_status', ''));

    // Redirect to frontend with query params so frontend can show order status
    $target = rtrim($frontend, '/') . '/?payment_finish=1';
    if (!empty($orderId)) {
        $target .= '&order_id=' . urlencode($orderId);
    }
    if (!empty($status)) {
        $target .= '&status=' . urlencode($status);
    }

    return redirect()->away($target);
});

Route::get('/', function () {
    return view('welcome');
});
