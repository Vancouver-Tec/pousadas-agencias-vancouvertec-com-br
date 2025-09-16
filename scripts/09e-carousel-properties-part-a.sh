#!/bin/bash

# 🏨 Script 09e-A - Carrosseis com Propriedades do Banco (Parte A)
# Vancouver-Tec Pousadas & Agências
# HomeController + Banners SVG

echo "🏨 Parte A: HomeController e Banners SVG..."

# Atualizar HomeController para buscar dados específicos
echo "🎯 Atualizando HomeController..."
cat > app/Http/Controllers/Site/HomeController.php << 'EOF'
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
EOF

# Criar pasta para banners
echo "📁 Criando pasta para banners..."
mkdir -p public/images/banners

# Banner 1 - Promoção Família
echo "🎨 Criando banner família..."
cat > public/images/banners/banner-familia.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600">
  <defs>
    <linearGradient id="familyGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#ff6b6b;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#feca57;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#familyGrad)"/>
  <circle cx="200" cy="150" r="100" fill="white" opacity="0.1"/>
  <circle cx="900" cy="400" r="120" fill="white" opacity="0.15"/>
  <circle cx="1000" cy="100" r="80" fill="white" opacity="0.1"/>
  <text x="600" y="250" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="48" font-weight="bold">
    Diversão em Família
  </text>
  <text x="600" y="320" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="28" opacity="0.9">
    Hospedagens perfeitas para toda família se divertir
  </text>
  <rect x="500" y="380" width="200" height="60" rx="30" fill="white" opacity="0.2"/>
  <text x="600" y="420" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="20" font-weight="bold">
    FIQUE 3, PAGUE 2!
  </text>
</svg>
EOF

# Banner 2 - Romântico
echo "💕 Criando banner romântico..."
cat > public/images/banners/banner-romantico.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600">
  <defs>
    <linearGradient id="romanticGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#e056fd;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#ff3838;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#romanticGrad)"/>
  <path d="M300,200 C300,150 350,150 350,200 C350,150 400,150 400,200 C400,250 350,300 350,300 C350,300 300,250 300,200 Z" fill="white" opacity="0.15"/>
  <path d="M800,350 C800,300 850,300 850,350 C850,300 900,300 900,350 C900,400 850,450 850,450 C850,450 800,400 800,350 Z" fill="white" opacity="0.1"/>
  <text x="600" y="250" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="48" font-weight="bold">
    Momentos Românticos
  </text>
  <text x="600" y="320" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="28" opacity="0.9">
    Escapadas perfeitas para casais apaixonados
  </text>
  <rect x="500" y="380" width="200" height="60" rx="30" fill="white" opacity="0.2"/>
  <text x="600" y="420" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="18" font-weight="bold">
    15% OFF PRIMEIRA RESERVA
  </text>
</svg>
EOF

# Banner 3 - Aventura
echo "🏔️ Criando banner aventura..."
cat > public/images/banners/banner-aventura.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600">
  <defs>
    <linearGradient id="adventureGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#00d2d3;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#54a0ff;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="1200" height="600" fill="url(#adventureGrad)"/>
  <polygon points="200,300 250,200 300,300" fill="white" opacity="0.15"/>
  <polygon points="800,350 850,250 900,350" fill="white" opacity="0.12"/>
  <polygon points="1000,400 1050,300 1100,400" fill="white" opacity="0.1"/>
  <text x="600" y="250" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="48" font-weight="bold">
    Aventuras Inesquecíveis
  </text>
  <text x="600" y="320" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="28" opacity="0.9">
    Explore a natureza com todo conforto e segurança
  </text>
  <rect x="500" y="380" width="200" height="60" rx="30" fill="white" opacity="0.2"/>
  <text x="600" y="420" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="18" font-weight="bold">
    PACOTES A PARTIR DE R$ 320
  </text>
</svg>
EOF

echo "✅ Script 09e-carousel-properties-part-a.sh criado!"
echo ""
echo "🔧 Parte A implementada:"
echo "   ✅ HomeController atualizado com 6 tipos de dados"
echo "   ✅ 3 banners SVG personalizados criados"
echo "   ✅ Sistema de ofertas com desconto simulado"
echo "   ✅ Queries otimizadas para diferentes categorias"
echo ""
echo "💡 Para executar: chmod +x 09e-carousel-properties-part-a.sh && ./09e-carousel-properties-part-a.sh"
echo ""
echo "⏳ Aguardando seu 'continuar' para a Parte B (Views e JavaScript)..."