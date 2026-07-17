<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FarmerLand;
use Illuminate\Http\Request;

class FarmerLandController extends Controller
{
    public function index()
    {
        $lands = FarmerLand::where('user_id', auth()->id())->get();

        return response()->json([
            'success' => true,
            'data' => $lands,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'area_size' => 'nullable|string|max:255',
            'description' => 'nullable|string|max:1000',
        ]);

        $land = FarmerLand::create(array_merge($validated, [
            'user_id' => auth()->id(),
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Lahan berhasil ditambahkan.',
            'data' => $land,
        ], 201);
    }

    public function destroy(FarmerLand $land)
    {
        if ($land->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $land->delete();

        return response()->json([
            'success' => true,
            'message' => 'Lahan berhasil dihapus.',
        ]);
    }
}
