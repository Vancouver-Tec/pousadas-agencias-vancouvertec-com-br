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
