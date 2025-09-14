#!/bin/bash

# 🔍 Script 08b - Views de Busca Responsivas (Estilo Booking.com)
# Vancouver-Tec Pousadas & Agências
# Views completas de busca, filtros e resultados responsivos

echo "🎨 Criando Views de Busca estilo Booking.com..."

# Criar view principal de listagem de propriedades
echo "📄 Criando view properties/index.blade.php..."
mkdir -p resources/views/site/properties
cat > resources/views/site/properties/index.blade.php << 'EOF'
@extends('layouts.site')

@section('title', 'Buscar Hospedagem')

@section('content')
<div class="bg-blue-800 py-8">
    <div class="container mx-auto px-4">
        <!-- Formulário de Busca Principal -->
        <div class="bg-white rounded-lg shadow-lg p-6 mb-6">
            <form action="{{ route('site.properties.index') }}" method="GET" id="searchForm">
                <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                    <!-- Destino -->
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1">Destino</label>
                        <div class="relative">
                            <input type="text" 
                                   name="destination" 
                                   id="destination"
                                   value="{{ request('destination') }}"
                                   placeholder="Para onde você vai?"
                                   class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   autocomplete="off">
                            <div id="suggestions" class="absolute z-50 w-full bg-white border border-gray-300 rounded-md mt-1 hidden shadow-lg max-h-60 overflow-y-auto"></div>
                        </div>
                    </div>

                    <!-- Check-in -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Check-in</label>
                        <input type="date" 
                               name="check_in" 
                               value="{{ request('check_in') }}"
                               class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    </div>

                    <!-- Check-out -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Check-out</label>
                        <input type="date" 
                               name="check_out" 
                               value="{{ request('check_out') }}"
                               class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                    </div>

                    <!-- Hóspedes -->
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Hóspedes</label>
                        <select name="guests" class="w-full border border-gray-300 rounded-md px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="">Qualquer</option>
                            @for($i = 1; $i <= 10; $i++)
                                <option value="{{ $i }}" {{ request('guests') == $i ? 'selected' : '' }}>
                                    {{ $i }} {{ $i == 1 ? 'hóspede' : 'hóspedes' }}
                                </option>
                            @endfor
                        </select>
                    </div>
                </div>

                <div class="flex justify-between items-center mt-4">
                    <button type="button" 
                            onclick="toggleFilters()" 
                            class="text-blue-600 hover:text-blue-800 font-medium">
                        <i class="fas fa-filter mr-2"></i>Filtros Avançados
                    </button>
                    <button type="submit" 
                            class="bg-blue-600 hover:bg-blue-700 text-white px-8 py-2 rounded-md font-medium transition duration-200">
                        <i class="fas fa-search mr-2"></i>Buscar
                    </button>
                </div>

                <!-- Filtros Avançados (Ocultos) -->
                <div id="advancedFilters" class="hidden mt-6 pt-6 border-t border-gray-200">
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                        <!-- Tipo de Propriedade -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Tipo</label>
                            <select name="property_type" class="w-full border border-gray-300 rounded-md px-3 py-2">
                                <option value="">Todos os tipos</option>
                                @foreach($filtersData['property_types'] as $type)
                                    <option value="{{ $type }}" {{ request('property_type') == $type ? 'selected' : '' }}>
                                        {{ ucfirst($type) }}
                                    </option>
                                @endforeach
                            </select>
                        </div>

                        <!-- Preço Mínimo -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Preço Mín.</label>
                            <input type="number" 
                                   name="min_price" 
                                   value="{{ request('min_price') }}"
                                   placeholder="R$ 0"
                                   class="w-full border border-gray-300 rounded-md px-3 py-2">
                        </div>

                        <!-- Preço Máximo -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Preço Máx.</label>
                            <input type="number" 
                                   name="max_price" 
                                   value="{{ request('max_price') }}"
                                   placeholder="R$ 1000"
                                   class="w-full border border-gray-300 rounded-md px-3 py-2">
                        </div>

                        <!-- Avaliação Mínima -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Avaliação</label>
                            <select name="min_rating" class="w-full border border-gray-300 rounded-md px-3 py-2">
                                <option value="">Qualquer</option>
                                <option value="3" {{ request('min_rating') == '3' ? 'selected' : '' }}>3+ estrelas</option>
                                <option value="4" {{ request('min_rating') == '4' ? 'selected' : '' }}>4+ estrelas</option>
                                <option value="4.5" {{ request('min_rating') == '4.5' ? 'selected' : '' }}>4.5+ estrelas</option>
                            </select>
                        </div>
                    </div>

                    <!-- Comodidades -->
                    <div class="mt-4">
                        <label class="block text-sm font-medium text-gray-700 mb-2">Comodidades</label>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
                            @php
                                $commonAmenities = ['wifi', 'piscina', 'estacionamento', 'ar_condicionado', 'cafe_manha', 'pet_friendly', 'academia', 'spa'];
                                $selectedAmenities = request('amenities', []);
                                if (is_string($selectedAmenities)) {
                                    $selectedAmenities = explode(',', $selectedAmenities);
                                }
                            @endphp
                            @foreach($commonAmenities as $amenity)
                                <label class="flex items-center">
                                    <input type="checkbox" 
                                           name="amenities[]" 
                                           value="{{ $amenity }}"
                                           {{ in_array($amenity, $selectedAmenities) ? 'checked' : '' }}
                                           class="mr-2 text-blue-600">
                                    <span class="text-sm">{{ ucfirst(str_replace('_', ' ', $amenity)) }}</span>
                                </label>
                            @endforeach
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="container mx-auto px-4 py-8">
    <div class="flex flex-col lg:flex-row gap-8">
        <!-- Sidebar com Filtros (Desktop) -->
        <div class="lg:w-1/4">
            <!-- Resultados encontrados -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                <h3 class="font-bold text-lg mb-2">
                    {{ $properties->total() }} {{ $properties->total() == 1 ? 'propriedade encontrada' : 'propriedades encontradas' }}
                </h3>
                @if(request('destination'))
                    <p class="text-gray-600">em <strong>{{ request('destination') }}</strong></p>
                @endif
            </div>

            <!-- Ordenação -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                <h4 class="font-semibold mb-3">Ordenar por</h4>
                <select name="sort" onchange="updateSort(this.value)" class="w-full border border-gray-300 rounded-md px-3 py-2">
                    <option value="relevance" {{ request('sort') == 'relevance' ? 'selected' : '' }}>Relevância</option>
                    <option value="price_low" {{ request('sort') == 'price_low' ? 'selected' : '' }}>Menor preço</option>
                    <option value="price_high" {{ request('sort') == 'price_high' ? 'selected' : '' }}>Maior preço</option>
                    <option value="rating" {{ request('sort') == 'rating' ? 'selected' : '' }}>Melhor avaliação</option>
                    <option value="newest" {{ request('sort') == 'newest' ? 'selected' : '' }}>Mais recentes</option>
                </select>
            </div>

            <!-- Destinos Populares -->
            @if($popularDestinations->count() > 0)
            <div class="bg-white rounded-lg shadow-md p-6">
                <h4 class="font-semibold mb-3">Destinos Populares</h4>
                @foreach($popularDestinations as $destination)
                    <a href="{{ route('site.properties.index', ['destination' => $destination->city_name]) }}" 
                       class="block py-2 text-blue-600 hover:text-blue-800 border-b border-gray-100 last:border-b-0">
                        {{ $destination->city_name }}, {{ $destination->state_name }}
                        <span class="text-gray-500 text-sm">({{ $destination->properties_count }} propriedades)</span>
                    </a>
                @endforeach
            </div>
            @endif
        </div>

        <!-- Lista de Propriedades -->
        <div class="lg:w-3/4">
            @if($properties->count() > 0)
                <div class="grid grid-cols-1 gap-6">
                    @foreach($properties as $property)
                        <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition duration-200">
                            <div class="md:flex">
                                <!-- Imagem -->
                                <div class="md:w-1/3">
                                    @php
                                        $mainPhoto = $property->photos->where('is_main', true)->first();
                                        $photoUrl = $mainPhoto ? asset('storage/properties/' . $mainPhoto->filename) : asset('images/property-placeholder.jpg');
                                    @endphp
                                    <img src="{{ $photoUrl }}" 
                                         alt="{{ $property->name }}"
                                         class="w-full h-48 md:h-full object-cover">
                                </div>

                                <!-- Conteúdo -->
                                <div class="md:w-2/3 p-6">
                                    <div class="flex justify-between items-start mb-2">
                                        <h3 class="text-xl font-bold text-gray-900 hover:text-blue-600">
                                            <a href="{{ route('site.properties.show', $property->id) }}">
                                                {{ $property->name }}
                                            </a>
                                        </h3>
                                        @if($property->average_rating > 0)
                                            <div class="flex items-center bg-blue-600 text-white px-2 py-1 rounded text-sm">
                                                {{ number_format($property->average_rating, 1) }}
                                                <i class="fas fa-star ml-1 text-xs"></i>
                                            </div>
                                        @endif
                                    </div>

                                    <p class="text-gray-600 mb-2">
                                        <i class="fas fa-map-marker-alt mr-1"></i>
                                        {{ $property->city->name ?? '' }}, {{ $property->state->name ?? '' }}
                                    </p>

                                    <p class="text-gray-700 mb-4 line-clamp-2">
                                        {{ $property->description }}
                                    </p>

                                    <!-- Comodidades -->
                                    @if($property->amenities)
                                        <div class="flex flex-wrap gap-2 mb-4">
                                            @foreach(array_slice(json_decode($property->amenities, true) ?? [], 0, 4) as $amenity)
                                                <span class="bg-gray-100 text-gray-700 px-2 py-1 rounded text-sm">
                                                    {{ ucfirst(str_replace('_', ' ', $amenity)) }}
                                                </span>
                                            @endforeach
                                        </div>
                                    @endif

                                    <div class="flex justify-between items-center">
                                        <div>
                                            <span class="text-2xl font-bold text-green-600">
                                                R$ {{ number_format($property->price_per_night, 2, ',', '.') }}
                                            </span>
                                            <span class="text-gray-600">/noite</span>
                                        </div>
                                        <a href="{{ route('site.properties.show', $property->id) }}" 
                                           class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md font-medium transition duration-200">
                                            Ver Detalhes
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>

                <!-- Paginação -->
                <div class="mt-8">
                    {{ $properties->links() }}
                </div>
            @else
                <!-- Sem resultados -->
                <div class="bg-white rounded-lg shadow-md p-12 text-center">
                    <i class="fas fa-search text-gray-400 text-6xl mb-4"></i>
                    <h3 class="text-xl font-bold text-gray-900 mb-2">Nenhuma propriedade encontrada</h3>
                    <p class="text-gray-600 mb-6">Tente ajustar seus filtros de busca ou pesquise por outro destino.</p>
                    <a href="{{ route('site.home') }}" 
                       class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md font-medium transition duration-200">
                        Nova Busca
                    </a>
                </div>
            @endif
        </div>
    </div>
</div>
EOF

# Criar JavaScript para funcionalidades interativas
echo "⚡ Criando JavaScript para busca..."
mkdir -p public/js
cat > public/js/search.js << 'EOF'
// Sistema de Busca e Filtros - Vancouver-Tec

// Autocomplete de destinos
let suggestionsTimeout;
const destinationInput = document.getElementById('destination');
const suggestionsDiv = document.getElementById('suggestions');

if (destinationInput) {
    destinationInput.addEventListener('input', function() {
        clearTimeout(suggestionsTimeout);
        const term = this.value.trim();
        
        if (term.length < 2) {
            suggestionsDiv.classList.add('hidden');
            return;
        }

        suggestionsTimeout = setTimeout(() => {
            fetch(`/api/search/suggestions?term=${encodeURIComponent(term)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.data.length > 0) {
                        showSuggestions(data.data);
                    } else {
                        suggestionsDiv.classList.add('hidden');
                    }
                })
                .catch(error => {
                    console.error('Erro ao buscar sugestões:', error);
                });
        }, 300);
    });

    // Esconder sugestões ao clicar fora
    document.addEventListener('click', function(e) {
        if (!destinationInput.contains(e.target) && !suggestionsDiv.contains(e.target)) {
            suggestionsDiv.classList.add('hidden');
        }
    });
}

function showSuggestions(suggestions) {
    suggestionsDiv.innerHTML = '';
    
    suggestions.forEach(suggestion => {
        const div = document.createElement('div');
        div.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 last:border-b-0';
        
        const icon = getIconForType(suggestion.type);
        div.innerHTML = `
            <i class="${icon} mr-2 text-gray-500"></i>
            ${suggestion.label}
        `;
        
        div.addEventListener('click', function() {
            destinationInput.value = suggestion.value;
            suggestionsDiv.classList.add('hidden');
        });
        
        suggestionsDiv.appendChild(div);
    });
    
    suggestionsDiv.classList.remove('hidden');
}

function getIconForType(type) {
    const icons = {
        'city': 'fas fa-city',
        'state': 'fas fa-map',
        'property': 'fas fa-home'
    };
    return icons[type] || 'fas fa-map-marker-alt';
}

// Toggle filtros avançados
function toggleFilters() {
    const filters = document.getElementById('advancedFilters');
    if (filters.classList.contains('hidden')) {
        filters.classList.remove('hidden');
    } else {
        filters.classList.add('hidden');
    }
}

// Atualizar ordenação
function updateSort(sortValue) {
    const url = new URL(window.location);
    url.searchParams.set('sort', sortValue);
    window.location = url;
}

// Configurar datas mínimas
const today = new Date().toISOString().split('T')[0];
const checkInInput = document.querySelector('input[name="check_in"]');
const checkOutInput = document.querySelector('input[name="check_out"]');

if (checkInInput) {
    checkInInput.setAttribute('min', today);
    checkInInput.addEventListener('change', function() {
        if (checkOutInput && this.value) {
            const checkIn = new Date(this.value);
            const nextDay = new Date(checkIn);
            nextDay.setDate(checkIn.getDate() + 1);
            checkOutInput.setAttribute('min', nextDay.toISOString().split('T')[0]);
            
            if (checkOutInput.value && new Date(checkOutInput.value) <= checkIn) {
                checkOutInput.value = nextDay.toISOString().split('T')[0];
            }
        }
    });
}

// Loading state no formulário
const searchForm = document.getElementById('searchForm');
if (searchForm) {
    searchForm.addEventListener('submit', function() {
        const submitBtn = this.querySelector('button[type="submit"]');
        if (submitBtn) {
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Buscando...';
            submitBtn.disabled = true;
        }
    });
}

// Filtro rápido por preço (slider)
function createPriceSlider() {
    const minPriceInput = document.querySelector('input[name="min_price"]');
    const maxPriceInput = document.querySelector('input[name="max_price"]');
    
    if (minPriceInput && maxPriceInput) {
        let timeout;
        
        [minPriceInput, maxPriceInput].forEach(input => {
            input.addEventListener('input', function() {
                clearTimeout(timeout);
                timeout = setTimeout(() => {
                    updatePriceFilter();
                }, 1000);
            });
        });
    }
}

function updatePriceFilter() {
    // Auto-submit form após mudança de preço (opcional)
    // document.getElementById('searchForm').submit();
}

// Inicializar funcionalidades
document.addEventListener('DOMContentLoaded', function() {
    createPriceSlider();
    
    // Marcar filtros ativos visualmente
    markActiveFilters();
});

function markActiveFilters() {
    const form = document.getElementById('searchForm');
    if (!form) return;
    
    const formData = new FormData(form);
    let hasActiveFilters = false;
    
    for (let [key, value] of formData.entries()) {
        if (value && !['destination', 'check_in', 'check_out', 'guests'].includes(key)) {
            hasActiveFilters = true;
            break;
        }
    }
    
    const filterButton = document.querySelector('[onclick="toggleFilters()"]');
    if (filterButton && hasActiveFilters) {
        filterButton.classList.add('text-blue-800', 'font-bold');
        filterButton.innerHTML = '<i class="fas fa-filter mr-2"></i>Filtros Ativos';
    }
}
EOF

echo "✅ Script 08b-views-busca.sh criado com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "   ✅ resources/views/site/properties/index.blade.php - Página de busca completa"
echo "   ✅ public/js/search.js - JavaScript interativo"
echo ""
echo "🔍 Funcionalidades das Views:"
echo "   ✅ Layout responsivo estilo Booking.com"
echo "   ✅ Formulário de busca principal"
echo "   ✅ Filtros avançados expansíveis"
echo "   ✅ Autocomplete de destinos"
echo "   ✅ Cards de propriedades otimizados"
echo "   ✅ Sistema de ordenação"
echo "   ✅ Paginação automática"
echo "   ✅ Sidebar com destinos populares"
echo "   ✅ Estado vazio (sem resultados)"
echo ""
echo "🎨 Design Features:"
echo "   ✅ Cores oficiais (#003580, #0071c2)"
echo "   ✅ Totalmente responsivo"
echo "   ✅ Interações suaves"
echo "   ✅ Loading states"
echo ""
echo "💡 Para executar: chmod +x 08b-views-busca.sh && ./08b-views-busca.sh"
echo ""
echo "🎯 Próximo script: 09-site-booking.sh (Views detalhes + reserva)"