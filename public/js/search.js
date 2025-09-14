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
