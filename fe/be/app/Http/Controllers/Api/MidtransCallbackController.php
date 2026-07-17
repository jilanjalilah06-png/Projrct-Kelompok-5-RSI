<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MidtransCallbackController extends Controller
{
    public function handle(Request $request)
    {
        $payload = $request->json()->all();
        if (empty($payload)) {
            $payload = $request->all();
        }

        $serverKey = (string) config('midtrans.server_key');
        $orderId = (string) ($payload['order_id'] ?? '');
        $statusCode = (string) ($payload['status_code'] ?? '');
        $grossAmount = (string) ($payload['gross_amount'] ?? '');
        $signatureKey = (string) ($payload['signature_key'] ?? $request->header('X-Midtrans-Signature'));

        $calculatedSignature = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);

        if ($signatureKey !== '' && $calculatedSignature !== $signatureKey) {
            Log::warning('Midtrans Callback Signature Mismatch!', [
                'order_id' => $orderId,
                'received_sig' => $signatureKey,
                'calculated_sig' => $calculatedSignature,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Invalid signature key',
            ], 403);
        }

        $transactionStatus = (string) ($payload['transaction_status'] ?? 'pending');
        $paymentType = (string) ($payload['payment_type'] ?? 'midtrans');
        $fraudStatus = (string) ($payload['fraud_status'] ?? '');

        $order = Order::where('order_number', $orderId)->first();

        if (! $order) {
            Log::warning('Midtrans Callback Order Not Found', ['order_id' => $orderId]);

            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        $order->payment_type = $paymentType;
        $order->payment_status = $transactionStatus;

        $mappedStatus = $this->mapTransactionStatus($transactionStatus, $fraudStatus);
        $previousStatus = $order->status;
        $order->status = $mappedStatus;

        if ($mappedStatus === Order::STATUS_CANCELLED && $previousStatus !== Order::STATUS_CANCELLED) {
            $order->loadMissing('items.product');
            foreach ($order->items as $item) {
                $item->product?->increment('stock', $item->quantity);
            }
        }

        $order->save();

        if ($mappedStatus === Order::STATUS_CONFIRMED && $previousStatus !== Order::STATUS_CONFIRMED) {
            $order->triggerPaymentSuccessNotificationsAndLogs();
        }

        Log::info('Midtrans Callback Handled', [
            'order_id' => $orderId,
            'status' => $order->status,
            'payment_status' => $order->payment_status,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Callback handled successfully',
        ]);
    }

    private function mapTransactionStatus(string $transactionStatus, string $fraudStatus): string
    {
        return match ($transactionStatus) {
            'capture' => $fraudStatus === 'challenge' ? Order::STATUS_PENDING : Order::STATUS_CONFIRMED,
            'settlement' => Order::STATUS_CONFIRMED,
            'pending' => Order::STATUS_PENDING,
            'deny', 'expire', 'cancel' => Order::STATUS_CANCELLED,
            default => Order::STATUS_PENDING,
        };
    }
}
