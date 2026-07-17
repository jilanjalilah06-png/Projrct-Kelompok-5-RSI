<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PetaniController extends Controller
{
    private function isAdmin()
    {
        return auth()->check() && auth()->user()->role === 'Admin';
    }

    /**
     * Toggle status keaktifan petani
     */
    public function toggleStatus(Request $request, User $user)
    {
        if (!$this->isAdmin()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized. Admin only.',
            ], 403);
        }

        if ($user->role !== 'Petani') {
            return response()->json([
                'success' => false,
                'message' => 'User is not a Petani.',
            ], 400);
        }

        $user->is_active = !$user->is_active;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Status keaktifan petani berhasil diubah',
            'data' => $user,
        ]);
    }
}
