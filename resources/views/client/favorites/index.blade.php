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
