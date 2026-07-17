<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    use RefreshDatabase;

    public function test_profile_endpoint_returns_authenticated_user_data(): void
    {
        $user = User::factory()->create([
            'role' => User::ROLE_PEMBELI,
            'phone' => '081234567890',
            'address' => 'Initial address',
        ]);

        $response = $this->actingAs($user, 'api')->getJson('/api/auth/profile');

        $response->assertStatus(200);
        $response->assertJsonPath('data.id', $user->id);
        $response->assertJsonPath('data.role', $user->role);
    }

    public function test_midtrans_callback_updates_order_status_and_restores_stock_on_cancel(): void
    {
        $buyer = User::factory()->create(['role' => User::ROLE_PEMBELI]);
        $seller = User::factory()->create(['role' => User::ROLE_PETANI]);
        $category = \App\Models\Category::firstOrCreate([
            'name' => 'Test Category',
        ], [
            'description' => 'Category for callback test',
        ]);
        $product = Product::create([
            'seller_id' => $seller->id,
            'category_id' => $category->id,
            'name' => 'Test Product',
            'description' => 'Test product',
            'price' => 50000,
            'stock' => 5,
            'unit' => 'kg',
            'is_active' => true,
        ]);

        $order = Order::create([
            'buyer_id' => $buyer->id,
            'order_number' => 'ORD-TEST-123',
            'total_price' => 100000,
            'status' => Order::STATUS_PENDING,
            'shipping_address' => 'Test address',
            'payment_status' => 'pending',
        ]);

        OrderItem::create([
            'order_id' => $order->id,
            'product_id' => $product->id,
            'quantity' => 2,
            'unit_price' => 50000,
            'total_price' => 100000,
        ]);

        $product->refresh();
        $product->decrement('stock', 2);
        $product->refresh();

        $response = $this->postJson('/api/payments/callback', [
            'order_id' => $order->order_number,
            'status_code' => '200',
            'gross_amount' => '100000',
            'transaction_status' => 'cancel',
            'payment_type' => 'qris',
            'fraud_status' => 'accept',
            'signature_key' => hash('sha512', $order->order_number . '200' . '100000' . config('midtrans.server_key')),
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('success', true);

        $order->refresh();
        $this->assertSame(Order::STATUS_CANCELLED, $order->status);
        $this->assertSame('cancel', $order->payment_status);
        $this->assertSame('qris', $order->payment_type);

        $product->refresh();
        $this->assertEquals(5, $product->stock);
    }
}
