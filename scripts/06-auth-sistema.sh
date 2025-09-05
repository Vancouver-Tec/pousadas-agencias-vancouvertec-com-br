#!/bin/bash

# ===========================================
# SISTEMA DE AUTENTICAÇÃO - Sistema Pousadas
# Vancouver-Tec - Auth completo + Views (PARTE 1)
# ===========================================

echo "🔐 Criando sistema de autenticação completo..."

# ===========================================
# ATUALIZAR AUTHCONTROLLER
# ===========================================

echo "🎮 Atualizando AuthController..."
cat > app/Http/Controllers/Site/AuthController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function showLogin()
    {
        if (Auth::check()) {
            return $this->redirectToDashboard();
        }
        
        return view('auth.login');
    }
    
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|min:6',
        ], [
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Digite um e-mail válido.',
            'password.required' => 'A senha é obrigatória.',
            'password.min' => 'A senha deve ter pelo menos 6 caracteres.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput($request->only('email'));
        }

        $credentials = $request->only('email', 'password');
        $remember = $request->boolean('remember');

        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();
            
            return $this->redirectToDashboard()
                ->with('success', 'Login realizado com sucesso!');
        }

        return back()
            ->withErrors(['email' => 'Credenciais inválidas.'])
            ->withInput($request->only('email'));
    }
    
    public function showRegister()
    {
        if (Auth::check()) {
            return $this->redirectToDashboard();
        }
        
        return view('auth.register');
    }
    
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'phone' => 'nullable|string|max:20',
            'document' => 'nullable|string|max:20',
            'birth_date' => 'nullable|date',
        ], [
            'name.required' => 'O nome é obrigatório.',
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Digite um e-mail válido.',
            'email.unique' => 'Este e-mail já está sendo usado.',
            'password.required' => 'A senha é obrigatória.',
            'password.min' => 'A senha deve ter pelo menos 6 caracteres.',
            'password.confirmed' => 'A confirmação da senha não confere.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput($request->except(['password', 'password_confirmation']));
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'client',
            'phone' => $request->phone,
            'document' => $request->document,
            'birth_date' => $request->birth_date,
            'preferred_language' => app()->getLocale(),
        ]);

        Auth::login($user);
        
        return redirect()->route('client.dashboard')
            ->with('success', 'Conta criada com sucesso! Bem-vindo(a)!');
    }
    
    public function logout(Request $request)
    {
        Auth::logout();
        
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        
        return redirect()->route('home')
            ->with('success', 'Logout realizado com sucesso!');
    }
    
    private function redirectToDashboard()
    {
        if (Auth::user()->isAdmin()) {
            return redirect()->route('admin.dashboard');
        }
        
        return redirect()->route('client.dashboard');
    }
}
EOF

# ===========================================
# LAYOUT BASE
# ===========================================

echo "🎨 Criando layout base..."
mkdir -p resources/views/layouts
cat > resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Vancouver-Tec Pousadas')</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .navbar {
            background: white;
            border-bottom: 1px solid #e0e0e0;
            padding: 12px 0;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .navbar-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: #0071c2;
            text-decoration: none;
        }
        
        .navbar-links {
            display: flex;
            gap: 20px;
            align-items: center;
        }
        
        .navbar-links a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 4px;
            transition: all 0.2s;
        }
        
        .navbar-links a:hover {
            background: #f0f0f0;
        }
        
        .btn {
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            border: 1px solid transparent;
            cursor: pointer;
            display: inline-block;
            transition: all 0.2s;
            background: none;
            font-size: 14px;
        }
        
        .btn-primary {
            background: #0071c2;
            color: white;
            border-color: #0071c2;
        }
        
        .btn-primary:hover {
            background: #005999;
            border-color: #005999;
        }
        
        .btn-secondary {
            background: transparent;
            color: #0071c2;
            border-color: #0071c2;
        }
        
        .btn-secondary:hover {
            background: #0071c2;
            color: white;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .alert {
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            transition: border-color 0.2s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #0071c2;
            box-shadow: 0 0 0 2px rgba(0,113,194,0.1);
        }
        
        .invalid-feedback {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .is-invalid {
            border-color: #dc3545;
        }
        
        .footer {
            background: #003580;
            color: white;
            text-align: center;
            padding: 40px 20px;
            margin-top: 60px;
        }
        
        @media (max-width: 768px) {
            .navbar-content {
                flex-direction: column;
                gap: 10px;
            }
            
            .navbar-links {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .container {
                padding: 10px;
            }
        }
    </style>
    @yield('styles')
</head>
<body>
    <nav class="navbar">
        <div class="navbar-content">
            <a href="{{ route('home') }}" class="logo">🏨 Vancouver-Tec</a>
            <div class="navbar-links">
                @auth
                    <span>Olá, {{ Auth::user()->name }}!</span>
                    @if(Auth::user()->isAdmin())
                        <a href="{{ route('admin.dashboard') }}">Dashboard Admin</a>
                    @else
                        <a href="{{ route('client.dashboard') }}">Minha Conta</a>
                    @endif
                    <form action="{{ route('logout') }}" method="POST" style="display: inline;">
                        @csrf
                        <button type="submit" class="btn btn-secondary">Sair</button>
                    </form>
                @else
                    <a href="{{ route('login') }}">Entrar</a>
                    <a href="{{ route('register') }}" class="btn btn-primary">Cadastrar</a>
                @endauth
            </div>
        </div>
    </nav>

    <main>
        @if(session('success'))
            <div class="container">
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            </div>
        @endif

        @if(session('error'))
            <div class="container">
                <div class="alert alert-error">
                    {{ session('error') }}
                </div>
            </div>
        @endif

        @yield('content')
    </main>

    <footer class="footer">
        <div>
            <p>&copy; {{ date('Y') }} Vancouver-Tec Pousadas. Todos os direitos reservados.</p>
            <p>Sistema de reservas para pousadas e agências de turismo.</p>
        </div>
    </footer>

    @yield('scripts')
</body>
</html>
EOF

echo "✅ AuthController e Layout base criados!"
echo ""
echo "🔄 Execute:"
echo "chmod +x 06-auth-sistema.sh && ./06-auth-sistema.sh"
echo ""
echo "🎯 Próximo: Views de login e register (06b-auth-views.sh)"