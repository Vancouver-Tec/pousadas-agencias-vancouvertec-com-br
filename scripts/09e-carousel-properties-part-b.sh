#!/bin/bash

# 🏨 Script 09e-B - Carrosseis com Propriedades do Banco (Parte B)
# Vancouver-Tec Pousadas & Agências
# Views completas com carrosseis estilo Booking.com

echo "🏨 Parte B: Views com carrosseis de propriedades..."

# Criar view home completa com carrosseis
echo "🏠 Criando view home com carrosseis..."
cat > resources/views/site/home.blade.php << 'EOF'
@extends('layouts.site')

@section('title', $title)

@section('content')
<!-- Hero Carousel com banners personalizados -->
<section class="hero-carousel swiper relative">
    <div class="swiper-wrapper">
        <!-- Slide 1 - Banner Família -->
        <div class="swiper-slide" style="background: url('{{ asset('images/banners/banner-familia.svg') }}') center/cover;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Diversão em Família</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Hospedagens perfeitas para toda família se divertir</p>
                <div class="space-x-4">
                    <a href="{{ route('site.properties.index', ['guests' => '4']) }}" class="bg-white text-orange-600 px-8 py-3 rounded-lg font-bold hover:bg-orange-50 transition">
                        Ver Ofertas Família
                    </a>
                    <span class="bg-yellow-400 text-yellow-900 px-6 py-3 rounded-lg font-bold">
                        Fique 3, Pague 2!
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Slide 2 - Banner Romântico -->
        <div class="swiper-slide" style="background: url('{{ asset('images/banners/banner-romantico.svg') }}') center/cover;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Momentos Românticos</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Escapadas perfeitas para casais apaixonados</p>
                <div class="space-x-4">
                    <a href="{{ route('register') }}" class="bg-white text-purple-600 px-8 py-3 rounded-lg font-bold hover:bg-purple-50 transition">
                        Cadastrar Agora
                    </a>
                    <span class="bg-green-400 text-green-900 px-6 py-3 rounded-lg font-bold">
                        15% OFF Primeira Reserva
                    </span>
                </div>
            </div>
        </div>
        
        <!-- Slide 3 - Banner Aventura -->
        <div class="swiper-slide" style="background: url('{{ asset('images/banners/banner-aventura.svg') }}') center/cover;">
            <div class="slide-overlay"></div>
            <div class="slide-content text-white">
                <h2 class="text-4xl md:text-6xl font-bold mb-4">Aventuras Inesquecíveis</h2>
                <p class="text-xl md:text-2xl mb-6 opacity-90">Explore a natureza com todo conforto e segurança</p>
                <div class="space-x-4">
                    <a href="{{ route('site.properties.index', ['min_price' => '300']) }}" class="bg-white text-teal-600 px-8 py-3 rounded-lg font-bold hover:bg-teal-50 transition">
                        Ver Pacotes
                    </a>
                    <span class="bg-orange-400 text-orange-900 px-6 py-3 rounded-lg font-bold">
                        A partir de R$ 320
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
                <div class="relative">
                    <label for="destination" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-map-marker-alt mr-1 text-blue-600"></i>Para onde você vai?
                    </label>
                    <input type="text" id="destination" name="destination" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900 placeholder-gray-500"
                           placeholder="Cidade, região, propriedade" autocomplete="off">
                    <div id="suggestions" class="absolute z-10 w-full bg-white border border-gray-200 rounded-lg shadow-lg mt-1 hidden search-suggestions"></div>
                </div>

                <div>
                    <label for="check_in" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-in
                    </label>
                    <input type="date" id="check_in" name="check_in" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d') }}" min="{{ date('Y-m-d') }}">
                </div>

                <div>
                    <label for="check_out" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-calendar-alt mr-1 text-blue-600"></i>Check-out
                    </label>
                    <input type="date" id="check_out" name="check_out" 
                           class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900"
                           value="{{ date('Y-m-d', strtotime('+1 day')) }}" min="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>

                <div>
                    <label for="guests" class="block text-sm font-medium text-gray-800 mb-2">
                        <i class="fas fa-users mr-1 text-blue-600"></i>Hóspedes
                    </label>
                    <div class="flex">
                        <select id="guests" name="guests" 
                                class="flex-1 px-4 py-3 border border-gray-300 rounded-l-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-gray-900">
                            <option value="1">1 hóspede</option>
                            <option value="2">2 hóspedes</option>
                            <option value="3">3 hóspedes</option>
                            <option value="4">4 hóspedes</option>
                            <option value="5">5+ hóspedes</option>
                        </select>
                        <button type="submit" class="px-6 py-3 booking-blue-light text-white rounded-r-lg hover:bg-blue-700 transition-colors">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>
</section>

<!-- Procurando a estadia perfeita? -->
@if($similarProperties && $similarProperties->count() > 0)
<section class="py-12 bg-gray-50">
    <div class="container mx-auto px-4">
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-2">Procurando a estadia perfeita?</h2>
            <p class="text-gray-600">Viajantes com pesquisas similares reservaram estas opções</p>
        </div>
        
        <div class="similar-properties-carousel swiper">
            <div class="swiper-wrapper">
                @foreach($similarProperties as $property)
                    <div class="swiper-slide" style="width: 280px;">
                        <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                            <div class="relative">
                                @if($property->photos && $property->photos->count() > 0)
                                    <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                         alt="{{ $property->name }}" class="w-full h-48 object-cover">
                                @else
                                    <div class="w-full h-48 bg-gray-200 flex items-center justify-center">
                                        <i class="fas fa-image text-gray-400 text-2xl"></i>
                                    </div>
                                @endif
                                <button class="absolute top-3 right-3 bg-white bg-opacity-80 hover:bg-opacity-100 p-2 rounded-full">
                                    <i class="fas fa-heart text-gray-400 hover:text-red-500"></i>
                                </button>
                            </div>
                            
                            <div class="p-4">
                                <div class="flex items-start justify-between mb-2">
                                    <div>
                                        <span class="text-xs bg-blue-600 text-white px-2 py-1 rounded">Hotel</span>
                                        @if($property->featured)
                                            <span class="text-xs bg-orange-500 text-white px-2 py-1 rounded ml-1">Destaque</span>
                                        @endif
                                    </div>
                                    <div class="text-right">
                                        <div class="flex items-center">
                                            <span class="bg-blue-600 text-white text-sm font-bold px-2 py-1 rounded">{{ $property->average_rating_format }}</span>
                                            <span class="text-xs text-gray-600 ml-1">Muito bom</span>
                                        </div>
                                        <p class="text-xs text-gray-500">{{ $property->reviews->count() }} avaliações</p>
                                    </div>
                                </div>
                                
                                <h3 class="font-bold text-gray-900 mb-1 truncate">{{ $property->name }}</h3>
                                <p class="text-sm text-gray-600 mb-3">{{ $property->city_name }}, {{ $property->state_name }}</p>
                                
                                <div class="text-right">
                                    <span class="text-lg font-bold">R$ {{ number_format($property->price_per_night, 0, ',', '.') }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
            
            <div class="flex justify-center mt-6 space-x-2">
                <button class="similar-prev bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-left text-blue-600"></i>
                </button>
                <button class="similar-next bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-right text-blue-600"></i>
                </button>
            </div>
        </div>
    </div>
</section>
@endif
EOF

echo "Continuando view home..."
cat >> resources/views/site/home.blade.php << 'EOF'

<!-- Ofertas para o fim de semana -->
@if($weekendOffers && $weekendOffers->count() > 0)
<section class="py-12">
    <div class="container mx-auto px-4">
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-2">Ofertas para o fim de semana</h2>
            <p class="text-gray-600">Economize em estadias entre {{ date('d \d\e F', strtotime('next friday')) }} - {{ date('d \d\e F', strtotime('next sunday')) }}</p>
        </div>
        
        <div class="weekend-offers-carousel swiper">
            <div class="swiper-wrapper">
                @foreach($weekendOffers as $property)
                    <div class="swiper-slide" style="width: 280px;">
                        <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                            <div class="relative">
                                @if($property->photos && $property->photos->count() > 0)
                                    <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                         alt="{{ $property->name }}" class="w-full h-48 object-cover">
                                @else
                                    <div class="w-full h-48 bg-gray-200 flex items-center justify-center">
                                        <i class="fas fa-image text-gray-400 text-2xl"></i>
                                    </div>
                                @endif
                                <button class="absolute top-3 right-3 bg-white bg-opacity-80 hover:bg-opacity-100 p-2 rounded-full">
                                    <i class="fas fa-heart text-gray-400 hover:text-red-500"></i>
                                </button>
                                <div class="absolute top-3 left-3">
                                    <span class="bg-green-600 text-white text-xs font-bold px-2 py-1 rounded">Promoção de Férias</span>
                                </div>
                            </div>
                            
                            <div class="p-4">
                                <div class="flex items-start justify-between mb-2">
                                    <div>
                                        <span class="text-xs bg-blue-600 text-white px-2 py-1 rounded">Hotel</span>
                                    </div>
                                    <div class="text-right">
                                        <div class="flex items-center">
                                            <span class="bg-blue-600 text-white text-sm font-bold px-2 py-1 rounded">{{ $property->average_rating_format }}</span>
                                            <span class="text-xs text-gray-600 ml-1">Muito bom</span>
                                        </div>
                                        <p class="text-xs text-gray-500">{{ $property->reviews->count() }} avaliações</p>
                                    </div>
                                </div>
                                
                                <h3 class="font-bold text-gray-900 mb-1 truncate">{{ $property->name }}</h3>
                                <p class="text-sm text-gray-600 mb-1">{{ $property->city_name }}, {{ $property->state_name }}</p>
                                <p class="text-xs text-green-600 font-medium mb-3">Fabuloso • {{ $property->reviews->count() }} avaliações</p>
                                
                                <div class="text-right">
                                    <p class="text-xs text-gray-500">2 diárias</p>
                                    <div class="flex items-center justify-end space-x-2">
                                        <span class="text-sm text-gray-500 line-through">R$ {{ number_format($property->original_price, 0, ',', '.') }}</span>
                                        <span class="text-lg font-bold">R$ {{ number_format($property->price_per_night, 0, ',', '.') }}</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
            
            <div class="flex justify-center mt-6 space-x-2">
                <button class="weekend-prev bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-left text-blue-600"></i>
                </button>
                <button class="weekend-next bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-right text-blue-600"></i>
                </button>
            </div>
        </div>
    </div>
</section>
@endif

<!-- Fique em uma acomodação exclusiva -->
@if($exclusiveProperties && $exclusiveProperties->count() > 0)
<section class="py-12 bg-gray-50">
    <div class="container mx-auto px-4">
        <div class="mb-8">
            <h2 class="text-2xl font-bold text-gray-900 mb-2">Fique em uma acomodação exclusiva</h2>
            <p class="text-gray-600">Castelos, villas, barcos, iglus... temos de tudo!</p>
        </div>
        
        <div class="exclusive-properties-carousel swiper">
            <div class="swiper-wrapper">
                @foreach($exclusiveProperties as $property)
                    <div class="swiper-slide" style="width: 280px;">
                        <div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
                            <div class="relative">
                                @if($property->photos && $property->photos->count() > 0)
                                    <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                                         alt="{{ $property->name }}" class="w-full h-48 object-cover">
                                @else
                                    <div class="w-full h-48 bg-gray-200 flex items-center justify-center">
                                        <i class="fas fa-image text-gray-400 text-2xl"></i>
                                    </div>
                                @endif
                                <button class="absolute top-3 right-3 bg-white bg-opacity-80 hover:bg-opacity-100 p-2 rounded-full">
                                    <i class="fas fa-heart text-gray-400 hover:text-red-500"></i>
                                </button>
                                <div class="absolute top-3 left-3">
                                    <span class="bg-orange-600 text-white text-xs font-bold px-2 py-1 rounded">
                                        <i class="fas fa-camera mr-1"></i>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="p-4">
                                <h3 class="font-bold text-gray-900 mb-1 truncate">{{ $property->name }}</h3>
                                <p class="text-sm text-gray-600 mb-3">{{ $property->city_name }}, {{ $property->state_name }}</p>
                                
                                <div class="flex items-center mb-3">
                                    <span class="bg-blue-600 text-white text-sm font-bold px-2 py-1 rounded mr-2">{{ $property->average_rating_format }}</span>
                                    <span class="text-sm text-gray-600">
                                        @if($property->average_rating >= 9)
                                            Excepcional
                                        @elseif($property->average_rating >= 8)
                                            Fabuloso
                                        @else
                                            Muito bom
                                        @endif
                                    </span>
                                </div>
                                <p class="text-xs text-gray-500 mb-3">{{ $property->reviews->count() }} avaliações</p>
                                
                                <div class="text-right">
                                    <span class="text-lg font-bold">A partir de R$ {{ number_format($property->price_per_night, 0, ',', '.') }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
            
            <div class="flex justify-center mt-6 space-x-2">
                <button class="exclusive-prev bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-left text-blue-600"></i>
                </button>
                <button class="exclusive-next bg-white border border-gray-300 p-2 rounded-full hover:bg-blue-50">
                    <i class="fas fa-chevron-right text-blue-600"></i>
                </button>
            </div>
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
            <input type="email" placeholder="Seu melhor email" 
                   class="flex-1 px-4 py-3 rounded-l-lg text-gray-900 focus:outline-none focus:ring-2 focus:ring-white">
            <button type="submit" class="bg-orange-500 hover:bg-orange-600 px-6 py-3 rounded-r-lg font-bold transition">
                Assinar
            </button>
        </form>
        
        <p class="text-sm mt-4 opacity-75">Sem spam. Você pode cancelar a qualquer momento.</p>
    </div>
</section>
@endsection

@push('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Autocomplete search
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
                        }
                    });
            }, 300);
        });
    }
    
    // Initialize carousels
    if (document.querySelector('.similar-properties-carousel')) {
        new Swiper('.similar-properties-carousel', {
            slidesPerView: 'auto',
            spaceBetween: 16,
            navigation: { nextEl: '.similar-next', prevEl: '.similar-prev' }
        });
    }
    
    if (document.querySelector('.weekend-offers-carousel')) {
        new Swiper('.weekend-offers-carousel', {
            slidesPerView: 'auto',
            spaceBetween: 16,
            navigation: { nextEl: '.weekend-next', prevEl: '.weekend-prev' }
        });
    }
    
    if (document.querySelector('.exclusive-properties-carousel')) {
        new Swiper('.exclusive-properties-carousel', {
            slidesPerView: 'auto',
            spaceBetween: 16,
            navigation: { nextEl: '.exclusive-next', prevEl: '.exclusive-prev' }
        });
    }
});
</script>
@endpush
EOF

echo "✅ Script 09e-carousel-properties-part-b.sh criado!"
echo ""
echo "🏨 Parte B implementada:"
echo "   ✅ View home.blade.php com 3 carrosseis de propriedades"
echo "   ✅ Cards estilo Booking.com com badges e avaliações"
echo "   ✅ Sistema de preços riscados para ofertas"
echo "   ✅ Botões de favoritar e navegação"
echo "   ✅ JavaScript para carrosseis e autocomplete"
echo ""
echo "🎨 Carrosseis implementados:"
echo "   ✅ 'Procurando a estadia perfeita?' - propriedades similares"
echo "   ✅ 'Ofertas para o fim de semana' - com descontos"
echo "   ✅ 'Acomodação exclusiva' - propriedades premium"
echo ""
echo "💡 Para executar: chmod +x 09e-carousel-properties-part-b.sh && ./09e-carousel-properties-part-b.sh"
echo ""
echo "🚀 Execute as duas partes em sequência:"
echo "   1. ./09e-carousel-properties-part-a.sh"
echo "   2. ./09e-carousel-properties-part-b.sh"
echo ""
echo "📱 Pronto! Página inicial completa com carrosseis estilo Booking.com!"