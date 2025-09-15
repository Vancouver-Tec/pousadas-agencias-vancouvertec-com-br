#!/bin/bash

# 🏨 Script 09 - Views Booking & Detalhes (Estilo Booking.com)
# Vancouver-Tec Pousadas & Agências
# Implementa páginas de detalhes, galeria, avaliações e sistema de reserva

echo "🏨 Iniciando implementação das Views de Detalhes e Reservas..."

# Criar view de detalhes da propriedade (show.blade.php)
echo "🎯 Criando view de detalhes da propriedade..."
mkdir -p resources/views/site/properties
cat > resources/views/site/properties/show.blade.php << 'EOF'
@extends('layouts.site')

@section('title', $property->name)

@section('content')
<div class="bg-white min-h-screen">
    <!-- Header da Propriedade -->
    <div class="container mx-auto px-4 py-6">
        <!-- Breadcrumb -->
        <nav class="text-sm text-gray-600 mb-4">
            <a href="{{ route('site.home') }}" class="hover:text-blue-600">Home</a>
            <span class="mx-2">></span>
            <a href="{{ route('site.properties.index') }}" class="hover:text-blue-600">Propriedades</a>
            <span class="mx-2">></span>
            <span>{{ $property->name }}</span>
        </nav>

        <!-- Título e Avaliação -->
        <div class="flex flex-col lg:flex-row lg:justify-between lg:items-start mb-6">
            <div>
                <h1 class="text-3xl font-bold text-gray-900 mb-2">{{ $property->name }}</h1>
                <div class="flex items-center mb-2">
                    @for($i = 1; $i <= 5; $i++)
                        <i class="fas fa-star {{ $i <= $property->average_rating ? 'text-yellow-400' : 'text-gray-300' }}"></i>
                    @endfor
                    <span class="ml-2 text-sm text-gray-600">
                        {{ number_format($property->average_rating, 1) }} 
                        ({{ $property->reviews->count() }} avaliações)
                    </span>
                </div>
                <p class="text-gray-600 flex items-center">
                    <i class="fas fa-map-marker-alt mr-2"></i>
                    {{ $property->address }}, {{ $property->city->name }}, {{ $property->state->name }}
                </p>
            </div>
            <div class="mt-4 lg:mt-0">
                <button class="bg-white border border-gray-300 px-4 py-2 rounded-lg hover:bg-gray-50 mr-2">
                    <i class="fas fa-heart mr-2"></i>Favoritar
                </button>
                <button class="bg-white border border-gray-300 px-4 py-2 rounded-lg hover:bg-gray-50">
                    <i class="fas fa-share mr-2"></i>Compartilhar
                </button>
            </div>
        </div>

        <!-- Galeria de Fotos -->
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-2 mb-8 max-h-96">
            @if($property->photos->count() > 0)
                <!-- Foto Principal -->
                <div class="lg:col-span-2 lg:row-span-2">
                    <img src="{{ asset('uploads/properties/' . $property->photos->first()->filename) }}" 
                         alt="{{ $property->name }}"
                         class="w-full h-full object-cover rounded-lg cursor-pointer hover:opacity-90 transition-opacity"
                         onclick="openGallery(0)">
                </div>
                
                <!-- Fotos Secundárias -->
                @foreach($property->photos->skip(1)->take(4) as $index => $photo)
                    <div class="relative {{ $loop->last && $property->photos->count() > 5 ? 'overflow-hidden' : '' }}">
                        <img src="{{ asset('uploads/properties/' . $photo->filename) }}" 
                             alt="{{ $property->name }}"
                             class="w-full h-48 object-cover rounded-lg cursor-pointer hover:opacity-90 transition-opacity"
                             onclick="openGallery({{ $index + 1 }})">
                        
                        @if($loop->last && $property->photos->count() > 5)
                            <div class="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center rounded-lg cursor-pointer"
                                 onclick="openGallery({{ $index + 1 }})">
                                <span class="text-white font-bold text-lg">+{{ $property->photos->count() - 5 }} fotos</span>
                            </div>
                        @endif
                    </div>
                @endforeach
            @else
                <!-- Placeholder se não houver fotos -->
                <div class="lg:col-span-4 bg-gray-200 rounded-lg h-96 flex items-center justify-center">
                    <div class="text-center">
                        <i class="fas fa-image text-4xl text-gray-400 mb-4"></i>
                        <p class="text-gray-500">Imagens não disponíveis</p>
                    </div>
                </div>
            @endif
        </div>

        <!-- Conteúdo Principal -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <!-- Coluna Esquerda - Detalhes -->
            <div class="lg:col-span-2">
                <!-- Tipo e Capacidade -->
                <div class="mb-8">
                    <h2 class="text-2xl font-bold mb-4">{{ $property->property_type ?? 'Propriedade' }}</h2>
                    <div class="flex items-center text-gray-600 space-x-4">
                        <span><i class="fas fa-users mr-1"></i>{{ $property->max_guests }} hóspedes</span>
                        <span><i class="fas fa-bed mr-1"></i>{{ $property->bedrooms ?? 'N/A' }} quartos</span>
                        <span><i class="fas fa-bath mr-1"></i>{{ $property->bathrooms ?? 'N/A' }} banheiros</span>
                    </div>
                </div>

                <!-- Descrição -->
                @if($property->description)
                <div class="mb-8">
                    <h3 class="text-xl font-bold mb-4">Sobre esta propriedade</h3>
                    <div class="prose max-w-none text-gray-700">
                        {!! nl2br(e($property->description)) !!}
                    </div>
                </div>
                @endif

                <!-- Comodidades -->
                @if($property->amenities)
                <div class="mb-8">
                    <h3 class="text-xl font-bold mb-4">Comodidades</h3>
                    <div class="grid grid-cols-2 gap-3">
                        @php
                            $amenities = is_string($property->amenities) ? json_decode($property->amenities, true) : $property->amenities;
                            $amenityIcons = [
                                'Wi-Fi' => 'fas fa-wifi',
                                'Piscina' => 'fas fa-swimming-pool',
                                'Estacionamento' => 'fas fa-car',
                                'Ar-condicionado' => 'fas fa-snowflake',
                                'Cozinha' => 'fas fa-utensils',
                                'TV' => 'fas fa-tv',
                                'Academia' => 'fas fa-dumbbell',
                                'Café da manhã' => 'fas fa-coffee'
                            ];
                        @endphp
                        
                        @if($amenities && is_array($amenities))
                            @foreach($amenities as $amenity)
                                <div class="flex items-center">
                                    <i class="{{ $amenityIcons[$amenity] ?? 'fas fa-check' }} text-green-600 mr-3"></i>
                                    <span class="text-gray-700">{{ $amenity }}</span>
                                </div>
                            @endforeach
                        @endif
                    </div>
                </div>
                @endif

                <!-- Localização -->
                <div class="mb-8">
                    <h3 class="text-xl font-bold mb-4">Localização</h3>
                    <div class="bg-gray-100 rounded-lg p-6">
                        <p class="text-gray-700 mb-4">
                            <i class="fas fa-map-marker-alt mr-2"></i>
                            {{ $property->address }}, {{ $property->city->name }}, {{ $property->state->name }}
                        </p>
                        <div class="bg-gray-300 h-48 rounded-lg flex items-center justify-center">
                            <span class="text-gray-500">Mapa em breve</span>
                        </div>
                    </div>
                </div>

                <!-- Avaliações -->
                <div class="mb-8">
                    <h3 class="text-xl font-bold mb-4">Avaliações dos hóspedes</h3>
                    
                    @if($property->reviews->count() > 0)
                        <!-- Resumo das avaliações -->
                        <div class="bg-blue-50 rounded-lg p-6 mb-6">
                            <div class="flex items-center justify-between mb-4">
                                <div>
                                    <span class="text-3xl font-bold text-blue-800">{{ number_format($property->average_rating, 1) }}</span>
                                    <span class="text-blue-600 ml-2">Excelente</span>
                                </div>
                                <div class="text-right">
                                    <p class="text-sm text-blue-600">{{ $property->reviews->count() }} avaliações</p>
                                </div>
                            </div>
                        </div>

                        <!-- Lista de avaliações -->
                        <div class="space-y-6">
                            @foreach($property->reviews->take(5) as $review)
                                <div class="border-b border-gray-200 pb-6">
                                    <div class="flex items-center mb-3">
                                        <div class="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center text-white font-bold mr-3">
                                            {{ strtoupper(substr($review->user->name, 0, 1)) }}
                                        </div>
                                        <div>
                                            <p class="font-semibold">{{ $review->user->name }}</p>
                                            <p class="text-sm text-gray-500">{{ $review->created_at->format('d/m/Y') }}</p>
                                        </div>
                                        <div class="ml-auto flex items-center">
                                            @for($i = 1; $i <= 5; $i++)
                                                <i class="fas fa-star {{ $i <= $review->rating ? 'text-yellow-400' : 'text-gray-300' }} text-sm"></i>
                                            @endfor
                                        </div>
                                    </div>
                                    <p class="text-gray-700">{{ $review->comment }}</p>
                                </div>
                            @endforeach
                        </div>

                        @if($property->reviews->count() > 5)
                            <button class="mt-4 text-blue-600 hover:text-blue-800 font-medium">
                                Ver todas as {{ $property->reviews->count() }} avaliações
                            </button>
                        @endif
                    @else
                        <div class="text-center py-8 bg-gray-50 rounded-lg">
                            <p class="text-gray-500">Ainda não há avaliações para esta propriedade.</p>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Coluna Direita - Reserva -->
            <div class="lg:col-span-1">
                <div class="sticky top-4">
                    <div class="border border-gray-200 rounded-lg p-6 shadow-lg bg-white">
                        <!-- Preço -->
                        <div class="mb-6">
                            <span class="text-2xl font-bold">R$ {{ number_format($property->price_per_night, 2, ',', '.') }}</span>
                            <span class="text-gray-600"> / noite</span>
                        </div>

                        <!-- Formulário de Reserva -->
                        <form id="bookingForm" class="space-y-4">
                            @csrf
                            <input type="hidden" name="property_id" value="{{ $property->id }}">
                            
                            <!-- Datas -->
                            <div class="grid grid-cols-2 gap-2">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Check-in</label>
                                    <input type="date" name="check_in" id="checkIn" 
                                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                           min="{{ date('Y-m-d') }}" required>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Check-out</label>
                                    <input type="date" name="check_out" id="checkOut"
                                           class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                           min="{{ date('Y-m-d', strtotime('+1 day')) }}" required>
                                </div>
                            </div>

                            <!-- Hóspedes -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Hóspedes</label>
                                <select name="guests" 
                                        class="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-blue-500" required>
                                    @for($i = 1; $i <= $property->max_guests; $i++)
                                        <option value="{{ $i }}">{{ $i }} {{ $i == 1 ? 'hóspede' : 'hóspedes' }}</option>
                                    @endfor
                                </select>
                            </div>

                            <!-- Resumo do Preço -->
                            <div id="priceBreakdown" class="hidden border-t pt-4 space-y-2">
                                <div class="flex justify-between">
                                    <span>R$ {{ number_format($property->price_per_night, 2, ',', '.') }} x <span id="nights">0</span> noites</span>
                                    <span id="subtotal">R$ 0,00</span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Taxa de limpeza</span>
                                    <span>R$ 50,00</span>
                                </div>
                                <div class="flex justify-between font-bold border-t pt-2">
                                    <span>Total</span>
                                    <span id="totalPrice">R$ 0,00</span>
                                </div>
                            </div>

                            <!-- Botão de Reserva -->
                            <button type="submit" 
                                    class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-lg transition-colors">
                                Reservar Agora
                            </button>
                        </form>

                        <p class="text-center text-sm text-gray-500 mt-4">
                            Você não será cobrado ainda
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal da Galeria -->
<div id="galleryModal" class="fixed inset-0 bg-black bg-opacity-90 z-50 hidden">
    <div class="flex items-center justify-center h-full">
        <button onclick="closeGallery()" class="absolute top-4 right-4 text-white text-2xl hover:text-gray-300">
            <i class="fas fa-times"></i>
        </button>
        <button onclick="prevImage()" class="absolute left-4 text-white text-2xl hover:text-gray-300">
            <i class="fas fa-chevron-left"></i>
        </button>
        <button onclick="nextImage()" class="absolute right-4 text-white text-2xl hover:text-gray-300">
            <i class="fas fa-chevron-right"></i>
        </button>
        <img id="galleryImage" class="max-w-full max-h-full object-contain">
    </div>
</div>

<script>
// Gallery functionality
let currentImageIndex = 0;
const images = @json($property->photos->pluck('filename'));

function openGallery(index) {
    currentImageIndex = index;
    showImage();
    document.getElementById('galleryModal').classList.remove('hidden');
}

function closeGallery() {
    document.getElementById('galleryModal').classList.add('hidden');
}

function showImage() {
    if (images.length > 0) {
        const img = document.getElementById('galleryImage');
        img.src = '/uploads/properties/' + images[currentImageIndex];
    }
}

function nextImage() {
    currentImageIndex = (currentImageIndex + 1) % images.length;
    showImage();
}

function prevImage() {
    currentImageIndex = (currentImageIndex - 1 + images.length) % images.length;
    showImage();
}

// Booking form functionality
document.addEventListener('DOMContentLoaded', function() {
    const checkInInput = document.getElementById('checkIn');
    const checkOutInput = document.getElementById('checkOut');
    const pricePerNight = {{ $property->price_per_night }};
    
    function updatePriceBreakdown() {
        const checkIn = new Date(checkInInput.value);
        const checkOut = new Date(checkOutInput.value);
        
        if (checkInInput.value && checkOutInput.value && checkOut > checkIn) {
            const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
            const subtotal = nights * pricePerNight;
            const cleaningFee = 50;
            const total = subtotal + cleaningFee;
            
            document.getElementById('nights').textContent = nights;
            document.getElementById('subtotal').textContent = 'R$ ' + subtotal.toLocaleString('pt-BR', {minimumFractionDigits: 2});
            document.getElementById('totalPrice').textContent = 'R$ ' + total.toLocaleString('pt-BR', {minimumFractionDigits: 2});
            document.getElementById('priceBreakdown').classList.remove('hidden');
        } else {
            document.getElementById('priceBreakdown').classList.add('hidden');
        }
    }
    
    checkInInput.addEventListener('change', function() {
        const checkIn = new Date(this.value);
        const nextDay = new Date(checkIn);
        nextDay.setDate(checkIn.getDate() + 1);
        checkOutInput.min = nextDay.toISOString().split('T')[0];
        
        if (checkOutInput.value && new Date(checkOutInput.value) <= checkIn) {
            checkOutInput.value = nextDay.toISOString().split('T')[0];
        }
        updatePriceBreakdown();
    });
    
    checkOutInput.addEventListener('change', updatePriceBreakdown);
});

// Keyboard navigation for gallery
document.addEventListener('keydown', function(e) {
    if (!document.getElementById('galleryModal').classList.contains('hidden')) {
        if (e.key === 'ArrowLeft') prevImage();
        if (e.key === 'ArrowRight') nextImage();
        if (e.key === 'Escape') closeGallery();
    }
});
</script>
@endsection
EOF

echo "✅ Script 09-site-booking.sh criado com sucesso!"
echo ""
echo "📄 Arquivos criados:"
echo "   ✅ resources/views/site/properties/show.blade.php - Página completa de detalhes"
echo ""
echo "🎯 Funcionalidades implementadas:"
echo "   ✅ Layout responsivo estilo Booking.com"
echo "   ✅ Galeria de fotos com modal"
echo "   ✅ Detalhes completos da propriedade"
echo "   ✅ Sistema de avaliações"
echo "   ✅ Formulário de reserva interativo"
echo "   ✅ Cálculo automático de preços"
echo "   ✅ Navegação por teclado na galeria"
echo ""
echo "🎨 Design Features:"
echo "   ✅ Cards de informações organizados"
echo "   ✅ Sticky sidebar com reserva"
echo "   ✅ Grid responsivo de fotos"
echo "   ✅ Modal de galeria com navegação"
echo "   ✅ Formulário interativo com validação"
echo ""
echo "💡 Para executar: chmod +x 09-site-booking.sh && ./09-site-booking.sh"
echo ""
echo "🚧 Próxima parte: 09b (se necessário) ou 10-painel-admin.sh"