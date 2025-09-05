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
