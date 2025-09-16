#!/bin/bash

# 🔍 Script 08 - Sistema de Busca Completo (Correção de Erros)
# Vancouver-Tec Pousadas & Agências
# Corrige erros de views, controllers e implementa busca funcional

echo "🔍 Iniciando correção e implementação do Sistema de Busca..."

# 1. Corrigir PropertiesController (estava com nome errado)
echo "🏠 Criando PropertiesController corrigido..."
cat > app/Http/Controllers/Site/PropertiesController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PropertiesController extends Controller
{
    public function index(Request $request)
    {
        try {
            // Construir query base
            $query = Property::where('active', true)
                           ->with(['reviews']);

            // Filtro por destino
            if ($request->filled('destination')) {
                $destination = $request->destination;
                $query->where(function($q) use ($destination) {
                    $q->where('name', 'LIKE', "%{$destination}%")
                      ->orWhere('city', 'LIKE', "%{$destination}%")
                      ->orWhere('state', 'LIKE', "%{$destination}%")
                      ->orWhere('address', 'LIKE', "%{$destination}%");
                });
            }

            // Filtro por número de hóspedes
            if ($request->filled('guests')) {
                $query->where('max_guests', '>=', $request->guests);
            }

            // Filtro por tipo de propriedade
            if ($request->filled('property_type') && $request->property_type != 'all') {
                $query->where('type', $request->property_type);
            }

            // Filtro por preço
            if ($request->filled('min_price')) {
                $query->where('price_per_night', '>=', $request->min_price);
            }
            if ($request->filled('max_price')) {
                $query->where('price_per_night', '<=', $request->max_price);
            }

            // Filtro por avaliação
            if ($request->filled('min_rating')) {
                $query->where(function($q) use ($request) {
                    $q->where('average_rating', '>=', $request->min_rating)
                      ->orWhere('rating', '>=', $request->min_rating);
                });
            }

            // Verificar disponibilidade por datas
            if ($request->filled('check_in') && $request->filled('check_out')) {
                $checkIn = $request->check_in;
                $checkOut = $request->check_out;
                
                $query->whereDoesntHave('bookings', function($bookingQuery) use ($checkIn, $checkOut) {
                    $bookingQuery->where('status', '!=', 'cancelled')
                                ->where(function($dateQuery) use ($checkIn, $checkOut) {
                                    $dateQuery->whereBetween('check_in', [$checkIn, $checkOut])
                                             ->orWhereBetween('check_out', [$checkIn, $checkOut])
                                             ->orWhere(function($overlapQuery) use ($checkIn, $checkOut) {
                                                 $overlapQuery->where('check_in', '<=', $checkIn)
                                                             ->where('check_out', '>=', $checkOut);
                                             });
                                });
                });
            }

            // Ordenação
            $sortBy = $request->get('sort', 'relevance');
            switch ($sortBy) {
                case 'price_low':
                    $query->orderBy('price_per_night', 'asc');
                    break;
                case 'price_high':
                    $query->orderBy('price_per_night', 'desc');
                    break;
                case 'rating':
                    $query->orderByRaw('COALESCE(average_rating, rating) DESC');
                    break;
                case 'newest':
                    $query->orderBy('created_at', 'desc');
                    break;
                default: // relevance
                    $query->orderBy('featured', 'desc')
                          ->orderByRaw('COALESCE(average_rating, rating) DESC');
            }

            // Executar busca
            $properties = $query->paginate(12)->withQueryString();

            // Dados para filtros
            $filterData = $this->getFilterData();

            return view('site.properties.index', compact('properties', 'filterData', 'request'));

        } catch (\Exception $e) {
            Log::error('Erro na busca de propriedades: ' . $e->getMessage());
            
            return view('site.properties.index', [
                'properties' => collect(),
                'filterData' => $this->getFilterData(),
                'request' => $request,
                'error' => 'Erro ao carregar propriedades. Tente novamente.'
            ]);
        }
    }

    public function show($id)
    {
        try {
            $property = Property::where('active', true)
                              ->with(['reviews.user'])
                              ->findOrFail($id);

            // Propriedades relacionadas
            $relatedProperties = Property::where('id', '!=', $id)
                                       ->where('active', true)
                                       ->where('city', $property->city)
                                       ->limit(4)
                                       ->get();

            return view('site.properties.show', compact('property', 'relatedProperties'));

        } catch (\Exception $e) {
            Log::error('Erro ao mostrar propriedade: ' . $e->getMessage());
            return redirect()->route('site.properties.index')
                           ->with('error', 'Propriedade não encontrada.');
        }
    }

    public function suggestions(Request $request)
    {
        $term = $request->get('term');
        
        if (strlen($term) < 2) {
            return response()->json([]);
        }

        try {
            $suggestions = collect();

            // Buscar cidades
            $cities = Property::select('city', 'state')
                            ->where('active', true)
                            ->where('city', 'LIKE', "%{$term}%")
                            ->groupBy('city', 'state')
                            ->limit(5)
                            ->get();

            foreach ($cities as $city) {
                $suggestions->push([
                    'type' => 'city',
                    'label' => $city->city . ', ' . $city->state,
                    'value' => $city->city
                ]);
            }

            // Buscar propriedades
            $properties = Property::where('active', true)
                                ->where('name', 'LIKE', "%{$term}%")
                                ->limit(5)
                                ->get();

            foreach ($properties as $property) {
                $suggestions->push([
                    'type' => 'property',
                    'label' => $property->name,
                    'value' => $property->name
                ]);
            }

            return response()->json($suggestions->take(10)->values());

        } catch (\Exception $e) {
            Log::error('Erro nas sugestões: ' . $e->getMessage());
            return response()->json([]);
        }
    }

    private function getFilterData()
    {
        try {
            return [
                'types' => [
                    'hotel' => 'Hotel',
                    'pousada' => 'Pousada',
                    'resort' => 'Resort',
                    'apartment' => 'Apartamento',
                    'house' => 'Casa'
                ],
                'price_range' => [
                    'min' => Property::where('active', true)->min('price_per_night') ?? 50,
                    'max' => Property::where('active', true)->max('price_per_night') ?? 1000
                ],
                'popular_cities' => Property::select('city', 'state')
                                          ->where('active', true)
                                          ->groupBy('city', 'state')
                                          ->orderByRaw('COUNT(*) DESC')
                                          ->limit(6)
                                          ->get()
            ];
        } catch (\Exception $e) {
            return [
                'types' => [],
                'price_range' => ['min' => 50, 'max' => 1000],
                'popular_cities' => collect()
            ];
        }
    }
}
EOF

# 2. Criar view de listagem de propriedades
echo "📱 Criando view de listagem de propriedades..."
mkdir -p resources/views/site/properties
cat > resources/views/site/properties/index.blade.php << 'EOF'
@extends('layouts.site')

@section('title', 'Propriedades - Vancouver-Tec')

@section('content')
<div class="bg-gray-50 min-h-screen">
    <!-- Header de Busca -->
    <div class="booking-blue text-white py-8">
        <div class="container mx-auto px-4">
            <!-- Formulário de Busca Compacto -->
            <form method="GET" action="{{ route('site.properties.index') }}" 
                  class="bg-white rounded-lg shadow-lg p-4 text-gray-900">
                <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
                    <!-- Destino -->
                    <div class="relative">
                        <label class="block text-sm font-medium mb-1">
                            <i class="fas fa-map-marker-alt mr-1"></i>Destino
                        </label>
                        <input type="text" name="destination" id="destination"
                               value="{{ request('destination') }}"
                               class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                               placeholder="Cidade, propriedade..."
                               autocomplete="off">
                        <div id="suggestions" class="absolute z-20 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden"></div>
                    </div>

                    <!-- Check-in -->
                    <div>
                        <label class="block text-sm font-medium mb-1">
                            <i class="fas fa-calendar mr-1"></i>Check-in
                        </label>
                        <input type="date" name="check_in" value="{{ request('check_in') }}"
                               class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                               min="{{ date('Y-m-d') }}">
                    </div>

                    <!-- Check-out -->
                    <div>
                        <label class="block text-sm font-medium mb-1">
                            <i class="fas fa-calendar mr-1"></i>Check-out
                        </label>
                        <input type="date" name="check_out" value="{{ request('check_out') }}"
                               class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500"
                               min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                    </div>

                    <!-- Hóspedes -->
                    <div>
                        <label class="block text-sm font-medium mb-1">
                            <i class="fas fa-users mr-1"></i>Hóspedes
                        </label>
                        <select name="guests" class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500">
                            <option value="">Qualquer</option>
                            @for($i = 1; $i <= 10; $i++)
                                <option value="{{ $i }}" {{ request('guests') == $i ? 'selected' : '' }}>
                                    {{ $i }} {{ $i == 1 ? 'hóspede' : 'hóspedes' }}
                                </option>
                            @endfor
                        </select>
                    </div>

                    <!-- Botão Buscar -->
                    <div class="flex items-end">
                        <button type="submit" 
                                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-lg transition-colors">
                            <i class="fas fa-search mr-2"></i>Buscar
                        </button>
                    </div>
                </div>

                <!-- Filtros Avançados -->
                <div class="mt-4 pt-4 border-t border-gray-200">
                    <button type="button" onclick="toggleFilters()" 
                            class="text-blue-600 hover:text-blue-800 font-medium">
                        <i class="fas fa-filter mr-2"></i>Filtros Avançados
                    </button>
                    
                    <div id="advancedFilters" class="hidden mt-4 grid grid-cols-1 md:grid-cols-4 gap-4">
                        <!-- Tipo de Propriedade -->
                        <div>
                            <label class="block text-sm font-medium mb-1">Tipo</label>
                            <select name="property_type" class="w-full border border-gray-300 rounded-lg px-3 py-2">
                                <option value="">Todos os tipos</option>
                                @if(isset($filterData['types']))
                                    @foreach($filterData['types'] as $key => $type)
                                        <option value="{{ $key }}" {{ request('property_type') == $key ? 'selected' : '' }}>
                                            {{ $type }}
                                        </option>
                                    @endforeach
                                @endif
                            </select>
                        </div>

                        <!-- Preço Mínimo -->
                        <div>
                            <label class="block text-sm font-medium mb-1">Preço Mín.</label>
                            <input type="number" name="min_price" value="{{ request('min_price') }}"
                                   class="w-full border border-gray-300 rounded-lg px-3 py-2"
                                   placeholder="R$ 0">
                        </div>

                        <!-- Preço Máximo -->
                        <div>
                            <label class="block text-sm font-medium mb-1">Preço Máx.</label>
                            <input type="number" name="max_price" value="{{ request('max_price') }}"
                                   class="w-full border border-gray-300 rounded-lg px-3 py-2"
                                   placeholder="R$ 1000">
                        </div>

                        <!-- Avaliação -->
                        <div>
                            <label class="block text-sm font-medium mb-1">Avaliação Mín.</label>
                            <select name="min_rating" class="w-full border border-gray-300 rounded-lg px-3 py-2">
                                <option value="">Qualquer</option>
                                <option value="3" {{ request('min_rating') == '3' ? 'selected' : '' }}>3+ estrelas</option>
                                <option value="4" {{ request('min_rating') == '4' ? 'selected' : '' }}>4+ estrelas</option>
                                <option value="4.5" {{ request('min_rating') == '4.5' ? 'selected' : '' }}>4.5+ estrelas</option>
                            </select>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div class="container mx-auto px-4 py-8">
        <div class="flex flex-col lg:flex-row gap-8">
            <!-- Sidebar com Destinos Populares -->
            <div class="lg:w-1/4">
                <div class="bg-white rounded-lg shadow-md p-6 mb-6">
                    <h3 class="text-lg font-bold mb-4">Destinos Populares</h3>
                    @if(isset($filterData['popular_cities']) && $filterData['popular_cities']->count() > 0)
                        @foreach($filterData['popular_cities'] as $city)
                            <a href="{{ route('site.properties.index', ['destination' => $city->city]) }}" 
                               class="block py-2 px-3 hover:bg-gray-100 rounded-lg text-gray-700 hover:text-blue-600 transition">
                                <i class="fas fa-map-marker-alt mr-2 text-blue-500"></i>
                                {{ $city->city }}, {{ $city->state }}
                            </a>
                        @endforeach
                    @endif
                </div>
            </div>

            <!-- Lista de Propriedades -->
            <div class="lg:w-3/4">
                <!-- Header com Resultados -->
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-900">
                            @if(request('destination'))
                                Propriedades em {{ request('destination') }}
                            @else
                                Todas as Propriedades
                            @endif
                        </h1>
                        @if(isset($properties) && $properties->total() > 0)
                            <p class="text-gray-600">{{ $properties->total() }} propriedades encontradas</p>
                        @endif
                    </div>

                    <!-- Ordenação -->
                    <div>
                        <select onchange="updateSort(this.value)" 
                                class="border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500">
                            <option value="relevance" {{ request('sort') == 'relevance' ? 'selected' : '' }}>Relevância</option>
                            <option value="price_low" {{ request('sort') == 'price_low' ? 'selected' : '' }}>Menor Preço</option>
                            <option value="price_high" {{ request('sort') == 'price_high' ? 'selected' : '' }}>Maior Preço</option>
                            <option value="rating" {{ request('sort') == 'rating' ? 'selected' : '' }}>Melhor Avaliação</option>
                            <option value="newest" {{ request('sort') == 'newest' ? 'selected' : '' }}>Mais Recente</option>
                        </select>
                    </div>
                </div>

                <!-- Grid de Propriedades -->
                @if(isset($properties) && $properties->count() > 0)
                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 mb-8">
                        @foreach($properties as $property)
                            <div class="bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow">
                                <!-- Imagem -->
                                <div class="relative h-48 overflow-hidden">
                                    @if($property->images && is_array(json_decode($property->images, true)) && count(json_decode($property->images, true)) > 0)
                                        @php
                                            $images = json_decode($property->images, true);
                                        @endphp
                                        <img src="{{ asset('storage/' . $images[0]) }}" 
                                             alt="{{ $property->name }}"
                                             class="w-full h-full object-cover hover:scale-105 transition-transform duration-300">
                                    @else
                                        <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                            <i class="fas fa-image text-gray-400 text-3xl"></i>
                                        </div>
                                    @endif
                                    
                                    <!-- Badge de Avaliação -->
                                    <div class="absolute top-3 right-3">
                                        <span class="bg-blue-600 text-white px-2 py-1 rounded text-sm font-bold">
                                            <i class="fas fa-star mr-1"></i>
                                            {{ number_format($property->average_rating ?: $property->rating, 1) }}
                                        </span>
                                    </div>
                                </div>

                                <!-- Conteúdo -->
                                <div class="p-4">
                                    <h3 class="font-bold text-lg text-gray-900 mb-2 truncate">{{ $property->name }}</h3>
                                    <p class="text-gray-600 text-sm mb-2 flex items-center">
                                        <i class="fas fa-map-marker-alt mr-2"></i>
                                        {{ $property->city }}, {{ $property->state }}
                                    </p>
                                    
                                    <!-- Informações -->
                                    <div class="flex items-center text-gray-600 text-sm space-x-4 mb-3">
                                        <span><i class="fas fa-users mr-1"></i>{{ $property->max_guests }}</span>
                                        <span><i class="fas fa-bed mr-1"></i>{{ $property->bedrooms }}</span>
                                        <span><i class="fas fa-bath mr-1"></i>{{ $property->bathrooms }}</span>
                                    </div>

                                    <!-- Preço e Botão -->
                                    <div class="flex items-center justify-between">
                                        <div>
                                            <span class="text-2xl font-bold text-gray-900">
                                                R$ {{ number_format($property->price_per_night, 0, ',', '.') }}
                                            </span>
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

                    <!-- Paginação -->
                    <div class="flex justify-center">
                        {{ $properties->appends(request()->query())->links() }}
                    </div>
                @else
                    <!-- Estado Vazio -->
                    <div class="text-center py-16">
                        <i class="fas fa-search text-4xl text-gray-400 mb-4"></i>
                        <h3 class="text-xl font-bold text-gray-900 mb-2">Nenhuma propriedade encontrada</h3>
                        <p class="text-gray-600 mb-6">
                            @if(request()->hasAny(['destination', 'check_in', 'check_out', 'guests', 'property_type', 'min_price', 'max_price']))
                                Tente ajustar seus filtros de busca.
                            @else
                                Nenhuma propriedade disponível no momento.
                            @endif
                        </p>
                        <a href="{{ route('site.properties.index') }}" 
                           class="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition">
                            Limpar Filtros
                        </a>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<script>
function toggleFilters() {
    const filters = document.getElementById('advancedFilters');
    filters.classList.toggle('hidden');
}

function updateSort(value) {
    const url = new URL(window.location);
    url.searchParams.set('sort', value);
    window.location = url;
}

// Autocomplete
let timeout;
document.getElementById('destination').addEventListener('input', function() {
    clearTimeout(timeout);
    const term = this.value.trim();
    
    if (term.length < 2) {
        document.getElementById('suggestions').classList.add('hidden');
        return;
    }
    
    timeout = setTimeout(() => {
        fetch(`{{ route('site.search.suggestions') }}?term=${encodeURIComponent(term)}`)
            .then(response => response.json())
            .then(data => {
                const suggestions = document.getElementById('suggestions');
                suggestions.innerHTML = '';
                
                if (data.length > 0) {
                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer';
                        div.innerHTML = `<i class="fas fa-${item.type === 'city' ? 'city' : 'home'} mr-2"></i>${item.label}`;
                        div.onclick = () => {
                            document.getElementById('destination').value = item.value;
                            suggestions.classList.add('hidden');
                        };
                        suggestions.appendChild(div);
                    });
                    suggestions.classList.remove('hidden');
                } else {
                    suggestions.classList.add('hidden');
                }
            })
            .catch(() => {
                document.getElementById('suggestions').classList.add('hidden');
            });
    }, 300);
});

// Fechar sugestões ao clicar fora
document.addEventListener('click', function(e) {
    if (!e.target.closest('#destination') && !e.target.closest('#suggestions')) {
        document.getElementById('suggestions').classList.add('hidden');
    }
});
</script>
@endsection
EOF

# 3. Corrigir rotas web.php
echo "🛣️ Corrigindo e adicionando rotas..."
cat >> routes/web.php << 'EOF'

// Rotas de busca e sugestões
Route::get('/search/suggestions', [App\Http\Controllers\Site\PropertiesController::class, 'suggestions'])->name('site.search.suggestions');
EOF

echo "✅ Script 08-sistema-busca.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ PropertiesController corrigido com tratamento robusto de erros"
echo "   ✅ View de listagem completa e responsiva"  
echo "   ✅ Sistema de busca funcional com filtros"
echo "   ✅ Autocomplete de sugestões"
echo "   ✅ Tratamento de propriedades sem imagens"
echo "   ✅ Paginação com parâmetros preservados"
echo ""
echo "🎯 Funcionalidades:"
echo "   ✅ Busca por destino, datas, hóspedes"
echo "   ✅ Filtros avançados (tipo, preço, avaliação)"
echo "   ✅ Múltiplas opções de ordenação"
echo "   ✅ Sidebar com destinos populares"  
echo "   ✅ Cards responsivos estilo Booking.com"
echo "   ✅ Estado vazio quando sem resultados"
echo ""
echo "💡 Para executar: chmod +x 08d-sistema-busca.sh && ./08d-sistema-busca.sh"