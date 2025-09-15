#!/bin/bash

# 🔍 Script 08 - Sistema de Busca Completo (Estilo Booking.com)
# Vancouver-Tec Pousadas & Agências
# Implementa SearchService, Controllers de busca e APIs

echo "🔍 Iniciando implementação do Sistema de Busca..."

# Corrigir HomeController com verificação correta do schema
echo "🏠 Corrigindo HomeController..."
cat > app/Http/Controllers/Site/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Log;

class HomeController extends Controller
{
    protected $searchService;

    public function __construct()
    {
        // SearchService será injetado conforme necessário
        $this->searchService = null;
    }

    public function index()
    {
        // Dados básicos sempre disponíveis
        $data = [
            'title' => 'Vancouver-Tec Pousadas & Agências',
            'subtitle' => 'Encontre sua hospedagem ideal no Brasil',
            'featuredProperties' => collect(),
            'popularDestinations' => collect(),
            'latestProperties' => collect()
        ];

        try {
            // Verificar se as tabelas existem antes de fazer queries
            if (Schema::hasTable('properties') && Schema::hasTable('users')) {
                
                // Buscar propriedades em destaque
                $data['featuredProperties'] = Property::where('active', true)
                                                    ->where('featured', true)
                                                    ->with(['photos' => function($query) {
                                                        $query->where('is_primary', true);
                                                    }])
                                                    ->limit(8)
                                                    ->get();

                // Buscar propriedades recentes
                $data['latestProperties'] = Property::where('active', true)
                                                  ->orderBy('created_at', 'desc')
                                                  ->with(['photos' => function($query) {
                                                      $query->where('is_primary', true);
                                                  }])
                                                  ->limit(6)
                                                  ->get();

                // Buscar destinos populares (simulado por enquanto)
                if (Schema::hasTable('cities') && Schema::hasTable('states')) {
                    $data['popularDestinations'] = \DB::table('properties')
                        ->join('cities', 'properties.city_id', '=', 'cities.id')
                        ->join('states', 'cities.state_id', '=', 'states.id')
                        ->select('cities.name as city_name', 'states.name as state_name', 
                                \DB::raw('COUNT(*) as properties_count'))
                        ->where('properties.active', true)
                        ->groupBy('cities.id', 'cities.name', 'states.name')
                        ->orderBy('properties_count', 'desc')
                        ->limit(6)
                        ->get();
                }
            }
        } catch (\Exception $e) {
            // Log do erro para debug, mas não quebra a página
            Log::info('HomeController: Erro ao carregar dados - ' . $e->getMessage());
        }

        return view('site.home', $data);
    }
}
EOF

# Criar SearchService
echo "🔎 Criando SearchService..."
mkdir -p app/Services
cat > app/Services/SearchService.php << 'EOF'
<?php

namespace App\Services;

use App\Models\Property;
use App\Models\City;
use App\Models\State;
use Illuminate\Http\Request;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class SearchService
{
    public function search(Request $request)
    {
        $query = Property::query()->with(['photos', 'city', 'state', 'reviews'])
                        ->where('active', true);

        // Filtro por destino (cidade, estado ou nome da propriedade)
        if ($request->filled('destination')) {
            $destination = $request->destination;
            $query->where(function (Builder $q) use ($destination) {
                // Busca por nome da propriedade
                $q->where('name', 'LIKE', "%{$destination}%")
                  ->orWhere('description', 'LIKE', "%{$destination}%");
                
                // Busca por cidade/estado se as tabelas existirem
                if (\Schema::hasTable('cities') && \Schema::hasTable('states')) {
                    $q->orWhereHas('city', function (Builder $cityQuery) use ($destination) {
                        $cityQuery->where('name', 'LIKE', "%{$destination}%");
                    })->orWhereHas('state', function (Builder $stateQuery) use ($destination) {
                        $stateQuery->where('name', 'LIKE', "%{$destination}%");
                    });
                } else {
                    // Fallback para colunas antigas
                    $q->orWhere('city', 'LIKE', "%{$destination}%")
                      ->orWhere('state', 'LIKE', "%{$destination}%");
                }
            });
        }

        // Filtro por datas (disponibilidade)
        if ($request->filled('check_in') && $request->filled('check_out')) {
            $query->available($request->check_in, $request->check_out);
        }

        // Filtro por número de hóspedes
        if ($request->filled('guests')) {
            $query->where('max_guests', '>=', $request->guests);
        }

        // Filtro por tipo de propriedade
        if ($request->filled('type')) {
            $query->where('type', $request->type);
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
            $query->where(function (Builder $q) use ($request) {
                $q->where('average_rating', '>=', $request->min_rating)
                  ->orWhere('rating', '>=', $request->min_rating);
            });
        }

        // Filtro por comodidades
        if ($request->filled('amenities')) {
            $amenities = is_array($request->amenities) ? $request->amenities : [$request->amenities];
            foreach ($amenities as $amenity) {
                $query->whereJsonContains('amenities', $amenity);
            }
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

        return $query->paginate(12)->appends($request->query());
    }

    public function getDestinationSuggestions($term)
    {
        $suggestions = collect();

        // Buscar cidades
        if (\Schema::hasTable('cities')) {
            $cities = City::where('name', 'LIKE', "%{$term}%")
                         ->with('state')
                         ->limit(5)
                         ->get();
            
            foreach ($cities as $city) {
                $suggestions->push([
                    'type' => 'city',
                    'name' => $city->name . ', ' . $city->state->name,
                    'value' => $city->name
                ]);
            }
        }

        // Buscar estados
        if (\Schema::hasTable('states')) {
            $states = State::where('name', 'LIKE', "%{$term}%")
                          ->limit(3)
                          ->get();
            
            foreach ($states as $state) {
                $suggestions->push([
                    'type' => 'state',
                    'name' => $state->name,
                    'value' => $state->name
                ]);
            }
        }

        // Buscar propriedades por nome
        $properties = Property::where('active', true)
                            ->where('name', 'LIKE', "%{$term}%")
                            ->limit(5)
                            ->get();
        
        foreach ($properties as $property) {
            $location = \Schema::hasTable('cities') && $property->city 
                       ? $property->city->name . ', ' . $property->state->name
                       : ($property->city ?? '') . ', ' . ($property->state ?? '');
                       
            $suggestions->push([
                'type' => 'property',
                'name' => $property->name,
                'location' => $location,
                'value' => $property->name
            ]);
        }

        return $suggestions->take(10);
    }

    public function getPopularDestinations($limit = 6)
    {
        try {
            if (\Schema::hasTable('cities') && \Schema::hasTable('states')) {
                return DB::table('properties')
                    ->join('cities', 'properties.city_id', '=', 'cities.id')
                    ->join('states', 'cities.state_id', '=', 'states.id')
                    ->select('cities.name as city_name', 'states.name as state_name', 
                            DB::raw('COUNT(*) as properties_count'))
                    ->where('properties.active', true)
                    ->groupBy('cities.id', 'cities.name', 'states.name')
                    ->orderBy('properties_count', 'desc')
                    ->limit($limit)
                    ->get();
            } else {
                // Fallback para colunas antigas
                return DB::table('properties')
                    ->select('city as city_name', 'state as state_name', 
                            DB::raw('COUNT(*) as properties_count'))
                    ->where('active', true)
                    ->whereNotNull('city')
                    ->whereNotNull('state')
                    ->groupBy('city', 'state')
                    ->orderBy('properties_count', 'desc')
                    ->limit($limit)
                    ->get();
            }
        } catch (\Exception $e) {
            return collect();
        }
    }

    public function getFilterOptions()
    {
        $options = [];

        try {
            // Tipos de propriedade
            $options['types'] = Property::where('active', true)
                                      ->whereNotNull('type')
                                      ->distinct()
                                      ->pluck('type')
                                      ->filter()
                                      ->values();

            // Range de preços
            $priceRange = Property::where('active', true)
                                ->selectRaw('MIN(price_per_night) as min_price, MAX(price_per_night) as max_price')
                                ->first();
            
            $options['price_range'] = [
                'min' => (int) $priceRange->min_price ?? 0,
                'max' => (int) $priceRange->max_price ?? 1000
            ];

            // Comodidades mais comuns
            $allAmenities = Property::where('active', true)
                                  ->whereNotNull('amenities')
                                  ->pluck('amenities')
                                  ->flatten()
                                  ->countBy()
                                  ->sortDesc()
                                  ->take(15)
                                  ->keys();
            
            $options['amenities'] = $allAmenities->values();

        } catch (\Exception $e) {
            $options['types'] = collect(['Hotel', 'Pousada', 'Casa', 'Apartamento']);
            $options['price_range'] = ['min' => 50, 'max' => 500];
            $options['amenities'] = collect(['Wi-Fi', 'Piscina', 'Estacionamento', 'Ar-condicionado']);
        }

        return $options;
    }
}
EOF

# Atualizar PropertiesController para usar SearchService
echo "🏨 Atualizando PropertiesController..."
cat > app/Http/Controllers/Site/PropertiesController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;

class PropertiesController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService)
    {
        $this->searchService = $searchService;
    }

    public function index(Request $request)
    {
        // Executar busca
        $properties = $this->searchService->search($request);
        
        // Opções para filtros
        $filterOptions = $this->searchService->getFilterOptions();
        
        return view('site.properties.index', compact('properties', 'filterOptions', 'request'));
    }

    public function show($id)
    {
        $property = Property::with(['photos', 'city', 'state', 'reviews.user'])
                          ->where('active', true)
                          ->findOrFail($id);

        return view('site.properties.show', compact('property'));
    }
}
EOF

echo "✅ Script 08-sistema-busca.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ HomeController corrigido (Schema::hasTable em vez de schema()->hasTable)"
echo "   ✅ SearchService completo com filtros avançados"
echo "   ✅ PropertiesController atualizado"
echo "   ✅ Tratamento de erro robusto"
echo ""
echo "🔍 Funcionalidades do SearchService:"
echo "   ✅ Busca por destino (cidade/estado/propriedade)"
echo "   ✅ Filtros por data, hóspedes, preço, tipo"
echo "   ✅ Filtros por avaliação e comodidades"
echo "   ✅ Múltiplas opções de ordenação"
echo "   ✅ Sugestões de autocomplete"
echo "   ✅ Destinos populares"
echo ""
echo "💡 Para executar: chmod +x 08-sistema-busca.sh && ./08-sistema-busca.sh"