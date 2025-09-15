#!/bin/bash

# 🔍 Script 08 - Sistema de Busca Completo (Estilo Booking.com)
# Vancouver-Tec Pousadas & Agências
# Implementa busca avançada, filtros e resultados responsivos

echo "🔍 Iniciando implementação do Sistema de Busca..."

# Criar Service para lógica de busca
echo "📋 Criando SearchService..."
mkdir -p app/Services
cat > app/Services/SearchService.php << 'EOF'
<?php

namespace App\Services;

use App\Models\Property;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

class SearchService
{
    public function search(array $filters)
    {
        $query = Property::with(['photos', 'reviews', 'city', 'state'])
                          ->where('active', true);

        // Filtro por destino (cidade ou estado)
        if (!empty($filters['destination'])) {
            $destination = $filters['destination'];
            $query->where(function($q) use ($destination) {
                $q->whereHas('city', function($cityQuery) use ($destination) {
                    $cityQuery->where('name', 'LIKE', "%{$destination}%");
                })->orWhereHas('state', function($stateQuery) use ($destination) {
                    $stateQuery->where('name', 'LIKE', "%{$destination}%");
                })->orWhere('name', 'LIKE', "%{$destination}%")
                  ->orWhere('address', 'LIKE', "%{$destination}%");
            });
        }

        // Filtro por tipo de propriedade
        if (!empty($filters['property_type'])) {
            $query->where('property_type', $filters['property_type']);
        }

        // Filtro por preço
        if (!empty($filters['min_price'])) {
            $query->where('price_per_night', '>=', $filters['min_price']);
        }
        if (!empty($filters['max_price'])) {
            $query->where('price_per_night', '<=', $filters['max_price']);
        }

        // Filtro por avaliação
        if (!empty($filters['min_rating'])) {
            $query->where('average_rating', '>=', $filters['min_rating']);
        }

        // Filtro por comodidades
        if (!empty($filters['amenities'])) {
            $amenities = is_array($filters['amenities']) ? $filters['amenities'] : explode(',', $filters['amenities']);
            foreach ($amenities as $amenity) {
                $query->where('amenities', 'LIKE', "%{$amenity}%");
            }
        }

        // Filtro por capacidade (hóspedes)
        if (!empty($filters['guests'])) {
            $query->where('max_guests', '>=', $filters['guests']);
        }

        // Verificar disponibilidade (datas)
        if (!empty($filters['check_in']) && !empty($filters['check_out'])) {
            $checkIn = Carbon::parse($filters['check_in']);
            $checkOut = Carbon::parse($filters['check_out']);
            
            $query->whereDoesntHave('bookings', function($bookingQuery) use ($checkIn, $checkOut) {
                $bookingQuery->where('status', '!=', 'cancelled')
                            ->where(function($dateQuery) use ($checkIn, $checkOut) {
                                $dateQuery->whereBetween('check_in_date', [$checkIn, $checkOut])
                                         ->orWhereBetween('check_out_date', [$checkIn, $checkOut])
                                         ->orWhere(function($overlapQuery) use ($checkIn, $checkOut) {
                                             $overlapQuery->where('check_in_date', '<=', $checkIn)
                                                         ->where('check_out_date', '>=', $checkOut);
                                         });
                            });
            });
        }

        // Ordenação
        $sortBy = $filters['sort'] ?? 'relevance';
        switch ($sortBy) {
            case 'price_low':
                $query->orderBy('price_per_night', 'asc');
                break;
            case 'price_high':
                $query->orderBy('price_per_night', 'desc');
                break;
            case 'rating':
                $query->orderBy('average_rating', 'desc');
                break;
            case 'newest':
                $query->orderBy('created_at', 'desc');
                break;
            default:
                $query->orderBy('featured', 'desc')
                      ->orderBy('average_rating', 'desc');
        }

        return $query;
    }

    public function getPopularDestinations($limit = 8)
    {
        return Property::selectRaw('cities.name as city_name, states.name as state_name, COUNT(*) as properties_count')
                      ->join('cities', 'properties.city_id', '=', 'cities.id')
                      ->join('states', 'cities.state_id', '=', 'states.id')
                      ->where('properties.active', true)
                      ->groupBy('cities.id', 'cities.name', 'states.name')
                      ->orderBy('properties_count', 'desc')
                      ->limit($limit)
                      ->get();
    }

    public function getFiltersData()
    {
        return [
            'property_types' => Property::select('property_type')
                                      ->distinct()
                                      ->pluck('property_type')
                                      ->filter()
                                      ->values(),
            'price_range' => [
                'min' => Property::where('active', true)->min('price_per_night') ?? 0,
                'max' => Property::where('active', true)->max('price_per_night') ?? 1000
            ],
            'amenities' => $this->getAvailableAmenities()
        ];
    }

    private function getAvailableAmenities()
    {
        $allAmenities = Property::where('active', true)
                               ->whereNotNull('amenities')
                               ->pluck('amenities')
                               ->flatMap(function($amenities) {
                                   return json_decode($amenities, true) ?? [];
                               })
                               ->unique()
                               ->values();

        return $allAmenities;
    }
}
EOF

# Atualizar Controller Site/PropertyController para busca
echo "🏠 Atualizando PropertyController com sistema de busca..."
cat > app/Http/Controllers/Site/PropertyController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;
use Carbon\Carbon;

class PropertyController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService)
    {
        $this->searchService = $searchService;
    }

    public function index(Request $request)
    {
        $filters = $request->only([
            'destination', 'check_in', 'check_out', 'guests', 
            'property_type', 'min_price', 'max_price', 'min_rating',
            'amenities', 'sort'
        ]);

        $query = $this->searchService->search($filters);
        $properties = $query->paginate(12)->withQueryString();

        $filtersData = $this->searchService->getFiltersData();
        $popularDestinations = $this->searchService->getPopularDestinations();

        return view('site.properties.index', compact(
            'properties', 'filters', 'filtersData', 'popularDestinations'
        ));
    }

    public function show($id)
    {
        $property = Property::with(['photos', 'reviews.user', 'city', 'state'])
                           ->findOrFail($id);

        $relatedProperties = Property::where('id', '!=', $id)
                                   ->where('city_id', $property->city_id)
                                   ->where('active', true)
                                   ->limit(4)
                                   ->get();

        return view('site.properties.show', compact('property', 'relatedProperties'));
    }

    public function searchSuggestions(Request $request)
    {
        $term = $request->get('term');
        
        if (strlen($term) < 2) {
            return response()->json([]);
        }

        $suggestions = collect();

        // Buscar cidades
        $cities = \App\Models\City::with('state')
                                 ->where('name', 'LIKE', "%{$term}%")
                                 ->limit(5)
                                 ->get()
                                 ->map(function($city) {
                                     return [
                                         'type' => 'city',
                                         'label' => $city->name . ', ' . $city->state->name,
                                         'value' => $city->name
                                     ];
                                 });

        // Buscar estados
        $states = \App\Models\State::where('name', 'LIKE', "%{$term}%")
                                  ->limit(3)
                                  ->get()
                                  ->map(function($state) {
                                      return [
                                          'type' => 'state',
                                          'label' => $state->name . ' (Estado)',
                                          'value' => $state->name
                                      ];
                                  });

        // Buscar propriedades
        $properties = Property::where('name', 'LIKE', "%{$term}%")
                             ->where('active', true)
                             ->limit(3)
                             ->get()
                             ->map(function($property) {
                                 return [
                                     'type' => 'property',
                                     'label' => $property->name,
                                     'value' => $property->name
                                 ];
                             });

        $suggestions = $suggestions->merge($cities)->merge($states)->merge($properties);

        return response()->json($suggestions->take(10)->values());
    }
}
EOF

# Criar Controller para API de busca
echo "📌 Criando API SearchController..."
mkdir -p app/Http/Controllers/Api
cat > app/Http/Controllers/Api/SearchController.php << 'EOF'
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SearchService;
use App\Http\Controllers\Site\PropertyController;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService)
    {
        $this->searchService = $searchService;
    }

    public function search(Request $request)
    {
        $filters = $request->only([
            'destination', 'check_in', 'check_out', 'guests', 
            'property_type', 'min_price', 'max_price', 'min_rating',
            'amenities', 'sort', 'page', 'per_page'
        ]);

        $perPage = min($filters['per_page'] ?? 12, 50);
        $query = $this->searchService->search($filters);
        $properties = $query->paginate($perPage)->withQueryString();

        return response()->json([
            'success' => true,
            'data' => $properties->items(),
            'pagination' => [
                'current_page' => $properties->currentPage(),
                'last_page' => $properties->lastPage(),
                'per_page' => $properties->perPage(),
                'total' => $properties->total()
            ],
            'filters_applied' => $filters
        ]);
    }

    public function filters()
    {
        $filtersData = $this->searchService->getFiltersData();
        
        return response()->json([
            'success' => true,
            'data' => $filtersData
        ]);
    }

    public function suggestions(Request $request)
    {
        $propertyController = new PropertyController($this->searchService);
        $suggestions = $propertyController->searchSuggestions($request);
        
        return response()->json([
            'success' => true,
            'data' => $suggestions->getData()
        ]);
    }

    public function popularDestinations()
    {
        $destinations = $this->searchService->getPopularDestinations();
        
        return response()->json([
            'success' => true,
            'data' => $destinations
        ]);
    }
}
EOF

# Adicionar rotas de busca
echo "🛣️ Adicionando rotas de busca..."

# Rotas web
cat >> routes/web.php << 'EOF'

// Rotas de busca
Route::get('/properties', [Site\PropertyController::class, 'index'])->name('site.properties.index');
Route::get('/properties/{id}', [Site\PropertyController::class, 'show'])->name('site.properties.show');
Route::get('/search/suggestions', [Site\PropertyController::class, 'searchSuggestions'])->name('site.search.suggestions');
EOF

# Rotas API
cat >> routes/api.php << 'EOF'

// API de busca
Route::prefix('search')->group(function () {
    Route::get('/', [Api\SearchController::class, 'search']);
    Route::get('/filters', [Api\SearchController::class, 'filters']);
    Route::get('/suggestions', [Api\SearchController::class, 'suggestions']);
    Route::get('/popular-destinations', [Api\SearchController::class, 'popularDestinations']);
});
EOF

echo "✅ Script 08-sistema-busca.sh criado com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "   ✅ app/Services/SearchService.php - Lógica de busca completa"
echo "   ✅ app/Http/Controllers/Site/PropertyController.php - Controller atualizado"
echo "   ✅ app/Http/Controllers/Api/SearchController.php - API de busca"
echo "   ✅ Rotas web e API adicionadas"
echo ""
echo "🔍 Funcionalidades implementadas:"
echo "   ✅ Busca por destino (cidade/estado/propriedade)"
echo "   ✅ Filtros: tipo, preço, avaliação, comodidades, hóspedes"
echo "   ✅ Verificação de disponibilidade por datas"
echo "   ✅ Ordenação múltipla (preço, avaliação, relevância)"
echo "   ✅ Sugestões de busca autocomplete"
echo "   ✅ API REST para mobile"
echo "   ✅ Destinos populares"
echo ""
echo "⏳ Próxima parte: Views de busca e filtros (08b-views-busca.sh)"
echo ""
echo "💡 Para executar: chmod +x 08-sistema-busca.sh && ./08-sistema-busca.sh"
echo ""
echo "Aguardando seu 'continuar' para a parte 2..."