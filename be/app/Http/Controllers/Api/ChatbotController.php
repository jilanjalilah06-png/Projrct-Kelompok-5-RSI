<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\User;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Tymon\JWTAuth\Facades\JWTAuth;

class ChatbotController extends Controller
{
    /**
     * Send message to n8n chatbot or fallback locally.
     */
    public function sendMessage(Request $request)
    {
        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        $message = $validated['message'];
        $user = null;

        // Try to authenticate optionally to inject user context
        try {
            if ($token = JWTAuth::getToken()) {
                $user = JWTAuth::toUser($token);
            }
        } catch (\Exception $e) {
            // Keep user as guest if token invalid or absent
        }

        // 1. Try sending the request to n8n Webhook
        try {
            // Service name 'n8n' resolves within the docker-compose bridge network
            $n8nUrl = 'http://n8n:5678/webhook/1/webhook-receiver/agri-asisten';
            
            $payload = [
                'message' => $message,
                'user' => $user ? [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                    'shop_name' => $user->shop_name,
                    'address' => $user->address,
                ] : [
                    'id' => null,
                    'name' => 'Guest',
                    'role' => 'Guest',
                ]
            ];

            // Set a low timeout so fallback triggers fast if n8n is down/not ready
            $response = Http::timeout(3)->post($n8nUrl, $payload);

            if ($response->successful()) {
                $data = $response->json();
                
                // Extract answer from n8n response structures
                $reply = '';
                if (is_array($data)) {
                    $reply = $data['reply'] ?? $data['response'] ?? $data['output'] ?? $data['message'] ?? '';
                    if (empty($reply) && isset($data[0])) {
                        $firstElement = $data[0];
                        $reply = $firstElement['reply'] ?? $firstElement['response'] ?? $firstElement['output'] ?? $firstElement['message'] ?? '';
                    }
                }
                
                if (empty($reply)) {
                    $reply = $response->body();
                }

                return response()->json([
                    'success' => true,
                    'reply' => $reply,
                    'source' => 'n8n'
                ]);
            }
        } catch (\Exception $e) {
            // Log or ignore to trigger DB fallback
        }

        // 2. Fallback to intelligent database-driven logic
        $reply = $this->getDatabaseDrivenReply($message, $user);

        return response()->json([
            'success' => true,
            'reply' => $reply,
            'source' => 'local_fallback'
        ]);
    }

    /**
     * Clean query by removing common Indonesian stop words.
     */
    private function cleanQuery(string $text): string
    {
        $cleaned = preg_replace('/[?,.\!]/', ' ', $text);
        $words = preg_split('/\s+/', strtolower($cleaned));
        $stopWords = [
            'apakah', 'adakah', 'ada', 'berapa', 'harga', 'stok', 'jual', 'daftar', 'tampilkan', 'cari', 
            'tentang', 'toko', 'tani', 'petani', 'mitra', 'penjual', 'order', 'pesanan', 'beli', 'transaksi', 
            'di', 'ke', 'dari', 'ini', 'itu', 'yang', 'saya', 'ingin', 'mau', 'tolong', 'info', 'informasi', 
            'detail', 'untuk', 'dong', 'kak', 'min', 'gan', 'bos', 'ya', 'sih', 'kah', 'permisi', 'halo', 
            'selamat', 'pagi', 'siang', 'sore', 'malam', 'list', 'status', 'cek', 'ketersediaan', 'bagaimanakah', 
            'bagaimana', 'mana', 'di mana', 'lokasi', 'alamat', 'kontak', 'wa', 'nomor', 'hp', 'telepon', 'hubungi',
            'bisa', 'tunjukkan', 'kasih', 'tahu', 'tau', 'lihat'
        ];
        
        $queryWords = array_filter($words, function($w) use ($stopWords) {
            return !in_array($w, $stopWords) && strlen($w) > 0;
        });
        
        return implode(' ', $queryWords);
    }

    /**
     * Local database-driven chatbot logic.
     */
    private function getDatabaseDrivenReply(string $message, $user = null): string
    {
        $normalized = strtolower(trim($message));

        // User Greeting
        $greeting = $user ? "Halo Kak **{$user->name}**! " : "Halo! ";

        $intent = 'general';
        $searchQuery = '';
        $orderNumber = '';

        if (preg_match('/(or-[a-z0-9\-]+)/i', $normalized, $matches)) {
            $intent = 'specific_order';
            $orderNumber = strtoupper($matches[1]);
        } elseif (
            str_contains($normalized, 'fitur') || 
            str_contains($normalized, 'bantuan') || 
            str_contains($normalized, 'cara') || 
            str_contains($normalized, 'aplikasi') || 
            str_contains($normalized, 'menu') ||
            str_contains($normalized, 'tutorial') ||
            str_contains($normalized, 'panduan')
        ) {
            $intent = 'general';
        } elseif (
            str_contains($normalized, 'produk') || 
            str_contains($normalized, 'stok') || 
            str_contains($normalized, 'harga') || 
            str_contains($normalized, 'jual') ||
            str_contains($normalized, 'beli') ||
            str_contains($normalized, 'beras') 

             )  {
            $intent = 'products';
            $searchQuery = $this->cleanQuery($normalized);
        } elseif (
            str_contains($normalized, 'petani') || 
            str_contains($normalized, 'toko') || 
            str_contains($normalized, 'mitra') || 
            str_contains($normalized, 'penjual') ||
            str_contains($normalized, 'alamat') ||
            str_contains($normalized, 'lokasi')
        ) {
            $intent = 'sellers';
            $searchQuery = $this->cleanQuery($normalized);
        } elseif (
            str_contains($normalized, 'order') || 
            str_contains($normalized, 'pesanan') || 
            str_contains($normalized, 'transaksi')
        ) {
            $intent = 'orders';
        }

        // 1. SPECIFIC ORDER LOOKUP
        if ($intent === 'specific_order') {
            $query = Order::where('order_number', 'like', "%{$orderNumber}%");
            if ($user && $user->role === 'Pembeli') {
                $query->where('buyer_id', $user->id);
            }
            
            $order = $query->first();

            if ($order) {
                $total = number_format($order->total_price, 0, ',', '.');
                $date = $order->created_at->format('d M Y H:i');
                $statusMap = [
                    'pending' => 'Menunggu Pembayaran ⏳',
                    'confirmed' => 'Dikonfirmasi (Sedang Diproses) 📦',
                    'shipped' => 'Dalam Pengiriman 🚚',
                    'delivered' => 'Telah Diterima (Selesai) ✓',
                    'cancelled' => 'Dibatalkan ✕'
                ];
                $statusStr = $statusMap[$order->status] ?? strtoupper($order->status);
                
                return $greeting . "Berikut detail pesanan Anda **{$order->order_number}**:\n\n" .
                    "• Tanggal: {$date}\n" .
                    "• Total Bayar: **Rp {$total}**\n" .
                    "• Alamat Kirim: {$order->shipping_address}\n" .
                    "• Catatan: " . ($order->notes ?? '-') . "\n" .
                    "• Status: **{$statusStr}**";
            } else {
                return $greeting . "Maaf, pesanan dengan nomor **{$orderNumber}** tidak ditemukan, atau Anda tidak berhak melacaknya.";
            }
        }

        // 2. PRODUCTS LOOKUP
        if ($intent === 'products') {
            $query = Product::where('is_active', 1)->with('seller');
            
            if (strlen($searchQuery) > 1) {
                $query->where('name', 'like', "%{$searchQuery}%");
            }
            
            $products = $query->take(5)->get();

            if ($products->isEmpty()) {
                return $searchQuery ? 
                    $greeting . "Maaf, produk dengan kata kunci \"**{$searchQuery}**\" tidak ditemukan di katalog kami saat ini." :
                    $greeting . "Saat ini belum ada produk segar terdaftar di katalog kami.";
            } elseif ($products->count() === 1) {
                $p = $products->first();
                $priceFormatted = number_format($p->price, 0, ',', '.');
                $shop = $p->seller->shop_name ?? $p->seller->name;
                return $greeting . "Berikut detail produk **{$p->name}**:\n\n" .
                    "• Deskripsi: " . ($p->description ?? '-') . "\n" .
                    "• Harga: **Rp {$priceFormatted} per {$p->unit}**\n" .
                    "• Stok: **{$p->stock} {$p->unit}**\n" .
                    "• Toko: **{$shop}** ({$p->seller->address})\n" .
                    "• Kontak Tani WA: {$p->seller->phone}\n\n" .
                    "Anda bisa langsung memesan produk ini di tab **Produk** pada aplikasi.";
            } else {
                $list = $searchQuery ? 
                    "Berikut produk yang cocok dengan pencarian \"**{$searchQuery}**\":\n\n" :
                    "Berikut daftar produk segar terbaru di platform kami:\n\n";
                
                foreach ($products as $idx => $p) {
                    $num = $idx + 1;
                    $priceFormatted = number_format($p->price, 0, ',', '.');
                    $shop = $p->seller->shop_name ?? $p->seller->name;
                    $list .= "{$num}. **{$p->name}**\n";
                    $list .= "   • Harga: Rp {$priceFormatted} per {$p->unit}\n";
                    $list .= "   • Stok: {$p->stock} {$p->unit}\n";
                    $list .= "   • Toko: {$shop}\n\n";
                }
                
                $list .= "Buka tab **Produk** untuk melihat lebih lengkap atau melakukan transaksi.";
                return $greeting . $list;
            }
        }

        // 3. SELLERS LOOKUP
        if ($intent === 'sellers') {
            $query = User::where('role', 'Petani')->whereNotNull('shop_name');
            
            if (strlen($searchQuery) > 1) {
                $query->where('shop_name', 'like', "%{$searchQuery}%");
            }
            
            $sellers = $query->take(5)->get();

            if ($sellers->isEmpty()) {
                return $searchQuery ? 
                    $greeting . "Maaf, toko tani dengan nama \"**{$searchQuery}**\" tidak ditemukan." :
                    $greeting . "Belum ada Toko Tani Mitra terdaftar.";
            } elseif ($sellers->count() === 1) {
                $s = $sellers->first();
                $desc = $s->shop_description ?? 'Penyedia komoditas segar pilihan.';
                return $greeting . "Berikut profil Toko Tani Mitra **{$s->shop_name}**:\n\n" .
                    "• Nama Pemilik: {$s->name}\n" .
                    "• Alamat: {$s->address}\n" .
                    "• Hubungi: **{$s->phone}**\n" .
                    "• Deskripsi: \"{$desc}\"";
            } else {
                $list = "Berikut daftar Toko Tani Mitra terbaik kami:\n\n";
                foreach ($sellers as $idx => $s) {
                    $num = $idx + 1;
                    $list .= "{$num}. **{$s->shop_name}** (Pemilik: {$s->name})\n";
                    $list .= "   • Alamat: {$s->address}\n";
                    $list .= "   • Hubungi: {$s->phone}\n\n";
                }
                return $greeting . $list;
            }
        }

        // 4. ORDERS LIST LOOKUP
        if ($intent === 'orders') {
            if (!$user) {
                return "Silakan melakukan login terlebih dahulu untuk mengakses riwayat transaksi Anda.";
            }

            if ($user->role === 'Pembeli') {
                $orders = Order::where('buyer_id', $user->id)
                    ->latest()
                    ->take(3)
                    ->get();

                if ($orders->isEmpty()) {
                    return $greeting . "Anda belum memiliki riwayat transaksi di AgriConnect.";
                }

                $list = "Berikut status 3 transaksi terbaru Anda:\n\n";
                foreach ($orders as $idx => $o) {
                    $num = $idx + 1;
                    $totalFormatted = number_format($o->total_price, 0, ',', '.');
                    $list .= "{$num}. **No. Order: {$o->order_number}**\n";
                    $list .= "   • Total: Rp {$totalFormatted}\n";
                    $list .= "   • Status: **" . strtoupper($o->status) . "**\n\n";
                }
                
                $list .= "Ketik \"*Cek pesanan [No. Order]*\" untuk melihat detail pengiriman spesifik.";
                return $greeting . $list;
            } elseif ($user->role === 'Petani') {
                return $greeting . "Sebagai Petani, Anda dapat mengelola pesanan masuk dan pengiriman dari tab **Stok** atau menu profil Anda.";
            } else {
                return $greeting . "Sebagai Admin, Anda dapat memantau seluruh order di sistem melalui menu **Monitor Order**.";
            }
        }

        // 5. GENERAL/FALLBACK
        if (
            str_contains($normalized, 'fitur') || 
            str_contains($normalized, 'bantuan') || 
            str_contains($normalized, 'cara') || 
            str_contains($normalized, 'aplikasi') || 
            str_contains($normalized, 'menu') ||
            str_contains($normalized, 'tutorial') ||
            str_contains($normalized, 'panduan')
        ) {
            return $greeting . "Saya adalah **Agri Asisten Bot**, asisten virtual Anda di AgriConnect. Berikut panduan cepat menu utama aplikasi kami:\n\n" .
                "• **Bagi Petani**: Anda dapat mencatat panen di menu **Panen**, mengatur penanaman di menu **Jadwal**, mengelola pengeluaran di **Biaya Produksi**, serta menerbitkan stok barang jualan di menu **Stok**.\n" .
                "• **Bagi Pembeli**: Anda dapat mencari produk segar di menu **Produk**, memasukkannya ke keranjang, melakukan checkout/pemesanan, melacak pengiriman di menu **Pesanan**, dan melakukan review produk.\n\n" .
                "Ada hal spesifik terkait fitur yang ingin Anda tanyakan?";
        }

        if (
            str_contains($normalized, 'panen') || 
            str_contains($normalized, 'tanam') || 
            str_contains($normalized, 'pupuk') || 
            str_contains($normalized, 'bibit') || 
            str_contains($normalized, 'padi') || 
            str_contains($normalized, 'hama')
        ) {
            return $greeting . "Berikut adalah beberapa tips pertanian praktis untuk mengoptimalkan hasil panen Anda:\n\n" .
                "1. **Bibit Unggul**: Gunakan varietas bibit bersertifikat yang tahan terhadap hama setempat.\n" .
                "2. **Pemupukan Berimbang**: Berikan pupuk organik dan anorganik (seperti NPK) sesuai fase pertumbuhan tanaman.\n" .
                "3. **Pengairan**: Gunakan sistem pengairan berkala (intermittent) untuk tanaman padi guna menghemat air dan menekan pertumbuhan gas metana.\n" .
                "4. **Pengendalian Hama**: Lakukan pemantauan rutin dan gunakan pestisida nabati atau musuh alami sebelum beralih ke bahan kimia.\n" .
                "5. **Masa Panen**: Lakukan pemanenan saat 90-95% butir gabah telah menguning untuk kualitas gabah terbaik.";
        }

        if (
            str_contains($normalized, 'halo') || 
            str_contains($normalized, 'hai') || 
            str_contains($normalized, 'pagi') || 
            str_contains($normalized, 'siang') || 
            str_contains($normalized, 'sore') || 
            str_contains($normalized, 'malam') || 
            str_contains($normalized, 'selamat')
        ) {
            return $greeting . "Saya adalah **Agri Asisten Bot** 🌾. Ada yang bisa saya bantu hari ini?\n\n" .
                "Anda bisa bertanya kepada saya tentang:\n" .
                "• \"*Apakah ada stok beras merah?*\" untuk mengecek ketersediaan produk.\n" .
                "• \"*Di mana alamat Toko Tani Makmur?*\" untuk mencari tahu profil penjual.\n" .
                "• \"*Cek status pesanan*\" atau nomor pesanan spesifik (seperti *OR-202606110001*) untuk melacak transaksi Anda.";
        }

        return $greeting . "Saya adalah **Agri Asisten Bot** yang didukung oleh n8n.\n\n" .
            "Maaf, saya tidak memahami pertanyaan Anda: \"*{$message}*\".\n\n" .
            "Cobalah untuk menanyakan hal spesifik seperti:\n" .
            "• *Harga produk*: \"Berapa harga cabai merah?\" atau \"Apakah ada stok madu?\"\n" .
            "• *Profil toko tani*: \"Toko Tani Makmur di mana?\"\n" .
            "• *Status pesanan*: \"Cek status pesanan OR-xxxx\" (pastikan Anda sudah login)\n" .
            "• *Bantuan*: \"Panduan menu aplikasi\" atau \"Tips pemupukan padi\"";
    }
}
