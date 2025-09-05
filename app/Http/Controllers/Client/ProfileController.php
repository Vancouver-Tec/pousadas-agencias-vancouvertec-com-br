<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class ProfileController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('client');
    }

    public function show()
    {
        $user = Auth::user();
        $bookingsCount = $user->bookings()->count();
        $favoritesCount = $user->favorites()->count();
        $reviewsCount = $user->reviews()->count();

        return view('client.profile.show', compact('user', 'bookingsCount', 'favoritesCount', 'reviewsCount'));
    }

    public function edit()
    {
        $user = Auth::user();
        return view('client.profile.edit', compact('user'));
    }

    public function update(Request $request)
    {
        $user = Auth::user();

        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
            'date_of_birth' => 'nullable|date|before:today',
            'gender' => 'nullable|in:male,female,other',
            'address' => 'nullable|string|max:500',
            'city' => 'nullable|string|max:100',
            'state' => 'nullable|string|max:50',
            'zip_code' => 'nullable|string|max:20',
            'country' => 'nullable|string|max:50',
        ]);

        $user->update($request->only([
            'name', 'email', 'phone', 'date_of_birth', 'gender',
            'address', 'city', 'state', 'zip_code', 'country'
        ]));

        return redirect()->route('client.profile.show')
            ->with('success', __('messages.profile_updated'));
    }

    public function password()
    {
        return view('client.profile.password');
    }

    public function updatePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|current_password',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        Auth::user()->update([
            'password' => Hash::make($request->password),
        ]);

        return redirect()->route('client.profile.show')
            ->with('success', __('messages.password_updated'));
    }
}
