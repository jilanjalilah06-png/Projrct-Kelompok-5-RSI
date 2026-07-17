<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PlantingSchedule;
use Illuminate\Http\Request;

class PlantingScheduleController extends Controller
{
    public function index()
    {
        $schedules = PlantingSchedule::where('user_id', auth()->id())->get();

        return response()->json([
            'success' => true,
            'data' => $schedules,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'plant' => 'required|string|max:255',
            'land' => 'required|string|max:255',
            'start_date' => 'required|date',
            'harvest_date' => 'required|date',
            'harvest_end_date' => 'required|date',
            'status' => 'required|string|in:planned,active,done',
        ]);

        $schedule = PlantingSchedule::create(array_merge($validated, [
            'user_id' => auth()->id(),
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Jadwal tanam berhasil ditambahkan.',
            'data' => $schedule,
        ], 201);
    }

    public function update(Request $request, PlantingSchedule $schedule)
    {
        if ($schedule->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $validated = $request->validate([
            'plant' => 'sometimes|required|string|max:255',
            'land' => 'sometimes|required|string|max:255',
            'start_date' => 'sometimes|required|date',
            'harvest_date' => 'sometimes|required|date',
            'harvest_end_date' => 'sometimes|required|date',
            'status' => 'sometimes|required|string|in:planned,active,done',
        ]);

        $schedule->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Jadwal tanam berhasil diperbarui.',
            'data' => $schedule,
        ]);
    }

    public function destroy(PlantingSchedule $schedule)
    {
        if ($schedule->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 403);
        }

        $schedule->delete();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal tanam berhasil dihapus.',
        ]);
    }
}
