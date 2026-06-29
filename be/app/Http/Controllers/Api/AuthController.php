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
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|unique:users',
                'password' => 'required|string|min:6|confirmed',
                'phone' => 'nullable|string',
                'address' => 'nullable|string',
                'role' => 'required|in:Admin,Petani,Pembeli',
                'shop_name' => 'nullable|string|max:255',
                'shop_description' => 'nullable|string',
            ]);

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'phone' => $validated['phone'] ?? null,
                'address' => $validated['address'] ?? null,
                'role' => $validated['role'],
                'shop_name' => $validated['shop_name'] ?? null,
                'shop_description' => $validated['shop_description'] ?? null,
            ]);

            $token = JWTAuth::fromUser($user);

            // Auto-update the registered users list in storage folder (synced to Windows host)
            try {
                $users = User::select('id', 'name', 'email', 'role', 'phone', 'address', 'shop_name', 'created_at')->get();
                file_put_contents(storage_path('registered_users.json'), json_encode($users, JSON_PRETTY_PRINT));
            } catch (\Exception $e) {
                // Ignore backup error so it doesn't interrupt registration
            }

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

    /**
     * Update authenticated user profile
     */
    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'name' => 'sometimes|string|max:255',
            'phone' => 'nullable|string',
            'address' => 'nullable|string',
            'shop_name' => 'nullable|string|max:255',
            'shop_description' => 'nullable|string',
            'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:4096',
        ]);

        $user = auth()->user();

        if ($request->hasFile('avatar')) {
            if ($user->avatar) {
                Storage::disk('public')->delete($user->avatar);
            }

            $validated['avatar'] = $request->file('avatar')->store('avatars', 'public');
        }

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $user->fresh(),
        ]);
    }

    /**
     * Logout user
     */
    public function logout()
    {
        JWTAuth::invalidate(JWTAuth::getToken());

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
}
