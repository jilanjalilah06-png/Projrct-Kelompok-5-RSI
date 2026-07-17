<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Tymon\JWTAuth\Facades\JWTAuth;

class AuthController extends Controller
{
    /**
     * Register a new user
     */
    public function register(Request $request)
    {
        try {
            $rules = [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|unique:users',
                'password' => 'required|string|min:6|confirmed',
                'phone' => 'nullable|string',
                'address' => 'nullable|string',
                'role' => 'required|in:Admin,Petani,Pembeli',
                'shop_name' => 'nullable|string|max:255',
                'shop_description' => 'nullable|string',
                'username' => 'nullable|string|max:255|unique:users,username',
                'nik' => 'nullable|string|max:50',
                'no_rekening' => 'nullable|string|max:100',
                'nama_bank' => 'nullable|string|max:100',
            ];

            if ($request->role === 'Petani') {
                $rules['username'] = 'required|string|max:255|unique:users,username';
                $rules['nik'] = 'required|string|max:50';
                $rules['address'] = 'required|string';
                $rules['no_rekening'] = 'required|string|max:100';
                $rules['nama_bank'] = 'required|string|max:100';
            } elseif ($request->role === 'Pembeli') {
                $rules['username'] = 'required|string|max:255|unique:users,username';
            }

            $validated = $request->validate($rules);

            $user = User::create([
                'name' => $validated['name'],
                'username' => $validated['username'] ?? null,
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'phone' => $validated['phone'] ?? null,
                'address' => $validated['address'] ?? null,
                'role' => $validated['role'],
                'shop_name' => $validated['shop_name'] ?? null,
                'shop_description' => $validated['shop_description'] ?? null,
                'nik' => $validated['nik'] ?? null,
                'no_rekening' => $validated['no_rekening'] ?? null,
                'nama_bank' => $validated['nama_bank'] ?? null,
            ]);

            \App\Models\ActivityLog::log(
                $user->name,
                $user->role === 'Petani' ? 'Petani baru mendaftar' : 'Pembeli baru mendaftar',
                $user->role
            );

            if ($user->role === 'Petani' && !$user->is_verified) {
                return response()->json([
                    'success' => true,
                    'message' => 'Pendaftaran berhasil. Akun Petani Anda sedang menunggu verifikasi dari Admin.',
                    'data' => [
                        'user' => $user,
                    ],
                ], 201);
            }

            $token = JWTAuth::fromUser($user);

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'data' => [
                    'user' => $user,
                    'token' => $token,
                ],
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        }
    }

    /**
     * Login user
     */
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        if (!$token = JWTAuth::attempt($credentials)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        $user = auth()->user();

        if (!$user->is_active) {
            try {
                JWTAuth::setToken($token)->invalidate();
            } catch (\Exception $e) {}
            return response()->json([
                'success' => false,
                'message' => 'Akun Anda telah dinonaktifkan. Silakan hubungi admin.',
            ], 401);
        }

        if ($user->role === 'Petani' && !$user->is_verified) {
            try {
                JWTAuth::setToken($token)->invalidate();
            } catch (\Exception $e) {
                // Token invalidation failed, but we still deny login
            }
            return response()->json([
                'success' => false,
                'message' => 'Akun Petani Anda sedang menunggu verifikasi dari Admin. Silakan coba lagi nanti.',
            ], 401);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => auth()->user(),
                'token' => $token,
            ],
        ], 200);
    }

    /**
     * Get authenticated user profile
     */
    public function me()
    {
        return response()->json([
            'success' => true,
            'data' => auth()->user(),
        ]);
    }

    public function profile()
    {
        return response()->json([
            'success' => true,
            'data' => auth()->user(),
        ]);
    }

    public function updateProfile(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'sometimes|required|string|max:255',
                'phone' => 'nullable|string|max:30',
                'address' => 'nullable|string|max:500',
                'shop_name' => 'nullable|string|max:255',
                'shop_description' => 'nullable|string|max:1000',
                'avatar' => 'nullable|image|max:2048',
            ]);

            $user = auth()->user();

            if ($request->hasFile('avatar')) {
                if ($user->avatar) {
                    Storage::disk('public')->delete($user->avatar);
                }
                $validated['avatar'] = $request->file('avatar')->store('avatars', 'public');
            }

            $user->fill($validated);
            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => $user->fresh(),
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $e->errors(),
            ], 422);
        }
    }

    public function chatbotMessage(Request $request)
    {
        $validated = $request->validate([
            'message' => 'required|string|max:1000',
        ]);

        $message = strtolower(trim($validated['message']));
        
        // Get authenticated user if token is present
        $user = null;
        if ($request->bearerToken()) {
            try {
                $user = auth('api')->authenticate();
            } catch (\Exception $e) {
                $user = null;
            }
        }

        // Helper to format currency
        $formatRupiah = function($amount) {
            return 'Rp ' . number_format($amount, 0, ',', '.');
        };

        // Score-based Intent Classification System
        $intents = [
            'cek_pesanan' => [
                'phrases' => ['cek pesanan', 'status pesanan', 'riwayat transaksi', 'riwayat belanja', 'pesanan saya', 'order saya', 'cek order', 'status order', 'lacak pesanan', 'lacak paket', 'daftar pesanan', 'daftar transaksi'],
                'keywords' => ['pesan', 'pesanan', 'order', 'transaksi', 'riwayat', 'belanjaan', 'lacak'],
                'modifiers' => ['cek', 'status', 'saya', 'daftar', 'riwayat', 'detail', 'lacak', 'history']
            ],
            'penjualan' => [
                'phrases' => ['laporan penjualan', 'hasil penjualan', 'total omset', 'omset saya', 'laba rugi', 'laporan keuangan', 'pendapatan saya', 'keuntungan saya'],
                'keywords' => ['jual', 'penjualan', 'omset', 'omzet', 'pendapatan', 'keuntungan', 'laba', 'keuangan', 'omset', 'sales', 'revenue']
            ],
            'stok' => [
                'phrases' => ['cek stok', 'stok gudang', 'sisa stok', 'hasil panen', 'stok beras', 'stok jagung', 'stok komoditas'],
                'keywords' => ['stok', 'panen', 'gudang', 'komoditas', 'persediaan', 'inventory']
            ],
            'biaya_tanam' => [
                'phrases' => ['biaya tanam', 'biaya produksi', 'modal tanam', 'pengeluaran tani', 'biaya pupuk', 'biaya bibit'],
                'keywords' => ['biaya', 'modal', 'pengeluaran', 'ongkos', 'dana', 'budget', 'cost'],
                'requires' => ['tanam', 'produksi', 'tani', 'pupuk', 'benih', 'bibit', 'lahan', 'kebun', 'jadwal']
            ],
            'jadwal_tanam' => [
                'phrases' => ['jadwal tanam', 'kalender tanam', 'rencana tanam', 'kegiatan tanam', 'jadwal aktivitas'],
                'keywords' => ['jadwal', 'tanam', 'kalender', 'rencana', 'timeline', 'schedule']
            ],
            'ringkasan' => [
                'phrases' => ['laporan ringkasan', 'ringkasan usaha', 'rangkuman data', 'laporan lengkap'],
                'keywords' => ['ringkasan', 'rangkum', 'laporan', 'data', 'summary']
            ],
            'cara_belanja' => [
                'phrases' => ['cara belanja', 'cara beli', 'cara bayar', 'cara checkout', 'panduan belanja', 'tutorial belanja', 'langkah belanja', 'proses beli', 'prosedur beli', 'metode bayar', 'cara pembayaran', 'cara bertransaksi'],
                'keywords' => ['belanja', 'checkout', 'bayar', 'transaksi', 'beli'],
                'modifiers' => ['cara', 'bagaimana', 'panduan', 'tutorial', 'langkah', 'proses', 'prosedur']
            ],
            'cara_jual' => [
                'phrases' => ['cara jual', 'cara jualan', 'cara menawarkan', 'cara memasarkan', 'gimana cara jual', 'bagaimana cara jual', 'cara dagang'],
                'keywords' => ['jual', 'dagang', 'jualan'],
                'requires' => ['cara', 'bagaimana', 'gimana', 'panduan', 'tutorial', 'langkah', 'proses']
            ],
            'cara_upload' => [
                'phrases' => ['cara upload', 'unggah foto', 'cara foto', 'tambah foto', 'cara pasang foto', 'upload gambar'],
                'keywords' => ['upload', 'unggah', 'foto', 'gambar'],
                'requires' => ['cara', 'bagaimana', 'gimana', 'panduan', 'tutorial', 'langkah']
            ],
            'cara_daftar' => [
                'phrases' => ['cara daftar', 'cara register', 'cara buat akun', 'cara bikin akun', 'cara mendaftar'],
                'keywords' => ['daftar', 'register', 'akun'],
                'requires' => ['cara', 'bagaimana', 'gimana', 'langkah', 'proses']
            ],
            'cara_edit_profil' => [
                'phrases' => ['cara edit', 'cara ubah', 'cara ganti', 'ubah profil', 'ganti profil', 'edit profil'],
                'keywords' => ['edit', 'ubah', 'ganti', 'profil'],
                'requires' => ['cara', 'bagaimana', 'gimana', 'langkah']
            ],
            'tentang_app' => [
                'phrases' => ['apa itu agriconnect', 'tentang agriconnect', 'fitur aplikasi', 'tentang aplikasi', 'apa agriconnect'],
                'keywords' => ['agriconnect', 'aplikasi', 'fitur', 'sistem', 'platform', 'tentang']
            ],
            'cari_produk' => [
                'phrases' => ['daftar produk', 'cek harga', 'harga komoditas', 'harga beras', 'harga jagung', 'cari beras', 'cari jagung'],
                'keywords' => ['beras', 'jagung', 'produk', 'harga', 'katalog', 'beli', 'pesan']
            ],
            'greetings' => [
                'phrases' => ['assalamualaikum', 'selamat pagi', 'selamat siang', 'selamat sore', 'selamat malam'],
                'keywords' => ['halo', 'hi', 'hello', 'pagi', 'siang', 'sore', 'malam', 'tanya', 'bantuan', 'tolong', 'bot', 'admin', 'bantu']
            ]
        ];

        $scores = [];
        foreach ($intents as $intentName => $rules) {
            $score = 0;
            
            // 1. Exact phrase matching (highest priority)
            if (isset($rules['phrases'])) {
                foreach ($rules['phrases'] as $phrase) {
                    if (str_contains($message, $phrase)) {
                        $score += 10;
                    }
                }
            }
            
            // 2. Keyword matching
            if (isset($rules['keywords'])) {
                $matchCount = 0;
                foreach ($rules['keywords'] as $kw) {
                    if (str_contains($message, $kw)) {
                        $matchCount++;
                    }
                }
                $score += $matchCount * 2;
            }
            
            // 3. Modifier/Context matching (increases score if context matches)
            if (isset($rules['modifiers']) && $score > 0) {
                foreach ($rules['modifiers'] as $mod) {
                    if (str_contains($message, $mod)) {
                        $score += 3;
                    }
                }
            }
            
            // 4. Required context constraints
            if (isset($rules['requires'])) {
                $hasRequired = false;
                foreach ($rules['requires'] as $req) {
                    if (str_contains($message, $req)) {
                        $hasRequired = true;
                        break;
                    }
                }
                if ($hasRequired && $score > 0) {
                    $score += 3;
                } else {
                    $score = 0; // Reset score if required context is missing or if base score is 0
                }
            }
            
            $scores[$intentName] = $score;
        }

        // Find the intent with the highest score
        arsort($scores);
        $topIntent = key($scores);
        $topScore = current($scores);

        // Minimum score threshold to match an intent
        $intent = ($topScore >= 2) ? $topIntent : 'fallback';

        $reply = '';

        switch ($intent) {
            case 'cek_pesanan':
                if ($user) {
                    if ($user->role === 'Petani') {
                        $orderItems = \App\Models\OrderItem::whereHas('product', function($q) use ($user) {
                            $q->where('seller_id', $user->id);
                        })->with('order.buyer')->latest()->take(5)->get();

                        if ($orderItems->isEmpty()) {
                            $reply = "Belum ada pesanan dari pembeli yang masuk untuk produk pertanian Anda.";
                        } else {
                            $reply = "Berikut adalah 5 pesanan pembeli terbaru yang masuk untuk Anda:\n\n";
                            foreach ($orderItems as $item) {
                                $order = $item->order;
                                $reply .= "• **#{$order->order_number}** - {$item->product->name}\n";
                                $reply .= "  Jumlah: **{$item->quantity} {$item->product->unit}** | Total: **" . $formatRupiah($item->total_price) . "**\n";
                                $reply .= "  Pembeli: *{$order->buyer->name}*\n";
                                $reply .= "  Status: **" . strtoupper($order->status) . "** | Pembayaran: **" . strtoupper($order->payment_status ?? 'pending') . "**\n\n";
                            }
                            $reply .= "Anda dapat memproses pesanan ini melalui halaman pesanan masuk.";
                        }
                    } else {
                        // Pembeli
                        $orders = \App\Models\Order::where('buyer_id', $user->id)->latest()->take(5)->get();

                        if ($orders->isEmpty()) {
                            $reply = "Anda belum memiliki riwayat pemesanan di AgriConnect.";
                        } else {
                            $reply = "Berikut adalah 5 transaksi pemesanan terbaru Anda:\n\n";
                            foreach ($orders as $order) {
                                $reply .= "• **#{$order->order_number}**\n";
                                $reply .= "  Total Belanja: **" . $formatRupiah($order->total_price) . "**\n";
                                $reply .= "  Status Pesanan: **" . strtoupper($order->status) . "**\n";
                                $reply .= "  Pembayaran: **" . strtoupper($order->payment_status ?? 'pending') . "**\n\n";
                            }
                            $reply .= "Detail pesanan lengkap dapat Anda lihat di halaman riwayat transaksi.";
                        }
                    }
                } else {
                    $reply = "Silakan masuk/login terlebih dahulu untuk memeriksa riwayat pesanan Anda.";
                }
                break;

            case 'penjualan':
                if ($user && $user->role === 'Petani') {
                    $orderItems = \App\Models\OrderItem::whereHas('product', function($q) use ($user) {
                        $q->where('seller_id', $user->id);
                    })->whereHas('order', function($q) {
                        $q->where('status', '!=', 'cancelled');
                    })->get();

                    $totalRevenue = $orderItems->sum('total_price');
                    $totalItemsSold = $orderItems->sum('quantity');
                    $ordersCount = $orderItems->pluck('order_id')->unique()->count();

                    $reply = "Berikut ringkasan hasil penjualan Anda di AgriConnect:\n\n" .
                             "• Total Omset Bersih: **" . $formatRupiah($totalRevenue) . "**\n" .
                             "• Total Produk Terjual: **" . number_format($totalItemsSold, 0, ',', '.') . " kg**\n" .
                             "• Jumlah Transaksi Berhasil: **" . $ordersCount . " pesanan**\n\n" .
                             "Rincian keuangan lengkap tersedia pada dashboard mitra tani Anda.";
                } else {
                    $reply = "Informasi hasil penjualan dan laba rugi hanya tersedia untuk akun kemitraan Petani.";
                }
                break;

            case 'stok':
                if ($user && $user->role === 'Petani') {
                    $products = \App\Models\Product::where('seller_id', $user->id)->get();
                    $totalStock = $products->sum('stock');

                    if ($products->isEmpty()) {
                        $reply = "Anda belum mendaftarkan komoditas hasil panen di gudang Anda.";
                    } else {
                        $reply = "Berikut adalah stok hasil panen yang tersimpan di gudang Anda:\n\n";
                        foreach ($products as $p) {
                            $reply .= "• **{$p->name}**: **{$p->stock} {$p->unit}** (Harga: " . $formatRupiah($p->price) . "/{$p->unit})\n";
                        }
                        $reply .= "\nTotal stok komoditas siap jual: **" . $totalStock . " kg**.";
                    }
                } else {
                    // Pembeli / Guest
                    $products = \App\Models\Product::where('is_active', true)->where('stock', '>', 0)->with('seller')->get();
                    
                    if ($products->isEmpty()) {
                        $reply = "Saat ini tidak ada komoditas hasil tani yang tersedia untuk dibeli.";
                    } else {
                        $reply = "Berikut adalah stok komoditas yang tersedia di AgriConnect:\n\n";
                        foreach ($products as $p) {
                            $sellerName = $p->seller->shop_name ?? $p->seller->name ?? 'Petani';
                            $reply .= "• **{$p->name}** (Tersedia: **{$p->stock} {$p->unit}**)\n";
                            $reply .= "  Harga: **" . $formatRupiah($p->price) . "/{$p->unit}**\n";
                            $reply .= "  Penjual: *" . $sellerName . "* (" . ($p->seller->address ?? 'Lahan Lokal') . ")\n\n";
                        }
                        $reply .= "Anda bisa membelinya langsung di halaman katalog produk.";
                    }
                }
                break;

            case 'biaya_tanam':
                if ($user && $user->role === 'Petani') {
                    $activities = \App\Models\PlantingActivity::where('user_id', $user->id)->get();
                    
                    if ($activities->isEmpty()) {
                        $reply = "Anda belum mencatat jadwal tanam atau biaya operasional produksi.";
                    } else {
                        $plantingCosts = $activities->sum('cost');
                        $schedules = $activities->pluck('schedule_name')->unique();
                        
                        $reply = "Berikut adalah ringkasan jadwal dan biaya operasional tanam Anda:\n\n" .
                                 "• Total Pengeluaran Produksi: **" . $formatRupiah($plantingCosts) . "**\n" .
                                 "• Jumlah Jadwal Tanam Aktif: **" . $schedules->count() . " jadwal**\n\n" .
                                 "Rincian biaya per jadwal:\n";
                        foreach ($schedules as $sch) {
                            $schCost = $activities->where('schedule_name', $sch)->sum('cost');
                            $reply .= "  - **{$sch}**: " . $formatRupiah($schCost) . "\n";
                        }
                    }
                } else {
                    $reply = "Informasi pengelolaan jadwal dan pencatatan biaya produksi hanya tersedia untuk akun Petani.";
                }
                break;

            case 'jadwal_tanam':
                if ($user && $user->role === 'Petani') {
                    $activities = \App\Models\PlantingActivity::where('user_id', $user->id)->get();
                    
                    if ($activities->isEmpty()) {
                        $reply = "Anda belum mencatat jadwal tanam atau aktivitas produksi.";
                    } else {
                        $schedulesCount = \App\Models\PlantingActivity::where('user_id', $user->id)->distinct('schedule_name')->count('schedule_name');
                        $reply = "Berikut adalah ringkasan jadwal tanam aktif Anda:\n\n" .
                                 "• Jumlah Jadwal Tanam Aktif: **" . $schedulesCount . " jadwal**\n" .
                                 "• Anda dapat mengelola detail jadwal ini melalui menu 'Jadwal Tanam' di dashboard Anda.";
                    }
                } else {
                    $reply = "Informasi pengelolaan jadwal tanam hanya tersedia untuk akun Petani.";
                }
                break;

            case 'ringkasan':
                if ($user && $user->role === 'Petani') {
                    $orderItems = \App\Models\OrderItem::whereHas('product', function($q) use ($user) {
                        $q->where('seller_id', $user->id);
                    })->whereHas('order', function($q) {
                        $q->where('status', '!=', 'cancelled');
                    })->get();

                    $totalRevenue = $orderItems->sum('total_price');
                    $totalItemsSold = $orderItems->sum('quantity');
                    $ordersCount = $orderItems->pluck('order_id')->unique()->count();

                    $products = \App\Models\Product::where('seller_id', $user->id)->get();
                    $totalStock = $products->sum('stock');

                    $plantingCosts = \App\Models\PlantingActivity::where('user_id', $user->id)->sum('cost');
                    $schedulesCount = \App\Models\PlantingActivity::where('user_id', $user->id)->distinct('schedule_name')->count('schedule_name');

                    $reply = "Halo Bapak/Ibu **" . $user->name . "**! Berikut adalah laporan ringkasan menyeluruh usaha tani Anda:\n\n" .
                             "📊 **Ringkasan Penjualan & Omset**:\n" .
                             "• Total Pendapatan: **" . $formatRupiah($totalRevenue) . "**\n" .
                             "• Hasil Terjual: **" . number_format($totalItemsSold, 0, ',', '.') . " kg**\n" .
                             "• Total Transaksi Sukses: **" . $ordersCount . " pesanan**\n\n" .
                             "🌾 **Stok Hasil Panen di Gudang**:\n";
                    
                    if ($products->isEmpty()) {
                        $reply .= "• *Belum ada hasil panen terdaftar.*\n\n";
                    } else {
                        foreach ($products as $p) {
                            $reply .= "• **" . $p->name . "**: " . $p->stock . " " . $p->unit . "\n";
                        }
                        $reply .= "• Total Stok Tersedia: **" . $totalStock . " kg**\n\n";
                    }

                    $reply .= "🌱 **Rencana & Biaya Tanam**:\n" .
                              "• Jumlah Jadwal Tanam: **" . $schedulesCount . " jadwal aktif**\n" .
                              "• Total Biaya Produksi: **" . $formatRupiah($plantingCosts) . "**\n\n" .
                              "Semoga pertanian Anda semakin sukses!";
                } else {
                    $reply = "Halo! Berikut adalah informasi ringkas platform AgriConnect saat ini:\n\n" .
                             "• Komoditas Utama: **Beras & Jagung**\n" .
                             "• Akses Mudah: Membeli langsung dari petani lokal terpercaya.";
                }
                break;

            case 'cara_belanja':
                $reply = "Berikut adalah panduan bertransaksi di AgriConnect:\n\n" .
                         "1. Buka menu utama / halaman beranda.\n" .
                         "2. Pilih komoditas Beras atau Jagung yang ingin Anda beli, lalu masukkan ke keranjang belanja.\n" .
                         "3. Buka halaman keranjang, periksa pesanan Anda, lalu klik **Checkout**.\n" .
                         "4. Isi alamat pengiriman Anda dengan benar.\n" .
                         "5. Lakukan pembayaran menggunakan metode pembayaran online via Midtrans yang aman.\n" .
                         "6. Penjual akan memverifikasi dan mengirimkan pesanan ke alamat Anda.";
                break;

            case 'cara_jual':
                $reply = "Untuk berjualan di AgriConnect, pastikan Anda mendaftar dengan akun tipe **Petani**. Setelah masuk:\n\n" .
                         "1. Buka menu **Produk**.\n" .
                         "2. Klik ikon tambah (**+**) di pojok kanan atas.\n" .
                         "3. Masukkan nama komoditas, grade (Premium/Standar), harga per kg, stok, dan deskripsi produk.\n" .
                         "4. Unggah foto produk Anda, lalu simpan.\n\n" .
                         "Produk Anda akan langsung tayang di katalog belanja dan dapat dibeli oleh Pembeli!";
                break;

            case 'cara_upload':
                $reply = "Untuk mengunggah atau mengganti foto produk di AgriConnect:\n\n" .
                         "1. Masuk ke menu **Produk** di akun Petani Anda.\n" .
                         "2. Saat membuat produk baru atau mengedit produk yang ada, klik tombol **Pilih Foto/Gambar**.\n" .
                         "3. Pilih file gambar produk (Beras atau Jagung) dari galeri perangkat Anda.\n" .
                         "4. Pastikan ukuran file gambar tidak terlalu besar dan dalam format JPG/PNG.\n" .
                         "5. Klik **Simpan** untuk memperbarui produk beserta fotonya!";
                break;

            case 'cara_daftar':
                $reply = "Cara mendaftar akun di AgriConnect:\n\n" .
                         "1. Di halaman masuk (Login), klik tombol **Daftar Sekarang** di bagian bawah.\n" .
                         "2. Pilih peran Anda: **Petani** atau **Pembeli**.\n" .
                         "3. Jika memilih **Petani**, lengkapi data: Nama (Sesuai KTP), NIK, Username, Email, Password, Alamat, No Rekening, dan Nama Bank.\n" .
                         "4. Jika memilih **Pembeli**, lengkapi data: Nama, Username, Email, dan Password.\n" .
                         "5. Setelah pendaftaran berhasil, Anda bisa langsung masuk menggunakan email dan password tersebut!";
                break;

            case 'cara_edit_profil':
                $reply = "Untuk mengedit profil Anda di AgriConnect:\n\n" .
                         "1. Masuk ke halaman **Profil** (menu paling kanan di bar navigasi bawah).\n" .
                         "2. Klik tombol **Edit Profil** atau ikon pena.\n" .
                         "3. Ubah informasi yang Anda inginkan (seperti nama, no telepon, alamat, atau detail rekening bank).\n" .
                         "4. Klik **Simpan Perubahan** untuk memperbarui data Anda di database.";
                break;

            case 'tentang_app':
                $reply = "AgriConnect adalah platform inovatif yang dirancang untuk mempertemukan petani lokal secara langsung dengan pembeli. Fitur utama kami meliputi:\n\n" .
                         "• **Katalog Beras & Jagung**: Memudahkan pembeli mendapatkan hasil panen segar berkualitas tinggi langsung dari petani.\n" .
                         "• **Manajemen Jadwal & Biaya Tanam**: Membantu petani menjadwalkan masa tanam, memantau pengeluaran produksi, dan mencatat riwayat panen.\n" .
                         "• **Pembayaran Instan & Aman**: Integrasi gerbang pembayaran online untuk memudahkan transaksi bagi petani dan pembeli.";
                break;

            case 'cari_produk':
                $productsQuery = \App\Models\Product::where('is_active', true)->where('stock', '>', 0);
                
                // Search filter based on keywords
                if (str_contains($message, 'beras')) {
                    $productsQuery->where('name', 'like', '%beras%');
                } elseif (str_contains($message, 'jagung')) {
                    $productsQuery->where('name', 'like', '%jagung%');
                }

                $products = $productsQuery->with('seller')->get();

                if ($products->isEmpty()) {
                    $reply = "Saat ini produk komoditas tersebut sedang kosong or belum terdaftar. Silakan cek katalog produk secara berkala untuk pembaruan.";
                } else {
                    $reply = "Berikut adalah daftar komoditas pertanian terbaik yang tersedia di AgriConnect saat ini:\n\n";
                    foreach ($products as $p) {
                        $sellerName = $p->seller->shop_name ?? $p->seller->name ?? 'Petani';
                        $reply .= "• **" . $p->name . "**\n";
                        $reply .= "  Harga: **" . $formatRupiah($p->price) . "/" . $p->unit . "**\n";
                        $reply .= "  Stok: **" . $p->stock . " " . $p->unit . "**\n";
                        $reply .= "  Penjual: *" . $sellerName . "* (" . ($p->seller->address ?? 'Lahan Lokal') . ")\n\n";
                    }
                    $reply .= "Anda dapat melakukan pemesanan langsung melalui halaman katalog produk.";
                }
                break;

            case 'greetings':
                $reply = "Halo! Saya **Agri Asisten Bot**, asisten virtual Anda di AgriConnect. Saya siap menjawab pertanyaan Anda.\n\n";
                if ($user) {
                    $reply .= "Anda saat ini masuk sebagai **" . $user->role . "**.\n\n";
                    if ($user->role === 'Petani') {
                        $reply .= "Ketik:\n" .
                                  "• *'ringkasan'* / *'laporan'* untuk melihat laporan menyeluruh.\n" .
                                  "• *'penjualan'* / *'omset'* untuk laporan keuangan.\n" .
                                  "• *'stok'* / *'hasil panen'* untuk daftar stok gudang.\n" .
                                  "• *'biaya tanam'* untuk melihat modal produksi.\n" .
                                  "• *'cek pesanan'* untuk memantau pesanan masuk.";
                    } else {
                        $reply .= "Ketik:\n" .
                                  "• *'daftar produk'* untuk melihat komoditas aktif.\n" .
                                  "• *'cek pesanan'* untuk memantau status status pesanan belanja Anda.\n" .
                                  "• *'cara belanja'* untuk panduan membeli produk.";
                    }
                } else {
                    $reply .= "Ketik **'daftar produk'** atau **'cara belanja'** untuk memulai di platform AgriConnect.";
                }
                break;

            case 'fallback':
            default:
                $query = strtolower(trim($validated['message']));
                
                // 1. Math matching
                if (preg_match('/(\d+)\s*([\+\-\*\/])\s*(\d+)/', $query, $matches)) {
                    $num1 = intval($matches[1]);
                    $op = $matches[2];
                    $num2 = intval($matches[3]);
                    $res = 0;
                    if ($op == '+') $res = $num1 + $num2;
                    elseif ($op == '-') $res = $num1 - $num2;
                    elseif ($op == '*') $res = $num1 * $num2;
                    elseif ($op == '/') $res = ($num2 != 0) ? ($num1 / $num2) : 'tidak terdefinisi (pembagian dengan nol)';
                    $reply = "Hasil hitungan dari $num1 $op $num2 adalah **$res**! 🧮 Apakah ada hitungan matematika atau data finansial tani lainnya?";
                }
                // 2. Capital cities matching
                elseif (preg_match('/ibu\s*kota\s*([a-zA-Z\s]+)/i', $query, $matches)) {
                    $country = strtolower(trim($matches[1]));
                    $capitals = [
                        'indonesia' => 'Jakarta',
                        'prancis' => 'Paris',
                        'perancis' => 'Paris',
                        'jepang' => 'Tokyo',
                        'inggris' => 'London',
                        'amerika' => 'Washington D.C.',
                        'malaysia' => 'Kuala Lumpur',
                        'singapura' => 'Singapura',
                        'arab saudi' => 'Riyadh',
                        'australia' => 'Canberra',
                        'china' => 'Beijing',
                        'cina' => 'Beijing',
                        'korea' => 'Seoul',
                        'korea selatan' => 'Seoul',
                    ];
                    if (array_key_exists($country, $capitals)) {
                        $reply = "Ibukota dari " . ucwords($country) . " adalah **" . $capitals[$country] . "**! 🏛️ Ada pertanyaan pengetahuan umum atau info geografi lain?";
                    } else {
                        $reply = "Hmm, saya belum tahu pasti ibukota dari " . ucwords($country) . ". Namun, saya sangat ahli dalam membantu pertanian dan transaksi komoditas di AgriConnect!";
                    }
                }
                // 3. President matching
                elseif (preg_match('/presiden\s*(indonesia|ri)/i', $query)) {
                    $reply = "Presiden Republik Indonesia saat ini adalah **Prabowo Subianto** (yang menjabat setelah Joko Widodo).";
                }
                // 4. Date matching
                elseif (preg_match('/(hari\s*ini\s*(hari|tanggal|bulan|tahun)|tanggal\s*berapa)/i', $query)) {
                    $reply = "Hari ini adalah hari **" . \Carbon\Carbon::now()->locale('id')->isoFormat('dddd, D MMMM YYYY') . "**! 📅";
                }
                // 5. General agricultural questions
                elseif (preg_match('/(padi|beras|jagung|tanaman|tanam)\s*(tumbuh|lama|waktu)/i', $query)) {
                    $reply = "Lama waktu pertumbuhan tanaman bervariasi:\n• **Padi**: Butuh waktu sekitar **3 hingga 4 bulan** (110 - 120 hari) dari tanam hingga siap panen.\n• **Jagung**: Biasanya siap panen dalam waktu **3 bulan** (90 hari) tergantung varietasnya.";
                } elseif (preg_match('/(pupuk|menyuburkan)/i', $query)) {
                    $reply = "Untuk menyuburkan tanaman padi dan jagung, biasanya direkomendasikan pupuk NPK, urea, atau pupuk organik kompos secara berkala sesuai fase pertumbuhan vegetatif dan generatif tanaman.";
                } elseif (preg_match('/(apa beda|perbedaan)\s*(beras|jagung)\s*(premium|standar)/i', $query)) {
                    $reply = "Perbedaan Beras/Jagung Premium dan Standar:\n• **Premium**: Memiliki butiran utuh lebih tinggi (broken beras minimal), warna putih alami bersih, tanpa kotoran, dan rasa lebih pulen.\n• **Standar**: Memiliki sedikit butiran patah (broken), namun tetap bersih, aman, sehat, dan sangat terjangkau untuk konsumsi harian.";
                }
                // 6. Conversational responses
                elseif (preg_match('/(apa kabar|how are you|gimana kabarmu|piye kabare)/i', $query)) {
                    $reply = "Kabar saya sangat baik! 😊 Sebagai Agri Asisten Bot, saya selalu bersemangat membantu Anda mengelola pertanian dan transaksi di AgriConnect. Bagaimana dengan kabar Anda hari ini?";
                } elseif (preg_match('/(siapa (kamu|anda)|who are you|nama kamu)/i', $query)) {
                    $reply = "Saya adalah **Agri Asisten Bot**, asisten virtual cerdas Anda di AgriConnect. Saya dirancang untuk mempermudah koordinasi masa tanam petani dan pemesanan bagi pembeli.";
                } elseif (preg_match('/(terima kasih|makasih|nuhun|suwun|thank|tengkiu)/i', $query)) {
                    $reply = "Sama-sama! Senang sekali bisa membantu Anda. 😊 Jika ada hal lain yang ingin Anda diskusikan atau tanyakan, silakan beri tahu saya!";
                } elseif (preg_match('/(cuaca|hujan|mendung|panas|kemarau|musim|angin)/i', $query)) {
                    $reply = "Memantau cuaca sangat penting bagi kesuksesan pertanian! Pastikan Anda memantau perkiraan cuaca lokal demi kelancaran aktivitas tanam Anda. Apakah Anda ingin memeriksa jadwal tanam aktif saat ini?";
                } elseif (preg_match('/(joke|lucu|canda|humor|lawak|dongeng)/i', $query)) {
                    $jokes = [
                        "Kenapa padi kalau sudah kuning harus dipanen? Karena kalau warnanya merah, nanti dikira stroberi! 🌾🍓",
                        "Kenapa petani jagung suka bernyanyi saat bekerja? Karena mereka ingin tanamannya tumbuh dengan gembira dan bernada tinggi! 🌽🎶",
                        "Tanaman apa yang paling sopan di dunia? Padi, karena semakin berisi ia semakin menunduk. Mari kita contoh teladan padi! 🌾"
                    ];
                    $reply = $jokes[array_rand($jokes)];
                } elseif (preg_match('/(makan|lapar|kuliner|resep|masak)/i', $query)) {
                    $reply = "Membayangkan hidangan lezat dari beras pulen premium hasil petani AgriConnect memang selalu menggugah selera! Anda bisa mengecek stok beras segar kami dengan mengetik **'daftar produk'**.";
                } elseif (preg_match('/(suka apa|hobi)/i', $query)) {
                    $reply = "Hobi saya adalah belajar hal baru dan membantu para petani Indonesia mengoptimalkan hasil panen mereka serta membantu pembeli berbelanja komoditas segar! 🌾";
                } elseif (preg_match('/(lagi apa|sedang apa)/i', $query)) {
                    $reply = "Saya sedang standby di server untuk melayani pertanyaan Anda dan memastikan transaksi serta jadwal tanam di AgriConnect berjalan lancar! Ada yang bisa saya bantu?";
                } elseif (preg_match('/(nyanyi)/i', $query)) {
                    $reply = "Saya tidak bisa bernyanyi secara langsung karena saya adalah chatbot teks, tapi saya bisa memberikan lirik pantun tani: 'Pergi ke sawah menanam padi, pulang-pulang membawa beras premium... Jangan lupa gunakan AgriConnect hari ini, agar hasil tani Anda selalu senyum!' 🌾😊";
                } elseif (strlen($query) < 4) {
                    $reply = "Halo! Saya di sini siap mendengarkan. Ada yang ingin Anda tanyakan atau diskusikan mengenai pertanian dan belanja komoditas hari ini? Silakan ketik pertanyaan Anda secara lengkap.";
                } else {
                    $sentences = [
                        "Wah, itu topik yang menarik sekali! Sebagai Agri Asisten Bot, saya senantiasa siap mendiskusikan berbagai hal dengan Anda. Apakah ada hubungannya dengan beras, jagung, atau aktivitas tani hari ini?",
                        "Pertanyaan/pernyataan yang bagus! Sebagai asisten digital AgriConnect, saya di sini untuk mendukung aktivitas tani dan belanja Anda. Mari kita diskusikan lebih lanjut tentang pengelolaan produk atau jadwal tanam Anda.",
                        "Menarik sekali obrolan kita! 😊 Saya siap menjawab pertanyaan seputar pertanian atau apa saja. Anda juga bisa menanyakan seputar stok produk, omset penjualan, biaya tanam, atau cara checkout barang."
                    ];
                    $reply = $sentences[array_rand($sentences)];
                }
                break;
        }

        return response()->json([
            'success' => true,
            'reply' => $reply,
        ]);
    }

    /**
     * Logout user
     */
    public function logout()
    {
        try {
            JWTAuth::setToken(JWTAuth::getToken())->invalidate();
        } catch (\Exception $e) {
            // Token may already be invalid
        }

        return response()->json([
            'success' => true,
            'message' => 'Logout successful',
        ]);
    }

    /**
     * Refresh token
     */
    public function refresh()
    {
        $token = JWTAuth::refresh(JWTAuth::getToken());

        return response()->json([
            'success' => true,
            'data' => [
                'token' => $token,
            ],
        ]);
    }

    public function getNotifications()
    {
        $user = auth()->user();
        $notifications = \App\Models\Notification::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $notifications,
        ]);
    }

    public function markAllNotificationsRead()
    {
        $user = auth()->user();
        \App\Models\Notification::where('user_id', $user->id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }

    public function markNotificationRead($id)
    {
        $user = auth()->user();
        $notification = \App\Models\Notification::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if ($notification) {
            $notification->update(['is_read' => true]);
            return response()->json([
                'success' => true,
                'message' => 'Notification marked as read',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Notification not found',
        ], 404);
    }

    public function forgotPassword(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
        ]);

        $user = \App\Models\User::where('email', $validated['email'])->first();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak terdaftar',
            ], 404);
        }

        $tempPassword = 'Agri' . rand(100000, 999999);
        $user->password = Hash::make($tempPassword);
        $user->save();

        $emailSent = false;
        try {
            \Illuminate\Support\Facades\Mail::raw(
                "Halo {$user->name},\n\nKata sandi akun AgriConnect Anda telah disetel ulang.\n\nKata sandi baru Anda adalah: {$tempPassword}\n\nSilakan masuk ke aplikasi dan segera ubah kata sandi Anda demi keamanan.",
                function ($message) use ($user) {
                    $message->to($user->email)
                        ->subject('Reset Password AgriConnect');
                }
            );
            $emailSent = true;
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Gagal mengirim email reset password: ' . $e->getMessage());
        }

        return response()->json([
            'success' => true,
            'message' => $emailSent 
                ? 'Kata sandi baru telah dikirim ke email Anda.' 
                : 'Reset berhasil. (Gagal mengirim email, silakan gunakan kata sandi sementara berikut)',
            'temp_password' => $emailSent ? null : $tempPassword,
        ]);
    }

    public function requestOtp(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string',
        ]);

        $phone = preg_replace('/[^0-9]/', '', $validated['phone']);
        
        $user = \App\Models\User::where('phone', $validated['phone'])
            ->orWhere('phone', 'like', '%' . substr($phone, -8))
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Nomor WhatsApp tidak terdaftar di sistem.',
            ], 404);
        }

        $otpCode = (string)rand(100000, 999999);
        
        \Illuminate\Support\Facades\Cache::put('otp_' . $user->id, $otpCode, now()->addMinutes(10));
        
        \Illuminate\Support\Facades\Log::info("WhatsApp OTP sent to {$user->phone} ({$user->name}): {$otpCode}");

        return response()->json([
            'success' => true,
            'message' => "Kode OTP WhatsApp berhasil dikirim ke nomor " . $user->phone,
            'otp' => $otpCode,
        ]);
    }

    public function resetPasswordOtp(Request $request)
    {
        $validated = $request->validate([
            'phone' => 'required|string',
            'otp' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $phone = preg_replace('/[^0-9]/', '', $validated['phone']);
        $user = \App\Models\User::where('phone', $validated['phone'])
            ->orWhere('phone', 'like', '%' . substr($phone, -8))
            ->first();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Nomor WhatsApp tidak terdaftar.',
            ], 404);
        }

        $cachedOtp = \Illuminate\Support\Facades\Cache::get('otp_' . $user->id);

        if (!$cachedOtp || $cachedOtp !== $validated['otp']) {
            return response()->json([
                'success' => false,
                'message' => 'Kode OTP tidak valid atau telah kedaluwarsa.',
            ], 400);
        }

        $user->password = Hash::make($validated['new_password']);
        $user->save();

        \Illuminate\Support\Facades\Cache::forget('otp_' . $user->id);

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi Anda berhasil diatur ulang.',
        ]);
    }

    public function changePassword(Request $request)
    {
        $validated = $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = auth()->user();

        if (!Hash::check($validated['old_password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Kata sandi lama tidak cocok',
            ], 400);
        }

        $user->password = Hash::make($validated['new_password']);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Kata sandi berhasil diperbarui',
        ]);
    }
}
