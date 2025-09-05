#!/bin/bash

# 06d-booking-details-part2.sh - Sistema Pousadas & Agências Vancouver-Tec
# Continuação: views de edição de perfil, senha e detalhes de reserva

echo "🚀 Iniciando script 06d-booking-details-part2.sh..."
echo "📋 Implementando: edição de perfil + senha + detalhes de reserva"

# ===== VIEW DE EDIÇÃO DE PERFIL =====
echo "📝 Criando view de edição de perfil..."

cat > resources/views/client/profile/edit.blade.php << 'EOF'
@extends('layouts.client')

@section('title', __('messages.edit_profile'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.edit_profile') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.update_personal_information') }}</p>
        </div>
        <a href="{{ route('client.profile.show') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> {{ __('messages.back_to_profile') }}
        </a>
    </div>

    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="card shadow">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-user-edit text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.personal_information') }}</h6>
                </div>
                <div class="card-body">
                    <form action="{{ route('client.profile.update') }}" method="POST">
                        @csrf
                        @method('PUT')

                        <!-- Basic Information -->
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="name" class="form-label">{{ __('messages.full_name') }} <span class="text-danger">*</span></label>
                                <input type="text" class="form-control @error('name') is-invalid @enderror" 
                                       id="name" name="name" value="{{ old('name', $user->name) }}" required>
                                @error('name')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label">{{ __('messages.email') }} <span class="text-danger">*</span></label>
                                <input type="email" class="form-control @error('email') is-invalid @enderror" 
                                       id="email" name="email" value="{{ old('email', $user->email) }}" required>
                                @error('email')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="phone" class="form-label">{{ __('messages.phone') }}</label>
                                <input type="text" class="form-control @error('phone') is-invalid @enderror" 
                                       id="phone" name="phone" value="{{ old('phone', $user->phone) }}">
                                @error('phone')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="date_of_birth" class="form-label">{{ __('messages.date_of_birth') }}</label>
                                <input type="date" class="form-control @error('date_of_birth') is-invalid @enderror" 
                                       id="date_of_birth" name="date_of_birth" 
                                       value="{{ old('date_of_birth', $user->date_of_birth?->format('Y-m-d')) }}">
                                @error('date_of_birth')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="gender" class="form-label">{{ __('messages.gender') }}</label>
                                <select class="form-select @error('gender') is-invalid @enderror" id="gender" name="gender">
                                    <option value="">{{ __('messages.select_gender') }}</option>
                                    <option value="male" {{ old('gender', $user->gender) == 'male' ? 'selected' : '' }}>
                                        {{ __('messages.gender_male') }}
                                    </option>
                                    <option value="female" {{ old('gender', $user->gender) == 'female' ? 'selected' : '' }}>
                                        {{ __('messages.gender_female') }}
                                    </option>
                                    <option value="other" {{ old('gender', $user->gender) == 'other' ? 'selected' : '' }}>
                                        {{ __('messages.gender_other') }}
                                    </option>
                                </select>
                                @error('gender')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <!-- Address Information -->
                        <hr class="my-4">
                        <h6 class="font-weight-bold text-gray-800 mb-3">{{ __('messages.address_information') }}</h6>

                        <div class="mb-3">
                            <label for="address" class="form-label">{{ __('messages.address') }}</label>
                            <textarea class="form-control @error('address') is-invalid @enderror" 
                                      id="address" name="address" rows="2">{{ old('address', $user->address) }}</textarea>
                            @error('address')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label for="city" class="form-label">{{ __('messages.city') }}</label>
                                <input type="text" class="form-control @error('city') is-invalid @enderror" 
                                       id="city" name="city" value="{{ old('city', $user->city) }}">
                                @error('city')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="state" class="form-label">{{ __('messages.state') }}</label>
                                <input type="text" class="form-control @error('state') is-invalid @enderror" 
                                       id="state" name="state" value="{{ old('state', $user->state) }}">
                                @error('state')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                            <div class="col-md-4 mb-3">
                                <label for="zip_code" class="form-label">{{ __('messages.zip_code') }}</label>
                                <input type="text" class="form-control @error('zip_code') is-invalid @enderror" 
                                       id="zip_code" name="zip_code" value="{{ old('zip_code', $user->zip_code) }}">
                                @error('zip_code')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-4">
                            <label for="country" class="form-label">{{ __('messages.country') }}</label>
                            <input type="text" class="form-control @error('country') is-invalid @enderror" 
                                   id="country" name="country" value="{{ old('country', $user->country) }}">
                            @error('country')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <!-- Actions -->
                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ route('client.profile.show') }}" class="btn btn-secondary">
                                {{ __('messages.cancel') }}
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> {{ __('messages.save_changes') }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
EOF

# ===== VIEW DE ALTERAÇÃO DE SENHA =====
echo "📝 Criando view de alteração de senha..."

cat > resources/views/client/profile/password.blade.php << 'EOF'
@extends('layouts.client')

@section('title', __('messages.change_password'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.change_password') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.update_account_password') }}</p>
        </div>
        <a href="{{ route('client.profile.show') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left"></i> {{ __('messages.back_to_profile') }}
        </a>
    </div>

    <div class="row justify-content-center">
        <div class="col-lg-6">
            <div class="card shadow">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-key text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.password_security') }}</h6>
                </div>
                <div class="card-body">
                    <!-- Security Tips -->
                    <div class="alert alert-info mb-4">
                        <i class="fas fa-info-circle me-2"></i>
                        <strong>{{ __('messages.security_tips') }}:</strong>
                        <ul class="mb-0 mt-2">
                            <li>{{ __('messages.password_tip_1') }}</li>
                            <li>{{ __('messages.password_tip_2') }}</li>
                            <li>{{ __('messages.password_tip_3') }}</li>
                        </ul>
                    </div>

                    <form action="{{ route('client.profile.password.update') }}" method="POST">
                        @csrf
                        @method('PUT')

                        <div class="mb-3">
                            <label for="current_password" class="form-label">{{ __('messages.current_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('current_password') is-invalid @enderror" 
                                       id="current_password" name="current_password" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('current_password')">
                                    <i class="fas fa-eye" id="current_password_icon"></i>
                                </button>
                            </div>
                            @error('current_password')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">{{ __('messages.new_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password') is-invalid @enderror" 
                                       id="password" name="password" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('password')">
                                    <i class="fas fa-eye" id="password_icon"></i>
                                </button>
                            </div>
                            @error('password')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                            <div class="form-text">{{ __('messages.password_requirements') }}</div>
                        </div>

                        <div class="mb-4">
                            <label for="password_confirmation" class="form-label">{{ __('messages.confirm_new_password') }} <span class="text-danger">*</span></label>
                            <div class="input-group">
                                <input type="password" class="form-control @error('password_confirmation') is-invalid @enderror" 
                                       id="password_confirmation" name="password_confirmation" required>
                                <button type="button" class="btn btn-outline-secondary" onclick="togglePassword('password_confirmation')">
                                    <i class="fas fa-eye" id="password_confirmation_icon"></i>
                                </button>
                            </div>
                            @error('password_confirmation')
                                <div class="invalid-feedback d-block">{{ $message }}</div>
                            @enderror
                        </div>

                        <!-- Actions -->
                        <div class="d-flex justify-content-end gap-2">
                            <a href="{{ route('client.profile.show') }}" class="btn btn-secondary">
                                {{ __('messages.cancel') }}
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> {{ __('messages.update_password') }}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
function togglePassword(fieldId) {
    const field = document.getElementById(fieldId);
    const icon = document.getElementById(fieldId + '_icon');
    
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.remove('fa-eye');
        icon.classList.add('fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.remove('fa-eye-slash');
        icon.classList.add('fa-eye');
    }
}

// Password strength indicator
document.getElementById('password').addEventListener('input', function() {
    const password = this.value;
    const strengthBar = document.getElementById('strength-bar');
    
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.match(/[a-z]/)) strength++;
    if (password.match(/[A-Z]/)) strength++;
    if (password.match(/[0-9]/)) strength++;
    if (password.match(/[^a-zA-Z0-9]/)) strength++;
    
    const colors = ['#dc3545', '#fd7e14', '#ffc107', '#20c997', '#28a745'];
    const labels = ['{{ __("messages.very_weak") }}', '{{ __("messages.weak") }}', '{{ __("messages.fair") }}', '{{ __("messages.good") }}', '{{ __("messages.strong") }}'];
    
    if (strengthBar) {
        strengthBar.style.width = (strength * 20) + '%';
        strengthBar.style.backgroundColor = colors[strength - 1] || '#dc3545';
        strengthBar.textContent = labels[strength - 1] || '';
    }
});
</script>
@endpush
@endsection
EOF

# ===== VIEW DE DETALHES DA RESERVA =====
echo "📝 Criando view de detalhes da reserva..."

mkdir -p resources/views/client/bookings

cat > resources/views/client/bookings/show.blade.php << 'EOF'
@extends('layouts.client')

@section('title', __('messages.booking_details'))

@section('content')
<div class="container-fluid px-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h1 class="h3 mb-0 text-gray-800">{{ __('messages.booking_details') }}</h1>
            <p class="mb-0 text-muted">{{ __('messages.booking_number') }}: #{{ $booking->id }}</p>
        </div>
        <div>
            <a href="{{ route('client.bookings.index') }}" class="btn btn-outline-secondary me-2">
                <i class="fas fa-arrow-left"></i> {{ __('messages.back_to_bookings') }}
            </a>
            @if($booking->status === 'confirmed')
                <form action="{{ route('client.bookings.cancel', $booking->id) }}" method="POST" class="d-inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger"
                            onclick="return confirm('{{ __('messages.confirm_cancel_booking') }}')">
                        <i class="fas fa-times"></i> {{ __('messages.cancel_booking') }}
                    </button>
                </form>
            @endif
        </div>
    </div>

    <div class="row">
        <!-- Booking Information -->
        <div class="col-lg-8">
            <!-- Status & Dates -->
            <div class="card shadow mb-4">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-calendar-check text-primary me-2"></i>
                        <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.booking_information') }}</h6>
                    </div>
                    <span class="badge bg-{{ $booking->status === 'confirmed' ? 'success' : ($booking->status === 'cancelled' ? 'danger' : 'warning') }} fs-6">
                        {{ __('messages.status_' . $booking->status) }}
                    </span>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.check_in') }}</label>
                            <p class="mb-0 font-weight-bold">
                                <i class="fas fa-sign-in-alt text-success me-1"></i>
                                {{ $booking->check_in->format('d/m/Y') }} - {{ $booking->check_in->format('l') }}
                            </p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.check_out') }}</label>
                            <p class="mb-0 font-weight-bold">
                                <i class="fas fa-sign-out-alt text-danger me-1"></i>
                                {{ $booking->check_out->format('d/m/Y') }} - {{ $booking->check_out->format('l') }}
                            </p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.nights') }}</label>
                            <p class="mb-0">{{ $booking->nights }} {{ __('messages.nights') }}</p>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label text-muted small">{{ __('messages.guests') }}</label>
                            <p class="mb-0">{{ $booking->guests }} {{ __('messages.guests') }}</p>
                        </div>
                        <div class="col-12">
                            <label class="form-label text-muted small">{{ __('messages.booking_date') }}</label>
                            <p class="mb-0">{{ $booking->created_at->format('d/m/Y H:i') }}</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Property Details -->
            <div class="card shadow mb-4">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-home text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.property_details') }}</h6>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-4">
                            @if($booking->property->images->count() > 0)
                                <img src="{{ asset('storage/' . $booking->property->images->first()->path) }}" 
                                     class="img-fluid rounded" style="height: 200px; width: 100%; object-fit: cover;" 
                                     alt="{{ $booking->property->name }}">
                            @else
                                <div class="d-flex align-items-center justify-content-center bg-light rounded" 
                                     style="height: 200px;">
                                    <i class="fas fa-image fa-3x text-muted"></i>
                                </div>
                            @endif
                        </div>
                        <div class="col-md-8">
                            <h5 class="font-weight-bold mb-2">{{ $booking->property->name }}</h5>
                            <p class="text-muted mb-2">
                                <i class="fas fa-map-marker-alt"></i> 
                                {{ $booking->property->address }}, {{ $booking->property->city }}, {{ $booking->property->state }}
                            </p>
                            <p class="mb-3">{{ Str::limit($booking->property->description, 200) }}</p>
                            
                            <!-- Property Features -->
                            <div class="row">
                                <div class="col-6">
                                    <small class="text-muted">{{ __('messages.bedrooms') }}: {{ $booking->property->bedrooms }}</small>
                                </div>
                                <div class="col-6">
                                    <small class="text-muted">{{ __('messages.bathrooms') }}: {{ $booking->property->bathrooms }}</small>
                                </div>
                                <div class="col-6">
                                    <small class="text-muted">{{ __('messages.max_guests') }}: {{ $booking->property->max_guests }}</small>
                                </div>
                                <div class="col-6">
                                    <small class="text-muted">{{ __('messages.property_type') }}: {{ $booking->property->type }}</small>
                                </div>
                            </div>

                            <div class="mt-3">
                                <a href="{{ route('site.property.show', $booking->property->id) }}" 
                                   class="btn btn-outline-primary btn-sm">
                                    <i class="fas fa-external-link-alt"></i> {{ __('messages.view_property') }}
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Contact Information -->
            <div class="card shadow">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-user-circle text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.host_contact') }}</h6>
                </div>
                <div class="card-body">
                    <div class="d-flex align-items-center">
                        <div class="me-3">
                            <i class="fas fa-user-circle fa-3x text-muted"></i>
                        </div>
                        <div>
                            <h6 class="mb-1">{{ $booking->property->user->name }}</h6>
                            <p class="mb-1 text-muted">{{ $booking->property->user->email }}</p>
                            @if($booking->property->user->phone)
                                <p class="mb-0 text-muted">
                                    <i class="fas fa-phone"></i> {{ $booking->property->user->phone }}
                                </p>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Summary & Payment -->
        <div class="col-lg-4">
            <!-- Price Summary -->
            <div class="card shadow mb-4">
                <div class="card-header d-flex align-items-center">
                    <i class="fas fa-calculator text-primary me-2"></i>
                    <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.price_summary') }}</h6>
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between mb-2">
                        <span>{{ __('messages.price_per_night') }}</span>
                        <span>R$ {{ number_format($booking->price_per_night, 2, ',', '.') }}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>{{ $booking->nights }} {{ __('messages.nights') }}</span>
                        <span>R$ {{ number_format($booking->price_per_night * $booking->nights, 2, ',', '.') }}</span>
                    </div>
                    @if($booking->service_fee > 0)
                        <div class="d-flex justify-content-between mb-2">
                            <span>{{ __('messages.service_fee') }}</span>
                            <span>R$ {{ number_format($booking->service_fee, 2, ',', '.') }}</span>
                        </div>
                    @endif
                    @if($booking->taxes > 0)
                        <div class="d-flex justify-content-between mb-3">
                            <span>{{ __('messages.taxes') }}</span>
                            <span>R$ {{ number_format($booking->taxes, 2, ',', '.') }}</span>
                        </div>
                    @endif
                    <hr>
                    <div class="d-flex justify-content-between font-weight-bold h5">
                        <span>{{ __('messages.total') }}</span>
                        <span class="text-primary">R$ {{ number_format($booking->total_amount, 2, ',', '.') }}</span>
                    </div>
                </div>
            </div>

            <!-- Payment Information -->
            @if($booking->payments->count() > 0)
                <div class="card shadow">
                    <div class="card-header d-flex align-items-center">
                        <i class="fas fa-credit-card text-primary me-2"></i>
                        <h6 class="m-0 font-weight-bold text-primary">{{ __('messages.payment_information') }}</h6>
                    </div>
                    <div class="card-body">
                        @foreach($booking->payments as $payment)
                            <div class="mb-3 {{ !$loop->last ? 'border-bottom pb-3' : '' }}">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="font-weight-bold">
                                        {{ __('messages.payment') }} #{{ $payment->id }}
                                    </span>
                                    <span class="badge bg-{{ $payment->status === 'completed' ? 'success' : ($payment->status === 'failed' ? 'danger' : 'warning') }}">
                                        {{ __('messages.payment_status_' . $payment->status) }}
                                    </span>
                                </div>
                                <div class="small text-muted">
                                    <div>{{ __('messages.amount') }}: R$ {{ number_format($payment->amount, 2, ',', '.') }}</div>
                                    <div>{{ __('messages.method') }}: {{ $payment->payment_method }}</div>
                                    <div>{{ __('messages.date') }}: {{ $payment->created_at->format('d/m/Y H:i') }}</div>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection
EOF

# ===== ATUALIZANDO ROTAS =====
echo "📝 Atualizando rotas para novas funcionalidades..."

cat >> routes/web.php << 'EOF'

// Rotas de Favoritos
Route::get('/client/favorites', [App\Http\Controllers\Client\FavoriteController::class, 'index'])->name('client.favorites.index');
Route::post('/client/favorites/toggle', [App\Http\Controllers\Client\FavoriteController::class, 'toggle'])->name('client.favorites.toggle');
Route::delete('/client/favorites/{id}', [App\Http\Controllers\Client\FavoriteController::class, 'destroy'])->name('client.favorites.destroy');

// Rotas de Perfil
Route::get('/client/profile', [App\Http\Controllers\Client\ProfileController::class, 'show'])->name('client.profile.show');
Route::get('/client/profile/edit', [App\Http\Controllers\Client\ProfileController::class, 'edit'])->name('client.profile.edit');
Route::put('/client/profile', [App\Http\Controllers\Client\ProfileController::class, 'update'])->name('client.profile.update');
Route::get('/client/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'password'])->name('client.profile.password');
Route::put('/client/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'updatePassword'])->name('client.profile.password.update');

// Rota adicional para detalhes de reserva
Route::get('/client/bookings/{id}', [App\Http\Controllers\Client\BookingController::class, 'show'])->name('client.bookings.show');
Route::delete('/client/bookings/{id}/cancel', [App\Http\Controllers\Client\BookingController::class, 'cancel'])->name('client.bookings.cancel');
EOF

echo "✅ Script 06d-booking-details-part2.sh executado com sucesso!"