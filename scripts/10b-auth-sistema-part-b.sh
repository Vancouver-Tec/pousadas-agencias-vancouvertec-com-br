#!/bin/bash

# 🔐 Script 10b - Sistema de Autenticação (Parte B)
# Vancouver-Tec Pousadas & Agências  
# Views de registro, recuperação de senha e configurações

echo "🔐 Continuando implementação do sistema de autenticação..."

# 1. View de Registro
echo "📝 Criando view de registro..."
cat > resources/views/site/auth/register.blade.php << 'EOF'
@extends('layouts.auth')

@section('title', 'Cadastro')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Crie sua conta</h2>
        <p class="mt-2 text-sm text-gray-600">
            Ou 
            <a href="{{ route('login') }}" class="font-medium text-blue-600 hover:text-blue-500">
                faça login na sua conta existente
            </a>
        </p>
    </div>

    <!-- Form -->
    <form class="space-y-6" action="{{ route('register') }}" method="POST">
        @csrf
        
        <!-- Name -->
        <div>
            <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-user mr-2"></i>Nome completo
            </label>
            <input id="name" 
                   name="name" 
                   type="text" 
                   required 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('name') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="Digite seu nome completo"
                   value="{{ old('name') }}">
            @error('name')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Email -->
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2"></i>Email
            </label>
            <input id="email" 
                   name="email" 
                   type="email" 
                   required 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('email') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="Digite seu email"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Phone -->
        <div>
            <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-phone mr-2"></i>Telefone (opcional)
            </label>
            <input id="phone" 
                   name="phone" 
                   type="tel" 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="(11) 99999-9999"
                   value="{{ old('phone') }}">
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
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border @error('password') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Mínimo 8 caracteres">
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

        <!-- Password Confirmation -->
        <div>
            <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Confirmar senha
            </label>
            <div class="relative">
                <input id="password_confirmation" 
                       name="password_confirmation" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Confirme sua senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password_confirmation', 'password-confirmation-icon')">
                    <i id="password-confirmation-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        </div>

        <!-- Terms -->
        <div class="flex items-start">
            <input id="terms" 
                   name="terms" 
                   type="checkbox" 
                   required
                   class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded mt-1 @error('terms') border-red-300 @enderror">
            <label for="terms" class="ml-2 block text-sm text-gray-900">
                Eu aceito os 
                <a href="#" class="text-blue-600 hover:text-blue-500">Termos de Uso</a> e
                <a href="#" class="text-blue-600 hover:text-blue-500">Política de Privacidade</a>
            </label>
        </div>
        @error('terms')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
        @enderror

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-user-plus text-blue-300"></i>
                </span>
                Criar conta
            </button>
        </div>
    </form>
</div>
@endsection
EOF

# 2. View de Esqueci a Senha
echo "🔑 Criando view de recuperação de senha..."
cat > resources/views/site/auth/forgot-password.blade.php << 'EOF'
@extends('layouts.auth')

@section('title', 'Recuperar Senha')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Esqueceu sua senha?</h2>
        <p class="mt-2 text-sm text-gray-600">
            Digite seu email e enviaremos um link para redefinir sua senha
        </p>
    </div>

    <!-- Success Message -->
    @if (session('status'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
            <i class="fas fa-check-circle mr-2"></i>{{ session('status') }}
        </div>
    @endif

    <!-- Form -->
    <form class="space-y-6" action="{{ route('password.email') }}" method="POST">
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
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('email') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="Digite seu email cadastrado"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-paper-plane text-blue-300"></i>
                </span>
                Enviar link de recuperação
            </button>
        </div>

        <!-- Back to Login -->
        <div class="text-center">
            <a href="{{ route('login') }}" class="text-sm text-blue-600 hover:text-blue-500">
                <i class="fas fa-arrow-left mr-2"></i>Voltar para o login
            </a>
        </div>
    </form>
</div>
@endsection
EOF

# 3. View de Redefinir Senha
echo "🔄 Criando view de redefinição de senha..."
cat > resources/views/site/auth/reset-password.blade.php << 'EOF'
@extends('layouts.auth')

@section('title', 'Redefinir Senha')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Redefinir senha</h2>
        <p class="mt-2 text-sm text-gray-600">
            Digite sua nova senha
        </p>
    </div>

    <!-- Form -->
    <form class="space-y-6" action="{{ route('password.update') }}" method="POST">
        @csrf
        
        <!-- Hidden Token -->
        <input type="hidden" name="token" value="{{ $token }}">

        <!-- Email -->
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2"></i>Email
            </label>
            <input id="email" 
                   name="email" 
                   type="email" 
                   required 
                   readonly
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 bg-gray-50 text-gray-900"
                   value="{{ $email ?? old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- New Password -->
        <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Nova senha
            </label>
            <div class="relative">
                <input id="password" 
                       name="password" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border @error('password') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Mínimo 8 caracteres">
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

        <!-- Confirm Password -->
        <div>
            <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Confirmar nova senha
            </label>
            <div class="relative">
                <input id="password_confirmation" 
                       name="password_confirmation" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Confirme sua nova senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password_confirmation', 'password-confirmation-icon')">
                    <i id="password-confirmation-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-key text-blue-300"></i>
                </span>
                Redefinir senha
            </button>
        </div>
    </form>
</div>
@endsection
EOF

# 4. Configuração de email (config/mail.php)
echo "📧 Configurando sistema de email..."
cat > config/mail.php << 'EOF'
<?php

return [
    'default' => env('MAIL_MAILER', 'log'),

    'mailers' => [
        'smtp' => [
            'transport' => 'smtp',
            'url' => env('MAIL_URL'),
            'host' => env('MAIL_HOST', '127.0.0.1'),
            'port' => env('MAIL_PORT', 2525),
            'encryption' => env('MAIL_ENCRYPTION', 'tls'),
            'username' => env('MAIL_USERNAME'),
            'password' => env('MAIL_PASSWORD'),
            'timeout' => null,
            'local_domain' => env('MAIL_EHLO_DOMAIN', parse_url(env('APP_URL', 'http://localhost'), PHP_URL_HOST)),
        ],

        'ses' => [
            'transport' => 'ses',
        ],

        'postmark' => [
            'transport' => 'postmark',
        ],

        'sendmail' => [
            'transport' => 'sendmail',
            'path' => env('MAIL_SENDMAIL_PATH', '/usr/sbin/sendmail -bs -i'),
        ],

        'log' => [
            'transport' => 'log',
            'channel' => env('MAIL_LOG_CHANNEL'),
        ],

        'array' => [
            'transport' => 'array',
        ],

        'failover' => [
            'transport' => 'failover',
            'mailers' => [
                'smtp',
                'log',
            ],
        ],

        'roundrobin' => [
            'transport' => 'roundrobin',
            'mailers' => [
                'ses',
                'postmark',
            ],
        ],
    ],

    'from' => [
        'address' => env('MAIL_FROM_ADDRESS', 'hello@example.com'),
        'name' => env('MAIL_FROM_NAME', 'Example'),
    ],
];
EOF

# 5. Configuração de autenticação (config/auth.php)
echo "🔐 Configurando autenticação..."
cat > config/auth.php << 'EOF'
<?php

return [
    'defaults' => [
        'guard' => env('AUTH_GUARD', 'web'),
        'passwords' => env('AUTH_PASSWORD_BROKER', 'users'),
    ],

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        'api' => [
            'driver' => 'sanctum',
            'provider' => 'users',
        ],
    ],

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => env('AUTH_MODEL', App\Models\User::class),
        ],
    ],

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => env('AUTH_PASSWORD_RESET_TOKEN_TABLE', 'password_reset_tokens'),
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    'password_timeout' => env('AUTH_PASSWORD_TIMEOUT', 10800),
];
EOF

# 6. Registrar middleware no bootstrap/app.php
echo "🛠️ Registrando middleware..."
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
            App\Http\Middleware\LanguageMiddleware::class,
        ]);
        
        $middleware->alias([
            'check.role' => App\Http\Middleware\CheckRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

echo "✅ Script 10b-auth-sistema-part-b.sh criado com sucesso!"
echo ""
echo "📋 Parte B implementada:"
echo "   ✅ View de registro completa com validações"
echo "   ✅ View de recuperação de senha"
echo "   ✅ View de redefinição de senha"
echo "   ✅ Configuração de email para recuperação"
echo "   ✅ Configuração de autenticação"
echo "   ✅ Middleware registrado no bootstrap"
echo ""
echo "🎯 Para executar ambas as partes:"
echo "   1. chmod +x 10-auth-sistema.sh && ./10-auth-sistema.sh"
echo "   2. chmod +x 10b-auth-sistema-part-b.sh && ./10b-auth-sistema-part-b.sh"
echo ""
echo "🚀 Sistema de autenticação completo!"
echo "Próximo: 11-painel-admin.sh ou 12-painel-client.sh"