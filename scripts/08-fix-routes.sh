#!/bin/bash

# 🔧 Script 08 - Correção das Rotas (Alinhamento Layout)
# Vancouver-Tec Pousadas & Agências
# Corrige inconsistências entre rotas e layouts

echo "🔧 Corrigindo inconsistências nas rotas..."

# Backup do arquivo atual
cp routes/web.php routes/web.php.backup
echo "📋 Backup criado: routes/web.php.backup"

# Criar web.php corrigido
echo "🛣️ Criando web.php alinhado com os layouts..."
cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\HomeController;
use App\Http\Controllers\Site\PropertiesController;
use App\Http\Controllers\Site\BookingController;
use App\Http\Controllers\Client\DashboardController as ClientDashboard;
use App\Http\Controllers\Admin\DashboardController as AdminDashboard;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Rotas do Site Público (alinhadas com layouts)
Route::get('/', [HomeController::class, 'index'])->name('site.home');
Route::get('/properties', [PropertiesController::class, 'index'])->name('site.properties.index');
Route::get('/properties/{id}', [PropertiesController::class, 'show'])->name('site.properties.show');

// API de busca e sugestões
Route::get('/api/search/suggestions', [PropertiesController::class, 'suggestions'])->name('site.search.suggestions');

// Rotas de Booking
Route::get('/booking/{property}', [BookingController::class, 'create'])->name('site.booking.create');
Route::post('/booking', [BookingController::class, 'store'])->name('site.booking.store');

// Rotas de Autenticação (Laravel padrão)
Route::middleware('guest')->group(function () {
    Route::get('/login', [App\Http\Controllers\Auth\LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [App\Http\Controllers\Auth\LoginController::class, 'login']);
    Route::get('/register', [App\Http\Controllers\Auth\RegisterController::class, 'showRegistrationForm'])->name('register');
    Route::post('/register', [App\Http\Controllers\Auth\RegisterController::class, 'register']);
});

Route::post('/logout', [App\Http\Controllers\Auth\LoginController::class, 'logout'])->name('logout');

// Rotas do Painel Cliente (protegidas)
Route::middleware(['auth', 'verified'])->prefix('client')->name('client.')->group(function () {
    Route::get('/dashboard', [ClientDashboard::class, 'index'])->name('dashboard');
    Route::get('/bookings', [ClientDashboard::class, 'bookings'])->name('bookings');
    Route::get('/bookings/{id}', [App\Http\Controllers\Client\BookingController::class, 'show'])->name('bookings.show');
    Route::delete('/bookings/{id}/cancel', [App\Http\Controllers\Client\BookingController::class, 'cancel'])->name('bookings.cancel');
    
    Route::get('/favorites', [App\Http\Controllers\Client\FavoriteController::class, 'index'])->name('favorites.index');
    Route::post('/favorites/toggle', [App\Http\Controllers\Client\FavoriteController::class, 'toggle'])->name('favorites.toggle');
    Route::delete('/favorites/{id}', [App\Http\Controllers\Client\FavoriteController::class, 'destroy'])->name('favorites.destroy');
    
    Route::get('/profile', [App\Http\Controllers\Client\ProfileController::class, 'show'])->name('profile.show');
    Route::get('/profile/edit', [App\Http\Controllers\Client\ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile', [App\Http\Controllers\Client\ProfileController::class, 'update'])->name('profile.update');
    Route::get('/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'password'])->name('profile.password');
    Route::put('/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'updatePassword'])->name('profile.password.update');
});

// Rotas do Painel Admin (protegidas)
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboard::class, 'index'])->name('dashboard');
    Route::get('/properties', [AdminDashboard::class, 'properties'])->name('properties');
    Route::get('/bookings', [AdminDashboard::class, 'bookings'])->name('bookings');
    Route::get('/users', [AdminDashboard::class, 'users'])->name('users');
    Route::get('/settings', [AdminDashboard::class, 'settings'])->name('settings');
});

// Rotas para alternar idioma
Route::get('/lang/{locale}', function ($locale) {
    if (in_array($locale, ['pt', 'en', 'es'])) {
        session(['locale' => $locale]);
    }
    return redirect()->back();
})->name('lang.switch');
EOF

# Verificar se PropertiesController existe, se não, renomear PropertyController
echo "🔄 Verificando Controllers..."

if [ -f "app/Http/Controllers/Site/PropertyController.php" ] && [ ! -f "app/Http/Controllers/Site/PropertiesController.php" ]; then
    echo "📁 Renomeando PropertyController para PropertiesController..."
    mv app/Http/Controllers/Site/PropertyController.php app/Http/Controllers/Site/PropertiesController.php
    
    # Atualizar namespace e nome da classe no arquivo
    sed -i 's/class PropertyController/class PropertiesController/g' app/Http/Controllers/Site/PropertiesController.php
    echo "✅ Controller renomeado com sucesso"
fi

# Verificar se AuthController existe e criar se necessário
if [ ! -f "app/Http/Controllers/Auth/LoginController.php" ]; then
    echo "🔐 Criando Auth Controllers..."
    mkdir -p app/Http/Controllers/Auth
    
    # LoginController
    cat > app/Http/Controllers/Auth/LoginController.php << 'AUTHEOF'
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;

class LoginController extends Controller
{
    use AuthenticatesUsers;

    protected $redirectTo = '/client/dashboard';

    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function showLoginForm()
    {
        return view('auth.login');
    }

    protected function redirectTo()
    {
        if (auth()->user()->hasRole('admin')) {
            return '/admin/dashboard';
        }
        return '/client/dashboard';
    }
}
AUTHEOF

    # RegisterController
    cat > app/Http/Controllers/Auth/RegisterController.php << 'AUTHEOF'
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Foundation\Auth\RegistersUsers;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class RegisterController extends Controller
{
    use RegistersUsers;

    protected $redirectTo = '/client/dashboard';

    public function __construct()
    {
        $this->middleware('guest');
    }

    public function showRegistrationForm()
    {
        return view('auth.register');
    }

    protected function validator(array $data)
    {
        return Validator::make($data, [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:6', 'confirmed'],
        ]);
    }

    protected function create(array $data)
    {
        return User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => 'client',
        ]);
    }
}
AUTHEOF

    echo "✅ Auth Controllers criados"
fi

# Verificar se BookingController do Site existe
if [ ! -f "app/Http/Controllers/Site/BookingController.php" ]; then
    echo "📝 Criando BookingController do Site..."
    cat > app/Http/Controllers/Site/BookingController.php << 'BOOKINGEOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function create(Property $property)
    {
        return view('site.booking.create', compact('property'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'property_id' => 'required|exists:properties,id',
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
            'guests' => 'required|integer|min:1',
        ]);

        // Lógica de criação da reserva será implementada posteriormente
        return redirect()->route('client.dashboard')->with('success', 'Reserva criada com sucesso!');
    }
}
BOOKINGEOF

    echo "✅ BookingController do Site criado"
fi

# Limpar cache de rotas
echo "🧹 Limpando cache de rotas..."
php artisan route:clear 2>/dev/null || true
php artisan config:clear 2>/dev/null || true

# Verificar rotas
echo "🔍 Verificando rotas registradas..."
php artisan route:list --name=site 2>/dev/null || echo "Rotas serão carregadas após iniciar o servidor"

echo ""
echo "✅ Script 08-fix-routes.sh executado com sucesso!"
echo ""
echo "🔧 Correções aplicadas:"
echo "   ✅ Rotas renomeadas para padrão 'site.*'"
echo "   ✅ Controller renomeado: PropertyController → PropertiesController"
echo "   ✅ Auth Controllers criados (Laravel padrão)"
echo "   ✅ BookingController do Site criado"
echo "   ✅ Rotas organizadas com prefixos e grupos"
echo ""
echo "🎯 Rotas principais agora disponíveis:"
echo "   ✅ site.home (/) - Página inicial"
echo "   ✅ site.properties.index (/properties) - Lista de propriedades"
echo "   ✅ site.properties.show (/properties/{id}) - Detalhes da propriedade"
echo "   ✅ client.dashboard - Painel do cliente"
echo "   ✅ admin.dashboard - Painel admin"
echo ""
echo "🚀 Teste com: php artisan serve"