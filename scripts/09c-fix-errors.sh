#!/bin/bash

# 🔧 Script 09c - Correção de Erros e Melhorias (Vancouver-Tec)
# Corrige erro de relacionamentos, melhora contraste e adiciona seções

echo "🔧 Iniciando correções de erros e melhorias..."

# 1. Corrigir Models com relacionamentos adequados
echo "📝 Corrigindo Models com relacionamentos..."

# Atualizar Model Property com relacionamentos corretos
cat > app/Models/Property.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Property extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'description', 'type', 'property_type', 'address',
        'city', 'state', 'country', 'zip_code', 'latitude', 'longitude',
        'price_per_night', 'max_guests', 'bedrooms', 'bathrooms',
        'amenities', 'rating', 'average_rating', 'reviews_count',
        'active', 'featured', 'instant_book'
    ];

    protected $casts = [
        'amenities' => 'array',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'price_per_night' => 'decimal:2',
        'rating' => 'decimal:2',
        'average_rating' => 'decimal:2',
        'active' => 'boolean',
        'featured' => 'boolean',
        'instant_book' => 'boolean'
    ];

    // Relacionamentos
    public function photos(): HasMany
    {
        return $this->hasMany(PropertyPhoto::class)->orderBy('sort_order');
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class)->where('is_public', true);
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('active', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('featured', true);
    }

    public function scopeAvailable($query, $checkIn, $checkOut)
    {
        return $query->whereDoesntHave('bookings', function($bookingQuery) use ($checkIn, $checkOut) {
            $bookingQuery->where('status', '!=', 'cancelled')
                        ->where(function($dateQuery) use ($checkIn, $checkOut) {
                            $dateQuery->whereBetween('check_in', [$checkIn, $checkOut])
                                     ->orWhereBetween('check_out', [$checkIn, $checkOut]);
                        });
        });
    }

    // Accessors - Tratamento seguro de dados
    public function getMainPhotoAttribute()
    {
        $photo = $this->photos()->where('is_primary', true)->first();
        return $photo ? $photo->filename : 'property-placeholder.svg';
    }

    public function getFormattedPriceAttribute()
    {
        return 'R$ ' . number_format($this->price_per_night, 2, ',', '.');
    }

    public function getCityNameAttribute()
    {
        return $this->city ?? 'Cidade não informada';
    }

    public function getStateNameAttribute()
    {
        return $this->state ?? 'Estado não informado';
    }

    public function getAverageRatingFormatAttribute()
    {
        return number_format($this->average_rating ?: $this->rating ?: 0, 1);
    }
}
EOF

# Criar Model PropertyPhoto se não existir
cat > app/Models/PropertyPhoto.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyPhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'property_id', 'filename', 'original_name', 'alt_text', 'sort_order', 'is_primary'
    ];

    protected $casts = [
        'is_primary' => 'boolean',
        'sort_order' => 'integer'
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function getUrlAttribute()
    {
        return asset('uploads/properties/' . $this->filename);
    }
}
EOF

# 2. Corrigir View Home com contraste adequado e seções
echo "🏠 Corrigindo view home com melhor contraste..."
cat > resources/views/site/home.blade.php << 'EOF'
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
                    <label for="destination" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-map-marker-alt mr-1 text-blue-600"></i>Para onde você vai?
                    </label>
                    <input type="text" 
                           id="destination" 
                           name="destination" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 placeholder-gray-500"
                           placeholder="Cidade, região, propriedade"
                           autocomplete="off">
                    
                    <div id="suggestions" class="absolute z-10 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden search-suggestions"></div>
                </div>

                <!-- Check-in -->
                <div>
                    <label for="check_in" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-in
                    </label>
                    <input type="date" 
                           id="check_in" 
                           name="check_in" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d') }}"
                           min="{{ date('Y-m-d') }}">
                </div>

                <!-- Check-out -->
                <div>
                    <label for="check_out" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-out
                    </label>
                    <input type="date" 
                           id="check_out" 
                           name="check_out" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d', strtotime('+1 day')) }}"
                           min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>

                <!-- Hóspedes e Buscar -->
                <div>
                    <label for="guests" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-users mr-1 text-blue-600"></i>Hóspedes
                    </label>
                    <div class="flex">
                        <select id="guests" 
                                name="guests" 
                                class="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900">
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

<!-- Ofertas Especiais -->
<section class="py-12 bg-yellow-50">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Ofertas Especiais</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Oferta 1 -->
            <div class="bg-gradient-to-r from-orange-500 to-pink-500 rounded-xl p-6 text-white relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-white bg-opacity-20 rounded-full -mr-16 -mt-16"></div>
                <div class="relative z-10">
                    <h3 class="text-2xl font-bold mb-2">Fique 3, Pague 2!</h3>
                    <p class="text-lg opacity-90 mb-4">Economize até 33% em estadias longas</p>
                    <span class="inline-block bg-white text-orange-600 px-4 py-2 rounded-full font-bold">
                        Válido até 31/12
                    </span>
                </div>
            </div>

            <!-- Oferta 2 -->
            <div class="bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl p-6 text-white relative overflow-hidden">
                <div class="absolute top-0 right-0 w-32 h-32 bg-white bg-opacity-20 rounded-full -mr-16 -mt-16"></div>
                <div class="relative z-10">
                    <h3 class="text-2xl font-bold mb-2">Primeira Viagem?</h3>
                    <p class="text-lg opacity-90 mb-4">Ganhe 15% de desconto no cadastro</p>
                    <span class="inline-block bg-white text-blue-600 px-4 py-2 rounded-full font-bold">
                        Código: BEMVINDO15
                    </span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Featured Properties -->
@if($featuredProperties && $featuredProperties->count() > 0)
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
                                <i class="fas fa-star mr-1"></i>{{ $property->average_rating_format }}
                            </span>
                        </div>
                    </div>
                    
                    <div class="p-4">
                        <h3 class="font-bold text-lg text-gray-900 mb-2 truncate">{{ $property->name }}</h3>
                        <p class="text-gray-600 text-sm mb-3 flex items-center">
                            <i class="fas fa-map-marker-alt mr-2 text-blue-600"></i>
                            {{ $property->city_name }}, {{ $property->state_name }}
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

<!-- Pacotes Especiais -->
<section class="py-16 bg-gradient-to-r from-green-50 to-blue-50">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Pacotes Especiais</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Pacote Família -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <div class="bg-gradient-to-r from-purple-500 to-pink-500 p-6 text-white">
                    <i class="fas fa-users text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Família</h3>
                    <p class="opacity-90">Diversão garantida para toda família</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Café da manhã incluso</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Atividades para crianças</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Desconto em atrações locais</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Cancelamento grátis</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 280</span>
                        <p class="text-gray-600 text-sm">por família/noite</p>
                    </div>
                </div>
            </div>

            <!-- Pacote Romântico -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <div class="bg-gradient-to-r from-red-500 to-pink-500 p-6 text-white">
                    <i class="fas fa-heart text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Romântico</h3>
                    <p class="opacity-90">Momentos inesquecíveis a dois</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Jantar romântico</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Spa para casais</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Champagne de cortesia</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Check-out tardio</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 450</span>
                        <p class="text-gray-600 text-sm">por casal/noite</p>
                    </div>
                </div>
            </div>

            <!-- Pacote Aventura -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden">
                <div class="bg-gradient-to-r from-green-500 to-teal-500 p-6 text-white">
                    <i class="fas fa-mountain text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Aventura</h3>
                    <p class="opacity-90">Para os amantes da natureza</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Trilhas guiadas</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Equipamentos inclusos</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Guia especializado</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Seguro aventura</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 320</span>
                        <p class="text-gray-600 text-sm">por pessoa/noite</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Popular Destinations -->
@if($popularDestinations && $popularDestinations->count() > 0)
<section class="py-16 bg-gray-50">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Destinos Populares</h2>
        
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            @foreach($popularDestinations as $destination)
                <a href="{{ route('site.properties.index', ['destination' => $destination->city_name]) }}" 
                   class="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-center group">
                    <i class="fas fa-city text-3xl text-blue-600 mb-3 group-hover:text-blue-700 transition-colors"></i>
                    <h3 class="font-bold text-gray-900 group-hover:text-blue-700">{{ $destination->city_name }}</h3>
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
<script>
// Autocomplete search functionality
document.addEventListener('DOMContentLoaded', function() {
    const destinationInput = document.getElementById('destination');
    const suggestionsDiv = document.getElementById('suggestions');
    
    if (destinationInput) {
        let timeoutId;
        
        destinationInput.addEventListener('input', function() {
            const term = this.value;
            
            clearTimeout(timeoutId);
            
            if (term.length < 2) {
                suggestionsDiv.classList.add('hidden');
                return;
            }
            
            timeoutId = setTimeout(function() {
                fetch(`/search/suggestions?term=${encodeURIComponent(term)}`)
                    .then(response => response.json())
                    .then(data => {
                        suggestionsDiv.innerHTML = '';
                        
                        if (data.length > 0) {
                            data.forEach(item => {
                                const div = document.createElement('div');
                                div.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer text-gray-800';
                                div.innerHTML = `<i class="fas fa-${item.type === 'city' ? 'city' : item.type === 'state' ? 'map' : 'home'} mr-2 text-blue-600"></i>${item.label}`;
                                
                                div.addEventListener('click', function() {
                                    destinationInput.value = item.value;
                                    suggestionsDiv.classList.add('hidden');
                                });
                                
                                suggestionsDiv.appendChild(div);
                            });
                            suggestionsDiv.classList.remove('hidden');
                        } else {
                            suggestionsDiv.classList.add('hidden');
                        }
                    })
                    .catch(error => {
                        console.error('Erro ao buscar sugestões:', error);
                        suggestionsDiv.classList.add('hidden');
                    });
            }, 300);
        });
        
        // Hide suggestions when clicking outside
        document.addEventListener('click', function(e) {
            if (!destinationInput.contains(e.target) && !suggestionsDiv.contains(e.target)) {
                suggestionsDiv.classList.add('hidden');
            }
        });
    }
});
</script>
@endpush
EOF

echo "✅ Script 09c-fix-errors.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ Models corrigidos com accessors seguros"
echo "   ✅ Contraste de texto melhorado (texto preto em fundos claros)"
echo "   ✅ Seção de Ofertas Especiais adicionada"
echo "   ✅ Seção de Pacotes Especiais implementada"
echo "   ✅ Autocomplete de busca funcional"
echo "   ✅ Tratamento de dados nulos para evitar erros"
echo ""
echo "🎨 Melhorias visuais:"
echo "   ✅ Gradientes coloridos para ofertas"
echo "   ✅ Ícones e badges para melhor UX"
echo "   ✅ Layout responsivo otimizado"
echo "   ✅ Cores com alto contraste"
echo ""
echo "💡 Para executar: chmod +x 09c-fix-errors.sh && ./09c-fix-errors.sh"
EOF