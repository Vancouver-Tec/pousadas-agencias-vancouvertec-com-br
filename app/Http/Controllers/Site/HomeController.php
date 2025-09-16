<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class HomeController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService = null)
    {
        $this->searchService = $searchService;
    }

    public function index()
    {
        $data = [
            'title' => 'Vancouver-Tec Pousadas & Agências',
            'subtitle' => 'Encontre sua hospedagem ideal no Brasil',
            'featuredProperties' => collect(),
            'popularDestinations' => collect(),
            'latestProperties' => collect(),
            'weekendOffers' => collect(),
            'exclusiveProperties' => collect(),
            'similarProperties' => collect()
        ];

        try {
            if (Schema::hasTable('properties')) {
                // Propriedades em destaque (featured)
                $data['featuredProperties'] = Property::where('active', true)
                                                    ->where('featured', true)
                                                    ->with(['photos'])
                                                    ->limit(8)
                                                    ->get();

                // Propriedades mais recentes
                $data['latestProperties'] = Property::where('active', true)
                                                  ->with(['photos'])
                                                  ->orderBy('created_at', 'desc')
                                                  ->limit(6)
                                                  ->get();

                // Ofertas de fim de semana (propriedades com desconto simulado)
                $data['weekendOffers'] = Property::where('active', true)
                                               ->where('price_per_night', '<=', 300)
                                               ->with(['photos'])
                                               ->inRandomOrder()
                                               ->limit(8)
                                               ->get()
                                               ->map(function($property) {
                                                   $property->original_price = $property->price_per_night * 1.2;
                                                   $property->discount_percent = 15;
                                                   return $property;
                                               });

                // Acomodações exclusivas (propriedades premium)
                $data['exclusiveProperties'] = Property::where('active', true)
                                                     ->where('price_per_night', '>', 400)
                                                     ->with(['photos'])
                                                     ->orderBy('average_rating', 'desc')
                                                     ->limit(8)
                                                     ->get();

                // Propriedades similares (baseado em preço médio)
                $averagePrice = Property::where('active', true)->avg('price_per_night') ?: 200;
                $data['similarProperties'] = Property::where('active', true)
                                                   ->whereBetween('price_per_night', [$averagePrice * 0.8, $averagePrice * 1.2])
                                                   ->with(['photos'])
                                                   ->inRandomOrder()
                                                   ->limit(8)
                                                   ->get();

                // Usar SearchService se disponível
                if ($this->searchService) {
                    $data['popularDestinations'] = $this->searchService->getPopularDestinations(6);
                }
            }
        } catch (\Exception $e) {
            \Log::info('HomeController: ' . $e->getMessage());
        }

        return view('site.home', $data);
    }
}
