<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WithdrawalController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        $withdrawals = DB::table('withdrawal_requests')->where('user_id', $user->id)->orderBy('created_at', 'desc')->get();
        
        return response()->json([
            'success' => true,
            'data' => $withdrawals
        ]);
    }

    public function store(Request $request)
    {
        $user = auth()->user();
        
        $validated = $request->validate([
            'amount' => 'required|numeric|min:10000',
            'bank_name' => 'required|string',
            'account_number' => 'required|string',
            'account_name' => 'required|string',
        ]);

        if ($user->wallet_balance < $validated['amount']) {
            return response()->json([
                'success' => false, 
                'message' => 'Saldo tidak mencukupi'
            ], 400);
        }

        DB::beginTransaction();
        try {
            // Use query builder to decrement
            DB::table('users')->where('id', $user->id)->decrement('wallet_balance', $validated['amount']);
            
            DB::table('withdrawal_requests')->insert([
                'user_id' => $user->id,
                'amount' => $validated['amount'],
                'status' => 'pending',
                'bank_name' => $validated['bank_name'],
                'account_number' => $validated['account_number'],
                'account_name' => $validated['account_name'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
            
            DB::commit();
            return response()->json([
                'success' => true,
                'message' => 'Permintaan penarikan berhasil dibuat'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat penarikan'
            ], 500);
        }
    }

    public function getPendingPayouts()
    {
        $user = auth()->user();
        if ($user->role !== 'Admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        // 1. Get all pending withdrawal requests
        $pendingRequests = DB::table('withdrawal_requests')
            ->join('users', 'withdrawal_requests.user_id', '=', 'users.id')
            ->where('withdrawal_requests.status', 'pending')
            ->select(
                'users.id as id',
                'users.name as name',
                'withdrawal_requests.amount as wallet_balance',
                'withdrawal_requests.bank_name as nama_bank',
                'withdrawal_requests.account_number as no_rekening'
            )
            ->get()
            ->map(function ($item) {
                $item->is_request = true;
                return (array)$item;
            })
            ->toArray();

        // 2. Get all farmers with wallet_balance > 0 who do NOT have a pending request
        $pendingFarmers = \App\Models\User::where('role', 'Petani')
            ->where('wallet_balance', '>', 0)
            ->whereNotIn('id', function($query) {
                $query->select('user_id')
                      ->from('withdrawal_requests')
                      ->where('status', 'pending');
            })
            ->get(['id', 'name', 'wallet_balance', 'nama_bank', 'no_rekening'])
            ->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'wallet_balance' => $user->wallet_balance,
                    'nama_bank' => $user->nama_bank,
                    'no_rekening' => $user->no_rekening,
                    'is_request' => false,
                ];
            })
            ->toArray();

        $pending = array_merge($pendingRequests, $pendingFarmers);
            
        $history = DB::table('withdrawal_requests')
            ->join('users', 'withdrawal_requests.user_id', '=', 'users.id')
            ->select('withdrawal_requests.*', 'users.name as user_name')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'pending' => $pending,
                'history' => $history
            ]
        ]);
    }

    public function processPayout(Request $request)
    {
        $user = auth()->user();
        if ($user->role !== 'Admin') {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        $validated = $request->validate([
            'user_id' => 'required|exists:users,id'
        ]);

        $petani = \App\Models\User::find($validated['user_id']);

        DB::beginTransaction();
        try {
            // Check if there is a pending withdrawal request for this user
            $pendingRequest = DB::table('withdrawal_requests')
                ->where('user_id', $petani->id)
                ->where('status', 'pending')
                ->first();

            if ($pendingRequest) {
                // Approve the pending request
                DB::table('withdrawal_requests')
                    ->where('id', $pendingRequest->id)
                    ->update([
                        'status' => 'approved',
                        'updated_at' => now(),
                    ]);
                $amount = $pendingRequest->amount;
                $bankName = $pendingRequest->bank_name;
                $accountNumber = $pendingRequest->account_number;

                // Reset wallet_balance petani ke 0 setelah transfer berhasil
                DB::table('users')
                    ->where('id', $petani->id)
                    ->update(['wallet_balance' => 0]);
            } else {
                // Otherwise, pay out the current wallet_balance
                if ($petani->wallet_balance <= 0) {
                     return response()->json(['success' => false, 'message' => 'No balance to payout'], 400);
                }
                $amount = $petani->wallet_balance;
                $bankName = $petani->nama_bank;
                $accountNumber = $petani->no_rekening;

                DB::table('withdrawal_requests')->insert([
                    'user_id' => $petani->id,
                    'amount' => $amount,
                    'status' => 'approved',
                    'bank_name' => $bankName,
                    'account_number' => $accountNumber,
                    'account_name' => $petani->name,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                DB::table('users')
                    ->where('id', $petani->id)
                    ->update(['wallet_balance' => 0]);
            }
            
            // Send notification to the farmer
            $formattedAmount = "Rp " . number_format($amount, 0, ',', '.');
            \App\Models\Notification::send(
                $petani->id,
                "Pencairan Dana Berhasil",
                "Dana penjualan sebesar $formattedAmount telah berhasil ditransfer ke rekening {$bankName} ({$accountNumber}) Anda.",
                "sale" // Maps to NotificationKind.sale
            );

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Payout processed successfully']);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => 'Failed to process payout: ' . $e->getMessage()], 500);
        }
    }
}
