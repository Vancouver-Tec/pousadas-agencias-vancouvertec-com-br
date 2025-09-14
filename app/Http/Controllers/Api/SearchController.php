<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\SearchService;
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
        $term = $request->get('term');
        
        if (strlen($term) < 2) {
            return response()->json([
                'success' => true,
                'data' => []
            ]);
        }

        $suggestions = app(PropertyController::class)->searchSuggestions($request);
        
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
