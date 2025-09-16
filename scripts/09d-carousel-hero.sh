#!/bin/bash

# 🎠 Script 09d - Carrosseis e Hero Section Interativo
# Vancouver-Tec Pousadas & Agências
# Implementa carrossel de promoções e seção hero com imagens

echo "🎠 Iniciando implementação dos carrosseis..."

# Atualizar layout principal com Swiper.js
echo "🎨 Atualizando layout com bibliotecas de carrossel..."
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
    
    <!-- Swiper CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/Swiper/10.3.1/swiper-bundle.min.css">
    
    <!-- Custom CSS -->
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
        .booking-gradient { background: linear-gradient(135deg, #003580 0%, #0071c2 100%); }
        
        /* Hero Carousel Styles */
        .hero-carousel .swiper-slide {
            height: 500px;
            position: relative;
            overflow: hidden;
        }
        
        .hero-carousel .slide-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            z-index: 10;
            width: 90%;
        }
        
        .hero-carousel .slide-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 53, 128, 0.7);
            z-index: 5;
        }
        
        .hero-carousel .swiper-pagination-bullet {
            background: white;
            opacity: 0.7;
        }
        
        .hero-carousel .swiper-pagination-bullet-active {
            opacity: 1;
        }
        
        .hero-carousel .swiper-button-next,
        .hero-carousel .swiper-button-prev {
            color: white;
        }
        
        /* Property Carousel Styles */
        .property-carousel .swiper-slide {
            width: auto;
        }
        
        .property-card:hover .property-image {
            transform: scale(1.05);
        }
        
        .property-image {
            transition: transform 0.3s ease;
        }
        
        /* Partners Carousel */
        .partners-carousel .swiper-slide {
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .partners-carousel img {
            filter: grayscale(100%);
            opacity: 0.6;
            transition: all 0.3s ease;
        }
        
        .partners-carousel img:hover {
            filter: grayscale(0%);
            opacity: 1;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .hero-carousel .swiper-slide {
                height: 400px;
            }
            
            .hero-carousel .slide-content h2 {
                font-size: 2rem !important;
            }
        }
        
        /* Loading animation */
        .loading-placeholder {
            background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
        }
        
        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="booking-blue text-white shadow-lg relative z-50">
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
                
                <!-- Mobile menu button -->
                <button class="md:hidden" onclick="toggleMobileMenu()">
                    <i class="fas fa-bars text-xl"></i>
                </button>
            </div>
            
            <!-- Mobile Menu -->
            <div id="mobile-menu" class="hidden md:hidden pb-4">
                <nav class="space-y-2">
                    <a href="{{ route('site.home') }}" class="block hover:text-blue-200 transition">Home</a>
                    <a href="{{ route('site.properties.index') }}" class="block hover:text-blue-200 transition">Propriedades</a>
                    <a href="#" class="block hover:text-blue-200 transition">Sobre</a>
                    <a href="#" class="block hover:text-blue-200 transition">Contato</a>
                </nav>
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

    <!-- Swiper JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Swiper/10.3.1/swiper-bundle.min.js"></script>
    
    <!-- JavaScript Global -->
    <script>
        // CSRF Token
        window.Laravel = {
            csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        };
        
        // Mobile menu toggle
        function toggleMobileMenu() {
            const menu = document.getElementById('mobile-menu');
            menu.classList.toggle('hidden');
        }
        
        // Initialize carousels when DOM is ready
        document.addEventListener('DOMContentLoaded', function() {
            // Hero Carousel
            if (document.querySelector('.hero-carousel')) {
                new Swiper('.hero-carousel', {
                    loop: true,
                    autoplay: {
                        delay: 5000,
                        disableOnInteraction: false,
                    },
                    pagination: {
                        el: '.swiper-pagination',
                        clickable: true,
                    },
                    navigation: {
                        nextEl: '.swiper-button-next',
                        prevEl: '.swiper-button-prev',
                    },
                    effect: 'fade',
                    fadeEffect: {
                        crossFade: true
                    }
                });
            }
            
            // Property Carousel
            if (document.querySelector('.property-carousel')) {
                new Swiper('.property-carousel', {
                    slidesPerView: 1,
                    spaceBetween: 20,
                    navigation: {
                        nextEl: '.property-next',
                        prevEl: '.property-prev',
                    },
                    breakpoints: {
                        640: {
                            slidesPerView: 2,
                        },
                        768: {
                            slidesPerView: 3,
                        },
                        1024: {
                            slidesPerView: 4,
                        },
                    }
                });
            }
            
            // Partners Carousel
            if (document.querySelector('.partners-carousel')) {
                new Swiper('.partners-carousel', {
                    slidesPerView: 2,
                    spaceBetween: 30,
                    loop: true,
                    autoplay: {
                        delay: 3000,
                        disableOnInteraction: false,
                    },
                    breakpoints: {
                        640: {
                            slidesPerView: 3,
                        },
                        768: {
                            slidesPerView: 4,
                        },
                        1024: {
                            slidesPerView: 6,
                        },
                    }
                });
            }
        });
    </script>
    
    @stack('scripts')
</body>
</html>
EOF

echo "🏠 Criando nova view home com carrosseis..."
cat > resources/views/site/home.blade.php << 'EOF'
@extends('layouts.site')

@section('title', $title)

@section('content')
<!-- Hero Carousel -->
<section class="hero-carousel swiper relative">
    <div class="swiper-wrapper">
        <!-- Slide 1 - Promoção Família -->
        <div class="swiper-slide" style="background: linear-gradient(rgba(0,53,128,0.4), rgba(0,113,194,0.4)), url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1200 600\" fill=\"%23f0f9ff\"><rect width=\"1200\" height=\"600\" fill=\"%2303045e\"/><circle cx=\"200\" cy=\"150\" r=\"100\" fill=\"%230284c7\" opacity=\"0.3\"/><circle cx=\"800\" cy=\"400\" r=\"150\" fill=\"%230ea5e9\" opacity=\"0.2\"/><circle cx=\"1000\" cy=\"200\" r=\"80\" fill=\"%2338bdf8\" opacity=\"0.4\"/></svg>'); background-size: cover; background-position: center;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Fique 3, Pague 2!</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Economize até 33% em estadias longas</p>
                <div class="space-x-4">
                    <a href="{{ route('site.properties.index') }}" class="bg-white text-blue-800 px-8 py-3 rounded-lg font-bold hover:bg-blue-50 transition">
                        Ver Ofertas
                    </a>
                    <span class="bg-yellow-400 text-yellow-900 px-6 py-3 rounded-lg font-bold">
                        Válido até 31/12
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Slide 2 - Primeira Viagem -->
        <div class="swiper-slide" style="background: linear-gradient(rgba(129,38,192,0.4), rgba(147,51,234,0.4)), url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1200 600\" fill=\"%23faf5ff\"><rect width=\"1200\" height=\"600\" fill=\"%23581c87\"/><circle cx=\"300\" cy=\"100\" r=\"120\" fill=\"%237c3aed\" opacity=\"0.3\"/><circle cx=\"900\" cy=\"350\" r=\"100\" fill=\"%238b5cf6\" opacity=\"0.4\"/><circle cx=\"600\" cy=\"500\" r=\"90\" fill=\"%23a78bfa\" opacity=\"0.2\"/></svg>'); background-size: cover; background-position: center;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Primeira Viagem?</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Ganhe 15% de desconto no seu cadastro</p>
                <div class="space-x-4">
                    <a href="{{ route('register') }}" class="bg-white text-purple-800 px-8 py-3 rounded-lg font-bold hover:bg-purple-50 transition">
                        Cadastrar Agora
                    </a>
                    <span class="bg-green-400 text-green-900 px-6 py-3 rounded-lg font-bold">
                        Código: BEMVINDO15
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Slide 3 - Pacotes Especiais -->
        <div class="swiper-slide" style="background: linear-gradient(rgba(16,185,129,0.4), rgba(34,197,94,0.4)), url('data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 1200 600\" fill=\"%23f0fdf4\"><rect width=\"1200\" height=\"600\" fill=\"%23064e3b\"/><circle cx=\"150\" cy=\"250\" r=\"80\" fill=\"%2310b981\" opacity=\"0.3\"/><circle cx=\"750\" cy=\"150\" r=\"110\" fill=\"%2322c55e\" opacity=\"0.4\"/><circle cx=\"1050\" cy=\"450\" r=\"90\" fill=\"%2334d399\" opacity=\"0.3\"/></svg>'); background-size: cover; background-position: center;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Pacotes Especiais</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Família, Romântico e Aventura esperando você</p>
                <div class="space-x-4">
                    <a href="#pacotes" class="bg-white text-green-800 px-8 py-3 rounded-lg font-bold hover:bg-green-50 transition">
                        Ver Pacotes
                    </a>
                    <span class="bg-orange-400 text-orange-900 px-6 py-3 rounded-lg font-bold">
                        A partir de R$ 280
                    </span>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Navigation -->
    <div class="swiper-pagination"></div>
    <div class="swiper-button-next"></div>
    <div class="swiper-button-prev"></div>
</section>

<!-- Search Form Section -->
<section class="bg-white py-8 shadow-lg relative z-40">
    <div class="container mx-auto px-4">
        <div class="max-w-4xl mx-auto">
            <form action="{{ route('site.properties.index') }}" method="GET" id="searchForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                <!-- Destino -->
                <div class="relative">
                    <label for="destination" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-map-marker-alt mr-1 text-blue-600"></i>Para onde você vai?
                    </label>
                    <input type="text" 
                           id="destination" 
                           name="destination" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 placeholder-gray-500"
                           placeholder="Cidade, região, propriedade"
                           autocomplete="off">
                    
                    <div id="suggestions" class="absolute z-10 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden search-suggestions"></div>
                </div>

                <!-- Check-in -->
                <div>
                    <label for="check_in" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-in
                    </label>
                    <input type="date" 
                           id="check_in" 
                           name="check_in" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d') }}"
                           min="{{ date('Y-m-d') }}">
                </div>

                <!-- Check-out -->
                <div>
                    <label for="check_out" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-out
                    </label>
                    <input type="date" 
                           id="check_out" 
                           name="check_out" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d', strtotime('+1 day')) }}"
                           min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>

                <!-- Hóspedes e Buscar -->
                <div>
                    <label for="guests" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-users mr-1 text-blue-600"></i>Hóspedes
                    </label>
                    <div class="flex">
                        <select id="guests" 
                                name="guests" 
                                class="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900">
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

<!-- Featured Properties Carousel -->
@if($featuredProperties && $featuredProperties->count() > 0)
<section class="py-16 bg-gray-50">
    <div class="container mx-auto px-4">
        <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-gray-900">Propriedades em Destaque</h2>
            <div class="flex space-x-2">
                <button class="property-prev bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50 transition">
                    <i class="fas fa-chevron-left text-blue-600"></i>
                </button>
                <button class="property-next bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50 transition">
                    <i class="fas fa-chevron-right text-blue-600"></i>
                </button>
            </div>
        </div>
        
        <div class="property-carousel swiper">
            <div class="swiper-wrapper">
                @foreach($featuredProperties as $property)
                    <div class="swiper-slide">
                        <div class="property-card bg-white rounded-lg shadow-lg overflow-hidden hover:shadow-xl transition-shadow h-full">
                            <div class="relative overflow-hidden h-48">
                                @if($property->photos && $property->photos->count() > 0)
                                    <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                         alt="{{ $property->name }}"
                                         class="property-image w-full h-full object-cover loading-placeholder"
                                         loading="lazy">
                                @else
                                    <div class="w-full h-full bg-gray-200 flex items-center justify-center">
                                        <i class="fas fa-image text-gray-400 text-2xl"></i>
                                    </div>
                                @endif
                                <div class="absolute top-3 right-3">
                                    <span class="bg-yellow-400 text-yellow-900 px-2 py-1 rounded text-xs font-bold">
                                        <i class="fas fa-star mr-1"></i>{{ $property->average_rating_format }}
                                    </span>
                                </div>
                            </div>
                            
                            <div class="p-4">
                                <h3 class="font-bold text-lg text-gray-900 mb-2 truncate">{{ $property->name }}</h3>
                                <p class="text-gray-600 text-sm mb-3 flex items-center">
                                    <i class="fas fa-map-marker-alt mr-2 text-blue-600"></i>
                                    {{ $property->city_name }}, {{ $property->state_name }}
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
                    </div>
                @endforeach
            </div>
        </div>
        
        <div class="text-center mt-8">
            <a href="{{ route('site.properties.index') }}" 
               class="bg-blue-600 text-white px-8 py-3 rounded-lg font-bold hover:bg-blue-700 transition">
                Ver Todas as Propriedades
            </a>
        </div>
    </div>
</section>
@endif

<!-- Parceiros e Agências -->
<section class="py-16 bg-white">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Nossos Parceiros</h2>
        <p class="text-center text-gray-600 mb-8">Trabalhamos com as melhores redes hoteleiras e agências do Brasil</p>
        
        <div class="partners-carousel swiper">
            <div class="swiper-wrapper">
                <!-- Partner logos - você pode substituir por logos reais -->
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Hotel Brasil
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-green-600 to-green-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Pousada SP
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-purple-600 to-purple-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Resort RJ
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-orange-600 to-orange-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Turismo BA
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-red-600 to-red-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Agência CE
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-teal-600 to-teal-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Hospedagem SC
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-indigo-600 to-indigo-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Resort MG
                        </div>
                    </div>
                </div>
                <div class="swiper-slide">
                    <div class="flex items-center justify-center h-20">
                        <div class="bg-gradient-to-r from-pink-600 to-pink-700 text-white px-6 py-3 rounded-lg font-bold text-lg">
                            Viagens RS
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Pacotes Especiais -->
<section id="pacotes" class="py-16 bg-gradient-to-r from-green-50 to-blue-50">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Pacotes Especiais</h2>
        
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
            <!-- Pacote Família -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden transform hover:scale-105 transition-transform">
                <div class="bg-gradient-to-r from-purple-500 to-pink-500 p-6 text-white">
                    <i class="fas fa-users text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Família</h3>
                    <p class="opacity-90">Diversão garantida para toda família</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Café da manhã incluso</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Atividades para crianças</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Desconto em atrações locais</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Cancelamento grátis</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 280</span>
                        <p class="text-gray-600 text-sm mb-4">por família/noite</p>
                        <button class="w-full bg-purple-600 text-white py-2 rounded-lg hover:bg-purple-700 transition">
                            Reservar Agora
                        </button>
                    </div>
                </div>
            </div>

            <!-- Pacote Romântico -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden transform hover:scale-105 transition-transform">
                <div class="bg-gradient-to-r from-red-500 to-pink-500 p-6 text-white">
                    <i class="fas fa-heart text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Romântico</h3>
                    <p class="opacity-90">Momentos inesquecíveis a dois</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Jantar romântico</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Spa para casais</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Champagne de cortesia</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Check-out tardio</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 450</span>
                        <p class="text-gray-600 text-sm mb-4">por casal/noite</p>
                        <button class="w-full bg-red-600 text-white py-2 rounded-lg hover:bg-red-700 transition">
                            Reservar Agora
                        </button>
                    </div>
                </div>
            </div>

            <!-- Pacote Aventura -->
            <div class="bg-white rounded-xl shadow-lg overflow-hidden transform hover:scale-105 transition-transform">
                <div class="bg-gradient-to-r from-green-500 to-teal-500 p-6 text-white">
                    <i class="fas fa-mountain text-3xl mb-4"></i>
                    <h3 class="text-xl font-bold">Pacote Aventura</h3>
                    <p class="opacity-90">Para os amantes da natureza</p>
                </div>
                <div class="p-6">
                    <ul class="space-y-3 text-gray-700 mb-6">
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Trilhas guiadas</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Equipamentos inclusos</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Guia especializado</li>
                        <li><i class="fas fa-check text-green-500 mr-2"></i>Seguro aventura</li>
                    </ul>
                    <div class="text-center">
                        <span class="text-2xl font-bold text-gray-900">A partir de R$ 320</span>
                        <p class="text-gray-600 text-sm mb-4">por pessoa/noite</p>
                        <button class="w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 transition">
                            Reservar Agora
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Popular Destinations -->
@if($popularDestinations && $popularDestinations->count() > 0)
<section class="py-16 bg-gray-50">
    <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold text-gray-900 mb-8 text-center">Destinos Populares</h2>
        
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            @foreach($popularDestinations as $destination)
                <a href="{{ route('site.properties.index', ['destination' => $destination->city_name]) }}" 
                   class="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow text-center group">
                    <i class="fas fa-city text-3xl text-blue-600 mb-3 group-hover:text-blue-700 transition-colors"></i>
                    <h3 class="font-bold text-gray-900 group-hover:text-blue-700">{{ $destination->city_name }}</h3>
                    <p class="text-gray-600 text-sm">{{ $destination->properties_count }} propriedades</p>
                </a>
            @endforeach
        </div>
    </div>
</section>
@endif

<!-- Newsletter Section -->
<section class="py-16 bg-gradient-to-r from-blue-600 to-purple-600 text-white">
    <div class="container mx-auto px-4 text-center">
        <h2 class="text-3xl font-bold mb-4">Não perca nenhuma oferta!</h2>
        <p class="text-xl mb-8 opacity-90">Receba as melhores promoções diretamente no seu email</p>
        
        <form class="max-w-md mx-auto flex">
            <input type="email" 
                   placeholder="Seu melhor email" 
                   class="flex-1 px-4 py-3 rounded-l-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-white">
            <button type="submit" 
                    class="bg-orange-500 hover:bg-orange-600 px-6 py-3 rounded-r-lg font-bold transition">
                Assinar
            </button>
        </form>
        
        <p class="text-sm mt-4 opacity-75">Sem spam. Você pode cancelar a qualquer momento.</p>
    </div>
</section>

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
<script>
// Autocomplete search functionality
document.addEventListener('DOMContentLoaded', function() {
    const destinationInput = document.getElementById('destination');
    const suggestionsDiv = document.getElementById('suggestions');
    
    if (destinationInput) {
        let timeoutId;
        
        destinationInput.addEventListener('input', function() {
            const term = this.value;
            
            clearTimeout(timeoutId);
            
            if (term.length < 2) {
                suggestionsDiv.classList.add('hidden');
                return;
            }
            
            timeoutId = setTimeout(function() {
                fetch(`/search/suggestions?term=${encodeURIComponent(term)}`)
                    .then(response => response.json())
                    .then(data => {
                        suggestionsDiv.innerHTML = '';
                        
                        if (data.length > 0) {
                            data.forEach(item => {
                                const div = document.createElement('div');
                                div.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer text-gray-800';
                                div.innerHTML = `<i class="fas fa-${item.type === 'city' ? 'city' : item.type === 'state' ? 'map' : 'home'} mr-2 text-blue-600"></i>${item.label}`;
                                
                                div.addEventListener('click', function() {
                                    destinationInput.value = item.value;
                                    suggestionsDiv.classList.add('hidden');
                                });
                                
                                suggestionsDiv.appendChild(div);
                            });
                            suggestionsDiv.classList.remove('hidden');
                        } else {
                            suggestionsDiv.classList.add('hidden');
                        }
                    })
                    .catch(error => {
                        console.error('Erro ao buscar sugestões:', error);
                        suggestionsDiv.classList.add('hidden');
                    });
            }, 300);
        });
        
        // Hide suggestions when clicking outside
        document.addEventListener('click', function(e) {
            if (!destinationInput.contains(e.target) && !suggestionsDiv.contains(e.target)) {
                suggestionsDiv.classList.add('hidden');
            }
        });
    }
    
    // Smooth scroll for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Image lazy loading fallback for older browsers
    if (!('IntersectionObserver' in window)) {
        document.querySelectorAll('[loading="lazy"]').forEach(img => {
            img.loading = 'eager';
        });
    }
});
</script>
@endpush
EOF

echo "✅ Script 09d-carousel-hero.sh criado com sucesso!"
echo ""
echo "🎠 Funcionalidades implementadas:"
echo "   ✅ Hero carousel com 3 slides de promoções"
echo "   ✅ Carrossel de propriedades em destaque"
echo "   ✅ Seção de parceiros com logos animados"
echo "   ✅ Pacotes especiais com hover effects"
echo "   ✅ Seção de newsletter"
echo "   ✅ Navigation responsiva com mobile menu"
echo ""
echo "🎨 Design Features:"
echo "   ✅ Swiper.js para carrosseis profissionais"
echo "   ✅ Auto-play e navegação por setas/dots"
echo "   ✅ Lazy loading de imagens"
echo "   ✅ Animações smooth e transitions"
echo "   ✅ Layout totalmente responsivo"
echo "   ✅ Gradientes modernos e cores vibrantes"
echo ""
echo "📱 Funcionalidades Mobile:"
echo "   ✅ Touch/swipe navigation"
echo "   ✅ Responsive breakpoints"
echo "   ✅ Menu mobile hamburger"
echo ""
echo "💡 Para executar: chmod +x 09d-carousel-hero.sh && ./09d-carousel-hero.sh"
echo ""
echo "🚀 Próximo: 10-painel-admin.sh (Dashboard administrativo)"