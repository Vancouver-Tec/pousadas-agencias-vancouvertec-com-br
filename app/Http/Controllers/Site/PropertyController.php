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
