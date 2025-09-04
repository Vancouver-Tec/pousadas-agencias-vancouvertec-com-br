#!/bin/bash

# ===========================================
# MIDDLEWARES - Sistema Pousadas
# Vancouver-Tec - Criar middlewares essenciais
# ===========================================

echo "🚀 Criando middlewares..."

# Criar LanguageMiddleware
echo "🌍 Criando LanguageMiddleware..."
cat > app/Http/Middleware/LanguageMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Session;

class LanguageMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $locale = Session::get('locale', config('app.locale'));
        
        if (in_array($locale, ['pt', 'en', 'es'])) {
            App::setLocale($locale);
        }
        
        return $next($request);
    }
}
EOF

# Criar ClientMiddleware
echo "👤 Criando ClientMiddleware..."
cat > app/Http/Middleware/ClientMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ClientMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (!Auth::check()) {
            return redirect()->route('login');
        }
        
        if (Auth::user()->role !== 'client') {
            abort(403, 'Acesso negado');
        }
        
        return $next($request);
    }
}
EOF

# Criar AdminMiddleware
echo "🔒 Criando AdminMiddleware..."
cat > app/Http/Middleware/AdminMiddleware.php << 'EOF'
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (!Auth::check()) {
            return redirect()->route('login');
        }
        
        if (Auth::user()->role !== 'admin') {
            abort(403, 'Acesso negado');
        }
        
        return $next($request);
    }
}
EOF

# Atualizar bootstrap/app.php para registrar middlewares
echo "⚙️ Atualizando bootstrap/app.php..."
cat > bootstrap/app.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->web(append: [
            \App\Http\Middleware\LanguageMiddleware::class,
        ]);
        
        $middleware->alias([
            'client' => \App\Http\Middleware\ClientMiddleware::class,
            'admin' => \App\Http\Middleware\AdminMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

# Criar Model User básico
echo "👥 Criando Model User..."
cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
        'document',
        'birth_date',
        'address',
        'city',
        'state',
        'country',
        'zip_code',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'birth_date' => 'date',
        'password' => 'hashed',
    ];

    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isClient(): bool
    {
        return $this->role === 'client';
    }
}
EOF

# Criar Controller básico HomeController
echo "🏠 Criando HomeController..."
cat > app/Http/Controllers/Site/HomeController.php << 'EOF'
<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index()
    {
        return view('site.home', [
            'title' => 'Encontre sua próxima estadia',
            'subtitle' => 'Encontre ofertas em hotéis, casas, apartamentos e muito mais...'
        ]);
    }
}
EOF

# Criar view básica home
echo "🎨 Criando view home básica..."
mkdir -p resources/views/site
cat > resources/views/site/home.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }} - Vancouver-Tec Pousadas</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #003580 0%, #0057b8 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .header {
            text-align: center;
            padding: 60px 0;
        }
        .header h1 {
            font-size: 3em;
            margin-bottom: 10px;
        }
        .header p {
            font-size: 1.2em;
            opacity: 0.9;
        }
        .search-box {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin: 40px 0;
            color: #333;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            align-items: end;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        .btn-search {
            background: #0071c2;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            height: fit-content;
        }
        .btn-search:hover {
            background: #005999;
        }
        .status {
            text-align: center;
            padding: 40px;
            background: rgba(255,255,255,0.1);
            border-radius: 8px;
            margin-top: 40px;
        }
        @media (max-width: 768px) {
            .search-form {
                grid-template-columns: 1fr;
            }
            .header h1 {
                font-size: 2em;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ $title }}</h1>
            <p>{{ $subtitle }}</p>
        </div>

        <div class="search-box">
            <form class="search-form" action="{{ route('properties.search') }}" method="GET">
                <div class="form-group">
                    <label>Para onde você vai?</label>
                    <input type="text" name="destination" placeholder="Cidade, região, propriedade">
                </div>
                <div class="form-group">
                    <label>Data de check-in</label>
                    <input type="date" name="checkin" value="{{ date('Y-m-d') }}">
                </div>
                <div class="form-group">
                    <label>Data de check-out</label>
                    <input type="date" name="checkout" value="{{ date('Y-m-d', strtotime('+1 day')) }}">
                </div>
                <div class="form-group">
                    <button type="submit" class="btn-search">Pesquisar</button>
                </div>
            </form>
        </div>

        <div class="status">
            <h3>🎉 Sistema Vancouver-Tec está funcionando!</h3>
            <p>Idioma atual: <strong>{{ strtoupper(app()->getLocale()) }}</strong></p>
            <p>Middleware de idiomas: <strong>✅ Ativo</strong></p>
            <p>Banco de dados: <strong>{{ config('database.default') }}</strong></p>
        </div>
    </div>
</body>
</html>
EOF

echo "✅ Middlewares e estrutura básica criados!"
echo ""
echo "📋 Teste agora:"
echo "php artisan serve"
echo ""
echo "🎯 Se funcionar, podemos continuar com Models e Migrations!"