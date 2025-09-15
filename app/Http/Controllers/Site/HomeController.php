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
