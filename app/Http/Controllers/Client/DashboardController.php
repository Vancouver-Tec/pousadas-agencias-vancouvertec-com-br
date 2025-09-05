<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Property;
use App\Models\Favorite;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        $stats = [
            'total_bookings' => $user->bookings()->count(),
            'active_bookings' => $user->bookings()->whereIn('status', ['confirmed', 'pending'])->count(),
            'completed_bookings' => $user->bookings()->where('status', 'completed')->count(),
            'favorites' => $user->favorites()->count(),
        ];
        
        $recentBookings = $user->bookings()
            ->with('property')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();
            
        $upcomingBookings = $user->bookings()
            ->with('property')
            ->where('status', 'confirmed')
            ->where('check_in', '>=', now())
            ->orderBy('check_in')
            ->limit(3)
            ->get();
        
        return view('client.dashboard', compact('stats', 'recentBookings', 'upcomingBookings'));
    }
    
    public function bookings()
    {
        $bookings = Auth::user()->bookings()
            ->with(['property', 'payments'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);
        
        return view('client.bookings', compact('bookings'));
    }
    
    public function bookingShow($id)
    {
        $booking = Auth::user()->bookings()
            ->with(['property', 'payments', 'review'])
            ->findOrFail($id);
        
        return view('client.booking-show', compact('booking'));
    }
    
    public function profile()
    {
        $user = Auth::user();
        return view('client.profile', compact('user'));
    }
    
    public function updateProfile(Request $request)
    {
        $user = Auth::user();
        
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
            'document' => 'nullable|string|max:20',
            'birth_date' => 'nullable|date',
            'address' => 'nullable|string|max:500',
            'city' => 'nullable|string|max:100',
            'state' => 'nullable|string|max:100',
            'country' => 'nullable|string|max:100',
            'zip_code' => 'nullable|string|max:20',
            'preferred_language' => 'required|in:pt,en,es',
        ], [
            'name.required' => 'O nome é obrigatório.',
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Digite um e-mail válido.',
            'email.unique' => 'Este e-mail já está sendo usado.',
            'preferred_language.required' => 'Selecione um idioma.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput();
        }

        $user->update($request->only([
            'name', 'email', 'phone', 'document', 'birth_date',
            'address', 'city', 'state', 'country', 'zip_code', 'preferred_language'
        ]));

        return back()->with('success', 'Perfil atualizado com sucesso!');
    }
    
    public function updatePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'password' => 'required|string|min:6|confirmed',
        ], [
            'current_password.required' => 'A senha atual é obrigatória.',
            'password.required' => 'A nova senha é obrigatória.',
            'password.min' => 'A nova senha deve ter pelo menos 6 caracteres.',
            'password.confirmed' => 'A confirmação da senha não confere.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput();
        }

        $user = Auth::user();

        if (!Hash::check($request->current_password, $user->password)) {
            return back()
                ->withErrors(['current_password' => 'Senha atual incorreta.']);
        }

        $user->update([
            'password' => Hash::make($request->password)
        ]);

        return back()->with('success', 'Senha alterada com sucesso!');
    }
    
    public function favorites()
    {
        $favorites = Auth::user()->favorites()
            ->with('property')
            ->orderBy('created_at', 'desc')
            ->paginate(12);
        
        return view('client.favorites', compact('favorites'));
    }
    
    public function toggleFavorite($propertyId)
    {
        $user = Auth::user();
        $property = Property::findOrFail($propertyId);
        
        $favorite = $user->favorites()->where('property_id', $propertyId)->first();
        
        if ($favorite) {
            $favorite->delete();
            $message = 'Propriedade removida dos favoritos.';
        } else {
            $user->favorites()->create(['property_id' => $propertyId]);
            $message = 'Propriedade adicionada aos favoritos!';
        }
        
        return response()->json(['success' => true, 'message' => $message]);
    }
}
