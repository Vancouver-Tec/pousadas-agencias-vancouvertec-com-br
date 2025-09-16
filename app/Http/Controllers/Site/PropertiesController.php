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
