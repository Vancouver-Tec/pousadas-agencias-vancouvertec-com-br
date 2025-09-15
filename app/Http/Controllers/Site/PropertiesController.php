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
