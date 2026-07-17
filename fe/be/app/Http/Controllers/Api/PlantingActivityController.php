<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PlantingActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PlantingActivityController extends Controller
{
    public function index(Request $request)
    {
        $validated = $request->validate([
            'schedule_name' => 'required|string|max:255',
        ]);

        $activities = PlantingActivity::query()
            ->where('user_id', auth()->id())
            ->where('schedule_name', $validated['schedule_name'])
            ->orderBy('activity_date')
            ->orderBy('id')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $activities,
        ]);
    }

    public function sync(Request $request)
    {
        $validated = $request->validate([
            'schedule_name' => 'required|string|max:255',
            'activities' => 'array',
            'activities.*.activity_date' => 'required|date',
            'activities.*.title' => 'required|string|max:255',
            'activities.*.note' => 'nullable|string|max:1000',
            'activities.*.cost' => 'required|integer|min:0',
        ]);

        $userId = auth()->id();
        $scheduleName = $validated['schedule_name'];

        $activities = DB::transaction(function () use ($validated, $userId, $scheduleName) {
            PlantingActivity::query()
                ->where('user_id', $userId)
                ->where('schedule_name', $scheduleName)
                ->delete();

            foreach ($validated['activities'] ?? [] as $activity) {
                PlantingActivity::create([
                    'user_id' => $userId,
                    'schedule_name' => $scheduleName,
                    'activity_date' => $activity['activity_date'],
                    'title' => $activity['title'],
                    'note' => $activity['note'] ?? null,
                    'cost' => $activity['cost'],
                ]);
            }

            return PlantingActivity::query()
                ->where('user_id', $userId)
                ->where('schedule_name', $scheduleName)
                ->orderBy('activity_date')
                ->orderBy('id')
                ->get();
        });

        return response()->json([
            'success' => true,
            'message' => 'Aktivitas tanam tersimpan.',
            'data' => $activities,
        ]);
    }
}
