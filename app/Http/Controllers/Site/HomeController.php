<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService)
    {
        $this->searchService = $searchService;
    }

    public function index()
    {
        // Propriedades em destaque
        $featuredProperties = Property::with(['photos', 'city', 'state'])
                                    ->where('active', true)
                                    ->where('featured', true)
                                    ->limit(8)
                                    ->get();

        // Destinos populares
        $popularDestinations = $this->searchService->getPopularDestinations(6);

        // Últimas propriedades adicionadas
        $latestProperties = Property::with(['photos', 'city', 'state'])
                                  ->where('active', true)
                                  ->orderBy('created_at', 'desc')
                                  ->limit(6)
                                  ->get();

        return view('site.home', compact('featuredProperties', 'popularDestinations', 'latestProperties'));
    }
}
