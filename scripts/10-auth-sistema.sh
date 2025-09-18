#!/bin/bash

# 🔐 Script 10 - Sistema de Autenticação Completo
# Vancouver-Tec Pousadas & Agências
# Implementa login, cadastro, recuperação de senha e middleware

echo "🔐 Iniciando implementação do sistema de autenticação..."

# 1. Atualizar AuthController Site
echo "👤 Criando AuthController completo..."
cat > app/Http/Controllers/Site/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\Registered;
use Illuminate\Validation\Rules;

class AuthController extends Controller
{
    public function showLogin()
    {
        return view('site.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ], [
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido',
            'password.required' => 'A senha é obrigatória'
        ]);

        $credentials = $request->only('email', 'password');
        $remember = $request->boolean('remember');

        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();

            $user = Auth::user();
            
            // Redirecionar baseado no tipo de usuário
            if ($user->role === 'admin') {
                return redirect()->intended(route('admin.dashboard'))->with('success', 'Login realizado com sucesso!');
            } else {
                return redirect()->intended(route('client.dashboard'))->with('success', 'Bem-vindo de volta!');
            }
        }

        return back()->withErrors([
            'email' => 'As credenciais não correspondem aos nossos registros.',
        ])->onlyInput('email');
    }

    public function showRegister()
    {
        return view('site.auth.register');
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'phone' => 'nullable|string|max:20',
            'terms' => 'required|accepted'
        ], [
            'name.required' => 'O nome é obrigatório',
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido',
            'email.unique' => 'Este email já está cadastrado',
            'password.required' => 'A senha é obrigatória',
            'password.confirmed' => 'As senhas não coincidem',
            'terms.accepted' => 'Você deve aceitar os termos de uso'
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone,
            'role' => 'client',
            'active' => true
        ]);

        event(new Registered($user));

        Auth::login($user);

        return redirect(route('client.dashboard'))->with('success', 'Conta criada com sucesso!');
    }

    public function showForgotPassword()
    {
        return view('site.auth.forgot-password');
    }

    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email'
        ], [
            'email.required' => 'O email é obrigatório',
            'email.email' => 'Digite um email válido'
        ]);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        if ($status === Password::RESET_LINK_SENT) {
            return back()->with('status', 'Link de recuperação enviado para seu email!');
        }

        return back()->withErrors(['email' => 'Não encontramos um usuário com este email.']);
    }

    public function showResetPassword(Request $request)
    {
        return view('site.auth.reset-password', [
            'token' => $request->token,
            'email' => $request->email
        ]);
    }

    public function resetPassword(Request $request)
    {
        $request->validate([
            'token' => 'required',
            'email' => 'required|email',
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ], [
            'email.required' => 'O email é obrigatório',
            'password.required' => 'A senha é obrigatória',
            'password.confirmed' => 'As senhas não coincidem'
        ]);

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => Hash::make($password)
                ]);

                $user->save();
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return redirect()->route('login')->with('status', 'Senha alterada com sucesso!');
        }

        return back()->withErrors(['email' => 'Token inválido ou expirado.']);
    }

    public function logout(Request $request)
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('site.home')->with('success', 'Logout realizado com sucesso!');
    }
}
EOF

# 2. Criar Middleware de autenticação
echo "🛡️ Criando middleware de autenticação..."
cat > app/Http/Middleware/CheckRole.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CheckRole
{
    public function handle(Request $request, Closure $next, string $role)
    {
        if (!Auth::check()) {
            return redirect()->route('login');
        }

        if (Auth::user()->role !== $role) {
            abort(403, 'Acesso negado.');
        }

        return $next($request);
    }
}
EOF

# 3. Atualizar rotas web.php
echo "🌐 Atualizando rotas de autenticação..."
cat > routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\HomeController;
use App\Http\Controllers\Site\PropertyController;
use App\Http\Controllers\Site\BookingController;
use App\Http\Controllers\Site\AuthController;
use App\Http\Controllers\Client\DashboardController as ClientDashboard;
use App\Http\Controllers\Admin\DashboardController as AdminDashboard;

// Rotas do Site Público
Route::name('site.')->group(function () {
    Route::get('/', [HomeController::class, 'index'])->name('home');
    Route::get('/properties', [PropertyController::class, 'index'])->name('properties.index');
    Route::get('/properties/{id}', [PropertyController::class, 'show'])->name('properties.show');
    Route::get('/search/suggestions', [PropertyController::class, 'suggestions'])->name('search.suggestions');
});

// Rotas de Autenticação
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
    Route::get('/forgot-password', [AuthController::class, 'showForgotPassword'])->name('password.request');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('password.email');
    Route::get('/reset-password/{token}', [AuthController::class, 'showResetPassword'])->name('password.reset');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.update');
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});

// Rotas protegidas para Clientes
Route::middleware(['auth', App\Http\Middleware\CheckRole::class.':client'])->prefix('client')->name('client.')->group(function () {
    Route::get('/dashboard', [ClientDashboard::class, 'index'])->name('dashboard');
    Route::get('/bookings', [ClientDashboard::class, 'bookings'])->name('bookings');
    Route::get('/profile', [ClientDashboard::class, 'profile'])->name('profile');
    Route::put('/profile', [ClientDashboard::class, 'updateProfile'])->name('profile.update');
});

// Rotas protegidas para Administradores
Route::middleware(['auth', App\Http\Middleware\CheckRole::class.':admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboard::class, 'index'])->name('dashboard');
    Route::get('/properties', [AdminDashboard::class, 'properties'])->name('properties');
    Route::get('/bookings', [AdminDashboard::class, 'bookings'])->name('bookings');
    Route::get('/users', [AdminDashboard::class, 'users'])->name('users');
    Route::get('/settings', [AdminDashboard::class, 'settings'])->name('settings');
});
EOF

# 4. Criar views de autenticação
echo "🎨 Criando views de autenticação..."

# Layout base para auth
mkdir -p resources/views/site/auth
cat > resources/views/layouts/auth.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Autenticação') - Vancouver-Tec</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
        .booking-gradient { background: linear-gradient(135deg, #003580 0%, #0071c2 100%); }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header Simples -->
    <header class="bg-white shadow-sm border-b">
        <div class="container mx-auto px-4 py-4">
            <a href="{{ route('site.home') }}" class="text-2xl font-bold text-blue-800">
                <i class="fas fa-home mr-2"></i>Vancouver-Tec
            </a>
        </div>
    </header>

    <!-- Conteúdo Principal -->
    <main class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
            @yield('content')
        </div>
    </main>

    <!-- Scripts -->
    <script>
        // Show/hide password functionality
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Auto-hide alerts
        setTimeout(() => {
            const alerts = document.querySelectorAll('.alert-auto-hide');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 5000);
    </script>
    
    @stack('scripts')
</body>
</html>
EOF

# View de Login
cat > resources/views/site/auth/login.blade.php << 'EOF'
@extends('layouts.auth')

@section('title', 'Login')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Entre na sua conta</h2>
        <p class="mt-2 text-sm text-gray-600">
            Ou 
            <a href="{{ route('register') }}" class="font-medium text-blue-600 hover:text-blue-500">
                crie uma conta gratuita
            </a>
        </p>
    </div>

    <!-- Alerts -->
    @if (session('status'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg alert-auto-hide">
            <i class="fas fa-check-circle mr-2"></i>{{ session('status') }}
        </div>
    @endif

    @if (session('success'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg alert-auto-hide">
            <i class="fas fa-check-circle mr-2"></i>{{ session('success') }}
        </div>
    @endif

    <!-- Form -->
    <form class="space-y-6" action="{{ route('login') }}" method="POST">
        @csrf
        
        <!-- Email -->
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2"></i>Email
            </label>
            <input id="email" 
                   name="email" 
                   type="email" 
                   required 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('email') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10"
                   placeholder="Digite seu email"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Password -->
        <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Senha
            </label>
            <div class="relative">
                <input id="password" 
                       name="password" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border @error('password') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10"
                       placeholder="Digite sua senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password', 'password-icon')">
                    <i id="password-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
            @error('password')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Remember & Forgot -->
        <div class="flex items-center justify-between">
            <div class="flex items-center">
                <input id="remember" 
                       name="remember" 
                       type="checkbox" 
                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                <label for="remember" class="ml-2 block text-sm text-gray-900">
                    Lembrar de mim
                </label>
            </div>

            <div class="text-sm">
                <a href="{{ route('password.request') }}" class="font-medium text-blue-600 hover:text-blue-500">
                    Esqueceu sua senha?
                </a>
            </div>
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-sign-in-alt text-blue-300"></i>
                </span>
                Entrar
            </button>
        </div>

        <!-- Social Login (placeholder) -->
        <div class="mt-6">
            <div class="relative">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-300"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-2 bg-gray-50 text-gray-500">Ou continue com</span>
                </div>
            </div>

            <div class="mt-6 grid grid-cols-2 gap-3">
                <button type="button" class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                    <i class="fab fa-google text-red-500"></i>
                    <span class="ml-2">Google</span>
                </button>

                <button type="button" class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                    <i class="fab fa-facebook text-blue-600"></i>
                    <span class="ml-2">Facebook</span>
                </button>
            </div>
        </div>
    </form>
</div>
@endsection
EOF

echo "✅ Script 10-auth-sistema.sh criado com sucesso!"
echo ""
echo "📋 Sistema implementado:"
echo "   ✅ AuthController completo com validações"
echo "   ✅ Middleware CheckRole para controle de acesso"
echo "   ✅ Rotas de autenticação organizadas"
echo "   ✅ Layout auth.blade.php responsivo"
echo "   ✅ View de login completa"
echo ""
echo "🔄 Próximos passos:"
echo "   1. chmod +x 10-auth-sistema.sh && ./10-auth-sistema.sh"
echo "   2. Aguardar 'continuar' para views de registro e recuperação"
echo ""
echo "⚠️ Este script tem mais de 300 linhas, vou dividir em partes."
echo "Esta é a Parte A - Aguarde o 'continuar' para a Parte B!"