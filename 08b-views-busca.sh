# Criar JavaScript para funcionalidades interativas
echo "⚡ Criando JavaScript para busca..."
mkdir -p public/js
cat > public/js/search.js << 'EOF'
// Sistema de Busca e Filtros - Vancouver-Tec

// Autocomplete de destinos
let suggestionsTimeout;
const destinationInput = document.getElementById('destination');
const suggestionsDiv = document.getElementById('suggestions');

if (destinationInput) {
    destinationInput.addEventListener('input', function() {
        clearTimeout(suggestionsTimeout);
        const term = this.value.trim();
        
        if (term.length < 2) {
            suggestionsDiv.classList.add('hidden');
            return;
        }

        suggestionsTimeout = setTimeout(() => {
            fetch(`/api/search/suggestions?term=${encodeURIComponent(term)}`)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.data.length > 0) {
                        showSuggestions(data.data);
                    } else {
                        suggestionsDiv.classList.add('hidden');
                    }
                })
                .catch(error => {
                    console.error('Erro ao buscar sugestões:', error);
                });
        }, 300);
    });

    // Esconder sugestões ao clicar fora
    document.addEventListener('click', function(e) {
        if (!destinationInput.contains(e.target) && !suggestionsDiv.contains(e.target)) {
            suggestionsDiv.classList.add('hidden');
        }
    });
}

function showSuggestions(suggestions) {
    suggestionsDiv.innerHTML = '';
    
    suggestions.forEach(suggestion => {
        const div = document.createElement('div');
        div.className = 'px-4 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 last:border-b-0';
        
        const icon = getIconForType(suggestion.type);
        div.innerHTML = `
            <i class="${icon} mr-2 text-gray-500"></i>
            ${suggestion.label}
        `;
        
        div.addEventListener('click', function() {
            destinationInput.value = suggestion.value;
            suggestionsDiv.classList.add('hidden');
        });
        
        suggestionsDiv.appendChild(div);
    });
    
    suggestionsDiv.classList.remove('hidden');
}

function getIconForType(type) {
    const icons = {
        'city': 'fas fa-city',
        'state': 'fas fa-map',
        'property': 'fas fa-home'
    };
    return icons[type] || 'fas fa-map-marker-alt';
}

// Toggle filtros avançados
function toggleFilters() {
    const filters = document.getElementById('advancedFilters');
    if (filters.classList.contains('hidden')) {
        filters.classList.remove('hidden');
    } else {
        filters.classList.add('hidden');
    }
}

// Atualizar ordenação
function updateSort(sortValue) {
    const url = new URL(window.location);
    url.searchParams.set('sort', sortValue);
    window.location = url;
}

// Configurar datas mínimas
const today = new Date().toISOString().split('T')[0];
const checkInInput = document.querySelector('input[name="check_in"]');
const checkOutInput = document.querySelector('input[name="check_out"]');

if (checkInInput) {
    checkInInput.setAttribute('min', today);
    checkInInput.addEventListener('change', function() {
        if (checkOutInput && this.value) {
            const checkIn = new Date(this.value);
            const nextDay = new Date(checkIn);
            nextDay.setDate(checkIn.getDate() + 1);
            checkOutInput.setAttribute('min', nextDay.toISOString().split('T')[0]);
            
            if (checkOutInput.value && new Date(checkOutInput.value) <= checkIn) {
                checkOutInput.value = nextDay.toISOString().split('T')[0];
            }
        }
    });
}

// Loading state no formulário
const searchForm = document.getElementById('searchForm');
if (searchForm) {
    searchForm.addEventListener('submit', function() {
        const submitBtn = this.querySelector('button[type="submit"]');
        if (submitBtn) {
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Buscando...';
            submitBtn.disabled = true;
        }
    });
}

// Filtro rápido por preço (slider)
function createPriceSlider() {
    const minPriceInput = document.querySelector('input[name="min_price"]');
    const maxPriceInput = document.querySelector('input[name="max_price"]');
    
    if (minPriceInput && maxPriceInput) {
        let timeout;
        
        [minPriceInput, maxPriceInput].forEach(input => {
            input.addEventListener('input', function() {
                clearTimeout(timeout);
                timeout = setTimeout(() => {
                    updatePriceFilter();
                }, 1000);
            });
        });
    }
}

function updatePriceFilter() {
    // Auto-submit form após mudança de preço (opcional)
    // document.getElementById('searchForm').submit();
}

// Inicializar funcionalidades
document.addEventListener('DOMContentLoaded', function() {
    createPriceSlider();
    
    // Marcar filtros ativos visualmente
    markActiveFilters();
});

function markActiveFilters() {
    const form = document.getElementById('searchForm');
    if (!form) return;
    
    const formData = new FormData(form);
    let hasActiveFilters = false;
    
    for (let [key, value] of formData.entries()) {
        if (value && !['destination', 'check_in', 'check_out', 'guests'].includes(key)) {
            hasActiveFilters = true;
            break;
        }
    }
    
    const filterButton = document.querySelector('[onclick="toggleFilters()"]');
    if (filterButton && hasActiveFilters) {
        filterButton.classList.add('text-blue-800', 'font-bold');
        filterButton.innerHTML = '<i class="fas fa-filter mr-2"></i>Filtros Ativos';
    }
}
EOF

# Criar imagem placeholder para propriedades sem foto
echo "🖼️ Criando imagem placeholder..."
mkdir -p public/images
cat > public/images/property-placeholder.svg << 'EOF'
<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f3f4f6"/>
  <rect x="150" y="100" width="100" height="80" fill="#d1d5db" rx="8"/>
  <rect x="160" y="110" width="80" height="60" fill="#9ca3af" rx="4"/>
  <circle cx="175" cy="125" r="8" fill="#6b7280"/>
  <text x="200" y="220" font-family="Arial, sans-serif" font-size="14" fill="#6b7280" text-anchor="middle">Imagem não disponível</text>
</svg>
EOF

# Atualizar HomeController para incluir busca na homepage
echo "🏠 Atualizando HomeController..."
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
EOF

echo "✅ Script 08b-views-busca.sh criado com sucesso!"
echo ""
echo "📁 Arquivos criados:"
echo "   ✅ resources/views/site/properties/index.blade.php - Página de busca completa"
echo "   ✅ public/js/search.js - JavaScript interativo"
echo "   ✅ public/images/property-placeholder.svg - Placeholder para imagens"
echo "   ✅ app/Http/Controllers/Site/HomeController.php - Homepage atualizada"
echo ""
echo "🔍 Funcionalidades das Views:"
echo "   ✅ Layout responsivo estilo Booking.com"
echo "   ✅ Formulário de busca principal"
echo "   ✅ Filtros avançados expansíveis"
echo "   ✅ Autocomplete de destinos"
echo "   ✅ Cards de propriedades otimizados"
echo "   ✅ Sistema de ordenação"
echo "   ✅ Paginação automática"
echo "   ✅ Sidebar com destinos populares"
echo "   ✅ Estado vazio (sem resultados)"
echo ""
echo "🎨 Design Features:"
echo "   ✅ Cores oficiais (#003580, #0071c2)"
echo "   ✅ Totalmente responsivo"
echo "   ✅ Interações suaves"
echo "   ✅ Loading states"
echo ""
echo "💡 Para executar: chmod +x 08b-views-busca.sh && ./08b-views-busca.sh"
echo ""
echo "🎯 Próximo script: 09-site-booking.sh (Views detalhes + reserva)"