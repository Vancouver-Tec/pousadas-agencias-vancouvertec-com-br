#!/bin/bash

# 🏠 Script 09b - Correção Views Home
# Vancouver-Tec Pousadas & Agências
# Corrige HomeController e cria layout principal estilo Booking.com

echo "🏠 Corrigindo views e controllers..."

# Corrigir HomeController
echo "📝 Atualizando HomeController..."
cat > app/Http/Controllers/Site/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Services\SearchService;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    protected $searchService;

    public function __construct(SearchService $searchService = null)
    {
        // Tornar SearchService opcional por enquanto
        $this->searchService = $searchService;
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
            // Tentar buscar propriedades se as tabelas existirem
            if (schema()->hasTable('properties')) {
                $data['featuredProperties'] = Property::where('active', true)
                                                    ->where('featured', true)
                                                    ->limit(8)
                                                    ->get();

                $data['latestProperties'] = Property::where('active', true)
                                                  ->orderBy('created_at', 'desc')
                                                  ->limit(6)
                                                  ->get();

                // Usar SearchService se disponível
                if ($this->searchService) {
                    $data['popularDestinations'] = $this->searchService->getPopularDestinations(6);
                }
            }
        } catch (\Exception $e) {
            // Ignorar erros de banco por enquanto
            \Log::info('HomeController: Banco ainda não configurado - ' . $e->getMessage());
        }

        return view('site.home', $data);
    }
}

// Helper function para verificar schema
function schema() {
    return \Illuminate\Support\Facades\Schema::class;
}
EOF

# Criar layout principal do site
echo "🎨 Criando layout principal..."
mkdir -p resources/views/layouts
cat > resources/views/layouts/site.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Vancouver-Tec Pousadas')</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Custom CSS -->
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
        .booking-gradient { background: linear-gradient(135deg, #003580 0%, #0071c2 100%); }
        
        .property-card:hover .property-image {
            transform: scale(1.05);
        }
        
        .property-image {
            transition: transform 0.3s ease;
        }
        
        .search-suggestions {
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="booking-blue text-white shadow-lg">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-between h-16">
                <!-- Logo -->
                <div class="flex items-center">
                    <a href="{{ route('site.home') }}" class="text-xl font-bold">
                        <i class="fas fa-home mr-2"></i>
                        Vancouver-Tec
                    </a>
                </div>
                
                <!-- Navigation -->
                <nav class="hidden md:flex space-x-6">
                    <a href="{{ route('site.home') }}" class="hover:text-blue-200 transition">Home</a>
                    <a href="{{ route('site.properties.index') }}" class="hover:text-blue-200 transition">Propriedades</a>
                    <a href="#" class="hover:text-blue-200 transition">Sobre</a>
                    <a href="#" class="hover:text-blue-200 transition">Contato</a>
                </nav>
                
                <!-- User Menu -->
                <div class="flex items-center space-x-4">
                    @auth
                        <div class="relative group">
                            <button class="flex items-center space-x-2 hover:text-blue-200">
                                <i class="fas fa-user-circle text-xl"></i>
                                <span>{{ Auth::user()->name }}</span>
                                <i class="fas fa-chevron-down text-sm"></i>
                            </button>
                            <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 hidden group-hover:block">
                                <a href="{{ route('client.dashboard') }}" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Minha Conta</a>
                                <a href="#" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Minhas Reservas</a>
                                <a href="#" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Favoritos</a>
                                <hr class="my-2">
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <button type="submit" class="block w-full text-left px-4 py-2 text-gray-800 hover:bg-gray-100">Sair</button>
                                </form>
                            </div>
                        </div>
                    @else
                        <a href="{{ route('login') }}" class="hover:text-blue-200">Entrar</a>
                        <a href="{{ route('register') }}" class="bg-white text-blue-800 px-4 py-2 rounded-lg hover:bg-blue-50 transition">Cadastrar</a>
                    @endauth
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main>
        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-16">
        <div class="container mx-auto px-4 py-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div>
                    <h3 class="text-lg font-bold mb-4">Vancouver-Tec</h3>
                    <p class="text-gray-300">Sua plataforma completa para hospedagens e turismo no Brasil.</p>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Links Rápidos</h4>
                    <ul class="space-y-2 text-gray-300">
                        <li><a href="#" class="hover:text-white">Como funciona</a></li>
                        <li><a href="#" class="hover:text-white">Cadastrar propriedade</a></li>
                        <li><a href="#" class="hover:text-white">Ajuda</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Suporte</h4>
                    <ul class="space-y-2 text-gray-300">
                        <li><a href="#" class="hover:text-white">Central de Ajuda</a></li>
                        <li><a href="#" class="hover:text-white">Contato</a></li>
                        <li><a href="#" class="hover:text-white">Termos de Uso</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Redes Sociais</h4>
                    <div class="flex space-x-4">
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-facebook text-xl"></i></a>
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-instagram text-xl"></i></a>
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-twitter text-xl"></i></a>
                    </div>
                </div>
            </div>
            <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-300">
                <p>&copy; {{ date('Y') }} Vancouver-Tec. Todos os direitos reservados.</p>
            </div>
        </div>
    </footer>

    <!-- JavaScript Global -->
    <script>
        // CSRF Token para requisições AJAX
        window.Laravel = {
            csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        };
        
        // Função para mostrar/ocultar menu mobile
        function toggleMobileMenu() {
            const menu = document.getElementById('mobile-menu');
            menu.classList.toggle('hidden');
        }
    </script>
    
    @stack('scripts')
</body>
</html>
EOF

# Recriar view home.blade.php usando o layout
echo "🏠 Recriando view home..."
cat > resources/views/site/home.blade.php << 'EOF'
@extends('layouts.site')

@section('title', $title)

@section('content')
<!-- Hero Section -->
<section class="booking-gradient text-white py-16">
    <div class="container mx-auto px-4">
        <div class="text-center mb-8">
            <h1 class="text-4xl md:text-5xl font-bold mb-4">{{ $title }}</h1>
            <p class="text-xl opacity-90">{{ $subtitle }}</p>
        </div>

        <!-- Search Form -->
        <div class="max-w-4xl mx-auto bg-white rounded-lg shadow-xl p-6">
            <form action="{{ route('site.properties.index') }}" method="GET" id="searchForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <!-- Destino -->
                <div class="relative">
                    <label for="destination" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-map-marker-alt mr-1"></i>Para onde você vai?
                    </label>
                    <input type="text" 
                           id="destination" 
                           name="destination" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="Cidade, região, propriedade"
                           autocomplete="off">
                    
                    <!-- Suggestions Dropdown -->
                    <div id="suggestions" class="absolute z-10 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden search-suggestions"></div>
                </div>

                <!-- Check-in -->
                <div>
                    <label for="check_in" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-calendar-alt mr-1"></i>Check-in
                    </label>
                    <input type="date" 
                           id="check_in" 
                           name="check_in" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           value="{{ date('Y-m-d') }}"
                           min="{{ date('Y-m-d') }}">
                </div>

                <!-- Check-out -->
                <div>
                    <label for="check_out" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-calendar-alt mr-1"></i>Check-out
                    </label>
                    <input type="date" 
                           id="check_out" 
                           name="check_out" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           value="{{ date('Y-m-d', strtotime('+1 day')) }}"
                           min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>

                <!-- Hóspedes e Buscar -->
                <div>
                    <label for="guests" class="block text-sm font-medium text-gray-700 mb-2">
                        <i class="fas fa-users mr-1"></i>Hóspedes
                    </label>
                    <div class="flex">
                        <select id="guests" 
                                name="guests" 
                                class="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                            <option value="1">1 hóspede</option>
                            <option value="2">2 hóspedes</option>
                            <option value="3">3 hóspedes</option>
                            <option value="4">4 hóspedes</option>
                            <option value="5">5+ hóspedes</option>
                        </select>
                        <button type="submit" 
                                class="px-6 py-3 booking-blue-light text-white rounded-r-lg hover:bg-blue-700 transition-colors">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<!-- Featured Properties -->
@if($featuredProperties->count() > 0)
<section class="py-16">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Propriedades em Destaque</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            @foreach($featuredProperties as $property)
                <div class="property-card bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow">
                    <div class="relative overflow-hidden h-48">
                        @if($property->photos && $property->photos->count() > 0)
                            <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                 alt="{{ $property->name }}"
                                 class="property-image w-full h-full object-cover">
                        @else
                            <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                <i class="fas fa-image text-gray-400 text-2xl"></i>
                            </div>
                        @endif
                        <div class="absolute top-3 right-3">
                            <span class="bg-yellow-400 text-yellow-900 px-2 py-1 rounded text-xs font-bold">
                                <i class="fas fa-star mr-1"></i>{{ number_format($property->average_rating ?: $property->rating, 1) }}
                            </span>
                        </div>
                    </div>
                    
                    <div class="p-4">
                        <h3 class="font-bold text-lg text-gray-900 mb-2 truncate">{{ $property->name }}</h3>
                        <p class="text-gray-600 text-sm mb-3 flex items-center">
                            <i class="fas fa-map-marker-alt mr-2"></i>
                            {{ $property->city }}, {{ $property->state }}
                        </p>
                        <div class="flex items-center justify-between">
                            <div>
                                <span class="text-2xl font-bold text-gray-900">R$ {{ number_format($property->price_per_night, 0, ',', '.') }}</span>
                                <span class="text-gray-600 text-sm"> / noite</span>
                            </div>
                            <a href="{{ route('site.properties.show', $property->id) }}" 
                               class="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700 transition">
                                Ver Detalhes
                            </a>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
</section>
@endif

<!-- Popular Destinations -->
@if($popularDestinations->count() > 0)
<section class="py-16 bg-gray-100">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Destinos Populares</h2>
        
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            @foreach($popularDestinations as $destination)
                <a href="{{ route('site.properties.index', ['destination' => $destination->city_name]) }}" 
                   class="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-center">
                    <i class="fas fa-city text-2xl text-blue-600 mb-2"></i>
                    <h3 class="font-bold text-gray-900">{{ $destination->city_name }}</h3>
                    <p class="text-gray-600 text-sm">{{ $destination->properties_count }} propriedades</p>
                </a>
            @endforeach
        </div>
    </div>
</section>
@endif

<!-- Call to Action -->
<section class="py-16 booking-gradient text-white">
    <div class="container mx-auto px-4 text-center">
        <h2 class="text-3xl font-bold mb-4">Pronto para começar sua aventura?</h2>
        <p class="text-xl mb-8 opacity-90">Encontre a hospedagem perfeita para sua próxima viagem</p>
        <a href="{{ route('site.properties.index') }}" 
           class="bg-white text-blue-800 px-8 py-3 rounded-lg font-bold hover:bg-blue-50 transition-colors inline-block">
            Explorar Propriedades
        </a>
    </div>
</section>
@endsection

@push('scripts')
<script src="{{ asset('js/search.js') }}"></script>
@endpush
EOF

echo "✅ Script 09b-fix-home-views.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ HomeController corrigido com tratamento de erro"
echo "   ✅ Layout principal site.blade.php criado"
echo "   ✅ View home.blade.php recriada com design moderno"
echo "   ✅ Navegação e footer completos"
echo "   ✅ Formulário de busca integrado"
echo ""
echo "🎨 Design Features:"
echo "   ✅ Layout responsivo estilo Booking.com"
echo "   ✅ Hero section com busca"
echo "   ✅ Cards de propriedades em destaque"
echo "   ✅ Seção de destinos populares"
echo "   ✅ Navigation dropdown para usuários logados"
echo ""
echo "💡 Para executar: chmod +x 09b-fix-home-views.sh && ./09b-fix-home-views.sh"