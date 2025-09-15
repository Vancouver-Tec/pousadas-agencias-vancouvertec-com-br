@extends('layouts.site')

@section('title', $title)

@section('content')
<!-- Hero Section -->
<section class="booking-gradient text-white py-16">
    <div class="container mx-auto px-4">
        <div class="text-center mb-8">
            <h1 class="text-4xl md:text-5xl font-bold mb-4">{{ $title }}</h1>
            <p class="text-xl opacity-90">{{ $subtitle }}</p>
        </div>

        <!-- Search Form -->
        <div class="max-w-4xl mx-auto bg-white rounded-lg shadow-xl p-6">
            <form action="{{ route('site.properties.index') }}" method="GET" id="searchForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <!-- Destino -->
                <div class="relative">
                    <label for="destination" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-map-marker-alt mr-1"></i>Para onde você vai?
                    </label>
                    <input type="text" 
                           id="destination" 
                           name="destination" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="Cidade, região, propriedade"
                           autocomplete="off">
                    
                    <!-- Suggestions Dropdown -->
                    <div id="suggestions" class="absolute z-10 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden search-suggestions"></div>
                </div>

                <!-- Check-in -->
                <div>
                    <label for="check_in" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-calendar-alt mr-1"></i>Check-in
                    </label>
                    <input type="date" 
                           id="check_in" 
                           name="check_in" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           value="{{ date('Y-m-d') }}"
                           min="{{ date('Y-m-d') }}">
                </div>

                <!-- Check-out -->
                <div>
                    <label for="check_out" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-calendar-alt mr-1"></i>Check-out
                    </label>
                    <input type="date" 
                           id="check_out" 
                           name="check_out" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           value="{{ date('Y-m-d', strtotime('+1 day')) }}"
                           min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>

                <!-- Hóspedes e Buscar -->
                <div>
                    <label for="guests" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-users mr-1"></i>Hóspedes
                    </label>
                    <div class="flex">
                        <select id="guests" 
                                name="guests" 
                                class="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="1">1 hóspede</option>
                            <option value="2">2 hóspedes</option>
                            <option value="3">3 hóspedes</option>
                            <option value="4">4 hóspedes</option>
                            <option value="5">5+ hóspedes</option>
                        </select>
                        <button type="submit" 
                                class="px-6 py-3 booking-blue-light text-white rounded-r-lg hover:bg-blue-700 transition-colors">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<!-- Featured Properties -->
@if($featuredProperties->count() > 0)
<section class="py-16">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Propriedades em Destaque</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            @foreach($featuredProperties as $property)
                <div class="property-card bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow">
                    <div class="relative overflow-hidden h-48">
                        @if($property->photos && $property->photos->count() > 0)
                            <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                 alt="{{ $property->name }}"
                                 class="property-image w-full h-full object-cover">
                        @else
                            <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                <i class="fas fa-image text-gray-400 text-2xl"></i>
                            </div>
                        @endif
                        <div class="absolute top-3 right-3">
                            <span class="bg-yellow-400 text-yellow-900 px-2 py-1 rounded text-xs font-bold">
                                <i class="fas fa-star mr-1"></i>{{ number_format($property->average_rating ?: $property->rating, 1) }}
                            </span>
                        </div>
                    </div>
                    
                    <div class="p-4">
                        <h3 class="font-bold text-lg text-gray-900 mb-2 truncate">{{ $property->name }}</h3>
                        <p class="text-gray-600 text-sm mb-3 flex items-center">
                            <i class="fas fa-map-marker-alt mr-2"></i>
                            {{ $property->city }}, {{ $property->state }}
                        </p>
                        <div class="flex items-center justify-between">
                            <div>
                                <span class="text-2xl font-bold text-gray-900">R$ {{ number_format($property->price_per_night, 0, ',', '.') }}</span>
                                <span class="text-gray-600 text-sm"> / noite</span>
                            </div>
                            <a href="{{ route('site.properties.show', $property->id) }}" 
                               class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700 transition">
                                Ver Detalhes
                            </a>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
@endif

<!-- Popular Destinations -->
@if($popularDestinations->count() > 0)
<section class="py-16 bg-gray-100">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Destinos Populares</h2>
        
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            @foreach($popularDestinations as $destination)
                <a href="{{ route('site.properties.index', ['destination' => $destination->city_name]) }}" 
                   class="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-center">
                    <i class="fas fa-city text-2xl text-blue-600 mb-2"></i>
                    <h3 class="font-bold text-gray-900">{{ $destination->city_name }}</h3>
                    <p class="text-gray-600 text-sm">{{ $destination->properties_count }} propriedades</p>
                </a>
            @endforeach
        </div>
    </div>
</section>
@endif

<!-- Call to Action -->
<section class="py-16 booking-gradient text-white">
    <div class="container mx-auto px-4 text-center">
        <h2 class="text-3xl font-bold mb-4">Pronto para começar sua aventura?</h2>
        <p class="text-xl mb-8 opacity-90">Encontre a hospedagem perfeita para sua próxima viagem</p>
        <a href="{{ route('site.properties.index') }}" 
           class="bg-white text-blue-800 px-8 py-3 rounded-lg font-bold hover:bg-blue-50 transition-colors inline-block">
            Explorar Propriedades
        </a>
    </div>
</section>
@endsection

@push('scripts')
<script src="{{ asset('js/search.js') }}"></script>
@endpush
