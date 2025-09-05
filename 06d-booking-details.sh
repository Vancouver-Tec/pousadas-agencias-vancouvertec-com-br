#!/bin/bash

# 06d-booking-details.sh - Sistema Pousadas & Agências Vancouver-Tec
# Implementa: detalhes de reserva, favoritos, perfil do usuário

echo "🚀 Iniciando script 06d-booking-details.sh..."
echo "📋 Implementando: detalhes de reserva + favoritos + perfil"

# ===== CONTROLLER DE FAVORITOS =====
echo "📝 Criando FavoriteController..."

cat > app/Http/Controllers/Client/FavoriteController.php << 'EOF'
<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use App\Models\Property;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('client');
    }

    public function index()
    {
        $favorites = Auth::user()->favorites()
            ->with('property.images')
            ->latest()
            ->paginate(12);

        return view('client.favorites.index', compact('favorites'));
    }

    public function toggle(Request $request)
    {
        $request->validate([
            'property_id' => 'required|exists:properties,id'
        ]);

        $property = Property::findOrFail($request->property_id);
        $user = Auth::user();

        $favorite = $user->favorites()
            ->where('property_id', $property->id)
            ->first();

        if ($favorite) {
            $favorite->delete();
            $favorited = false;
            $message = __('messages.favorite_removed');
        } else {
            $user->favorites()->create([
                'property_id' => $property->id
            ]);
            $favorited = true;
            $message = __('messages.favorite_added');
        }

        if ($request->ajax()) {
            return response()->json([
                'favorited' => $favorited,
                'message' => $message
            ]);
        }

        return redirect()->back()->with('success', $message);
    }

    public function destroy($id)
    {
        $favorite = Auth::user()->favorites()->findOrFail($id);
        $favorite->delete();

        return redirect()->back()->with('success', __('messages.favorite_removed'));
    }
}
EOF

# ===== CONTROLLER DE PERFIL =====
echo "📝 Criando ProfileController..."

cat > app/Http/Controllers/Client/ProfileController.php << 'EOF'
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
EOF

# ===== ATUALIZANDO BookingController =====
echo "📝 Atualizando BookingController com view show..."

cat >> app/Http/Controllers/Client/BookingController.php << 'EOF'

    public function show($id)
    {
        $booking = Auth::user()->bookings()
            ->with(['property.images', 'property.user', 'payments'])
            ->findOrFail($id);

        return view('client.bookings.show', compact('booking'));
    }

    public function cancel(Request $request, $id)
    {
        $booking = Auth::user()->bookings()->findOrFail($id);

        if ($booking->status !== 'confirmed') {
            return redirect()->back()->with('error', __('messages.booking_cannot_cancel'));
        }

        $booking->update(['status' => 'cancelled']);

        return redirect()->route('client.bookings.index')
            ->with('success', __('messages.booking_cancelled'));
    }
}
EOF

# ===== VIEW DE FAVORITOS =====
echo "📝 Criando views de favoritos..."

mkdir -p resources/views/client/favorites

cat > resources/views/client/favorites/index.blade.php << 'EOF'
@extends('layouts.client')

@section('title', __('messages.my_favorites'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.my_favorites') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.manage_favorite_properties') }}</p>
        </div>
        <div class="text-muted">
            <i class="fas fa-heart text-danger"></i> {{ $favorites->total() }} {{ __('messages.favorites') }}
        </div>
    </div>

    @if($favorites->count() > 0)
        <div class="row">
            @foreach($favorites as $favorite)
                <div class="col-lg-4 col-md-6 mb-4">
                    <div class="card border-0 shadow-sm h-100">
                        <!-- Image -->
                        <div class="position-relative">
                            @if($favorite->property->images->count() > 0)
                                <img src="{{ asset('storage/' . $favorite->property->images->first()->path) }}" 
                                     class="card-img-top" style="height: 200px; object-fit: cover;" 
                                     alt="{{ $favorite->property->name }}">
                            @else
                                <div class="card-img-top d-flex align-items-center justify-content-center bg-light" 
                                     style="height: 200px;">
                                    <i class="fas fa-image fa-3x text-muted"></i>
                                </div>
                            @endif
                            
                            <!-- Favorite Button -->
                            <button class="btn btn-sm btn-danger position-absolute favorite-btn" 
                                    style="top: 10px; right: 10px;"
                                    onclick="toggleFavorite({{ $favorite->property->id }}, this)">
                                <i class="fas fa-heart"></i>
                            </button>
                        </div>

                        <!-- Content -->
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title mb-2">{{ $favorite->property->name }}</h5>
                            <p class="card-text text-muted mb-2">
                                <i class="fas fa-map-marker-alt"></i> {{ $favorite->property->city }}, {{ $favorite->property->state }}
                            </p>
                            <p class="card-text small text-muted flex-grow-1">
                                {{ Str::limit($favorite->property->description, 100) }}
                            </p>
                            
                            <!-- Price & Rating -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <div class="text-primary font-weight-bold">
                                    R$ {{ number_format($favorite->property->price_per_night, 2, ',', '.') }}
                                    <small class="text-muted">/ {{ __('messages.night') }}</small>
                                </div>
                                @if($favorite->property->reviews_avg_rating)
                                    <div class="text-warning">
                                        @for($i = 1; $i <= 5; $i++)
                                            @if($i <= $favorite->property->reviews_avg_rating)
                                                <i class="fas fa-star"></i>
                                            @else
                                                <i class="far fa-star"></i>
                                            @endif
                                        @endfor
                                        <small>({{ $favorite->property->reviews_count }})</small>
                                    </div>
                                @endif
                            </div>

                            <!-- Actions -->
                            <div class="d-grid gap-2 d-md-flex">
                                <a href="{{ route('site.property.show', $favorite->property->id) }}" 
                                   class="btn btn-primary flex-fill">
                                    {{ __('messages.view_details') }}
                                </a>
                                <form action="{{ route('client.favorites.destroy', $favorite->id) }}" 
                                      method="POST" class="d-inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-outline-danger"
                                            onclick="return confirm('{{ __('messages.confirm_remove_favorite') }}')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>

        <!-- Pagination -->
        <div class="d-flex justify-content-center">
            {{ $favorites->links() }}
        </div>
    @else
        <!-- Empty State -->
        <div class="text-center py-5">
            <i class="fas fa-heart fa-4x text-muted mb-3"></i>
            <h4 class="text-muted">{{ __('messages.no_favorites_yet') }}</h4>
            <p class="text-muted mb-4">{{ __('messages.start_exploring_properties') }}</p>
            <a href="{{ route('site.properties.index') }}" class="btn btn-primary">
                <i class="fas fa-search"></i> {{ __('messages.explore_properties') }}
            </a>
        </div>
    @endif
</div>

@push('scripts')
<script>
function toggleFavorite(propertyId, button) {
    fetch('{{ route("client.favorites.toggle") }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({
            property_id: propertyId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.favorited) {
            button.innerHTML = '<i class="fas fa-heart"></i>';
            button.className = 'btn btn-sm btn-danger position-absolute favorite-btn';
        } else {
            // Remove the card from view since it's no longer favorited
            button.closest('.col-lg-4').remove();
        }
        
        // Show toast notification
        showToast(data.message, data.favorited ? 'success' : 'info');
    })
    .catch(error => {
        console.error('Error:', error);
        showToast('{{ __("messages.error_occurred") }}', 'error');
    });
}

function showToast(message, type) {
    // Simple toast implementation
    const toast = document.createElement('div');
    toast.className = `alert alert-${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} position-fixed`;
    toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999; min-width: 300px;';
    toast.innerHTML = `
        <div class="d-flex align-items-center">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-triangle' : 'info-circle'} me-2"></i>
            ${message}
            <button type="button" class="btn-close ms-auto" onclick="this.parentElement.parentElement.remove()"></button>
        </div>
    `;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        if (toast.parentElement) {
            toast.remove();
        }
    }, 5000);
}
</script>
@endpush
@endsection
EOF

# ===== VIEW DE PERFIL (SHOW) =====
echo "📝 Criando views de perfil..."

mkdir -p resources/views/client/profile

cat > resources/views/client/profile/show.blade.php << 'EOF'
@extends('layouts.client')

@section('title', __('messages.my_profile'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.my_profile') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.manage_personal_information') }}</p>
        </div>
        <div>
            <a href="{{ route('client.profile.edit') }}" class="btn btn-primary me-2">
                <i class="fas fa-edit"></i> {{ __('messages.edit_profile') }}
            </a>
            <a href="{{ route('client.profile.password') }}" class="btn btn-outline-secondary">
                <i class="fas fa-key"></i> {{ __('messages.change_password') }}
            </a>
        </div>
    </div>

    <div class="row">
        <!-- Profile Info -->
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-user text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.personal_information') }}</h6>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.full_name') }}</label>
                            <p class="mb-0 font-weight-bold">{{ $user->name }}</p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.email') }}</label>
                            <p class="mb-0">{{ $user->email }}</p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.phone') }}</label>
                            <p class="mb-0">{{ $user->phone ?: '-' }}</p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.date_of_birth') }}</label>
                            <p class="mb-0">
                                {{ $user->date_of_birth ? $user->date_of_birth->format('d/m/Y') : '-' }}
                            </p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.gender') }}</label>
                            <p class="mb-0">
                                @if($user->gender)
                                    {{ __('messages.gender_' . $user->gender) }}
                                @else
                                    -
                                @endif
                            </p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.member_since') }}</label>
                            <p class="mb-0">{{ $user->created_at->format('M Y') }}</p>
                        </div>
                    </div>

                    @if($user->address || $user->city || $user->state || $user->country)
                        <hr>
                        <h6 class="font-weight-bold text-gray-800 mb-3">{{ __('messages.address_information') }}</h6>
                        <div class="row">
                            <div class="col-12 mb-3">
                                <label class="form-label text-muted small">{{ __('messages.address') }}</label>
                                <p class="mb-0">{{ $user->address ?: '-' }}</p>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label text-muted small">{{ __('messages.city') }}</label>
                                <p class="mb-0">{{ $user->city ?: '-' }}</p>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label text-muted small">{{ __('messages.state') }}</label>
                                <p class="mb-0">{{ $user->state ?: '-' }}</p>
                            </div>
                            <div class="col-md-4 mb-3">
                                <label class="form-label text-muted small">{{ __('messages.zip_code') }}</label>
                                <p class="mb-0">{{ $user->zip_code ?: '-' }}</p>
                            </div>
                        </div>
                    @endif
                </div>
            </div>
        </div>

        <!-- Statistics -->
        <div class="col-lg-4">
            <div class="card shadow mb-4">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-chart-bar text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.activity_summary') }}</h6>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-12 mb-3">
                            <div class="p-3 border rounded">
                                <i class="fas fa-calendar-check text-primary fa-2x mb-2"></i>
                                <h4 class="mb-1 font-weight-bold text-primary">{{ $bookingsCount }}</h4>
                                <small class="text-muted">{{ __('messages.total_bookings') }}</small>
                            </div>
                        </div>
                        <div class="col-12 mb-3">
                            <div class="p-3 border rounded">
                                <i class="fas fa-heart text-danger fa-2x mb-2"></i>
                                <h4 class="mb-1 font-weight-bold text-danger">{{ $favoritesCount }}</h4>
                                <small class="text-muted">{{ __('messages.favorite_properties') }}</small>
                            </div>
                        </div>
                        <div class="col-12">
                            <div class="p-3 border rounded">
                                <i class="fas fa-star text-warning fa-2x mb-2"></i>
                                <h4 class="mb-1 font-weight-bold text-warning">{{ $reviewsCount }}</h4>
                                <small class="text-muted">{{ __('messages.reviews_written') }}</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Quick Actions -->
            <div class="card shadow">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-bolt text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.quick_actions') }}</h6>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <a href="{{ route('client.bookings.index') }}" class="btn btn-outline-primary">
                            <i class="fas fa-list"></i> {{ __('messages.my_bookings') }}
                        </a>
                        <a href="{{ route('client.favorites.index') }}" class="btn btn-outline-danger">
                            <i class="fas fa-heart"></i> {{ __('messages.my_favorites') }}
                        </a>
                        <a href="{{ route('site.properties.index') }}" class="btn btn-outline-success">
                            <i class="fas fa-search"></i> {{ __('messages.explore_properties') }}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

echo "✅ Script 06d-booking-details.sh executado com sucesso!"
echo "📋 Implementado:"
echo "  - FavoriteController com toggle e gestão"
echo "  - ProfileController com edição e senha"  
echo "  - BookingController atualizado com show/cancel"
echo "  - Views de favoritos completas"
echo "  - View de perfil com estatísticas"
echo ""
echo "⏭️  Próximo: continuar com views de edição de perfil"
echo "💡 Digite 'continuar' para prosseguir..."