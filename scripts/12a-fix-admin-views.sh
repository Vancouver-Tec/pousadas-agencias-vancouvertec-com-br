#!/bin/bash

# 🔧 Script 12a - Correção das Views Admin
# Vancouver-Tec Pousadas & Agências
# Cria views admin faltantes para resolver erro

echo "🔧 Corrigindo views administrativas faltantes..."

# Criar estrutura de diretórios
mkdir -p resources/views/admin/{properties,bookings,users}

# Criar view admin.dashboard temporária
echo "📊 Criando view admin/dashboard.blade.php..."
cat > resources/views/admin/dashboard.blade.php << 'EOF'
@extends('layouts.admin')

@section('title', 'Dashboard Admin')
@section('page-title', 'Dashboard')

@section('content')
<!-- Stats Cards -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="flex-shrink-0">
                <i class="fas fa-building text-3xl text-blue-600"></i>
            </div>
            <div class="ml-4">
                <div class="text-sm font-medium text-gray-500">Propriedades</div>
                <div class="text-2xl font-bold text-gray-900">{{ $stats['total_properties'] ?? 0 }}</div>
                <div class="text-sm text-green-600">{{ $stats['active_properties'] ?? 0 }} ativas</div>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="flex-shrink-0">
                <i class="fas fa-calendar-check text-3xl text-green-600"></i>
            </div>
            <div class="ml-4">
                <div class="text-sm font-medium text-gray-500">Reservas</div>
                <div class="text-2xl font-bold text-gray-900">{{ $stats['total_bookings'] ?? 0 }}</div>
                <div class="text-sm text-orange-600">{{ $stats['pending_bookings'] ?? 0 }} pendentes</div>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="flex-shrink-0">
                <i class="fas fa-users text-3xl text-purple-600"></i>
            </div>
            <div class="ml-4">
                <div class="text-sm font-medium text-gray-500">Usuários</div>
                <div class="text-2xl font-bold text-gray-900">{{ $stats['total_users'] ?? 0 }}</div>
                <div class="text-sm text-gray-500">clientes</div>
            </div>
        </div>
    </div>

    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <div class="flex-shrink-0">
                <i class="fas fa-dollar-sign text-3xl text-yellow-600"></i>
            </div>
            <div class="ml-4">
                <div class="text-sm font-medium text-gray-500">Receita Total</div>
                <div class="text-2xl font-bold text-gray-900">R$ {{ number_format($stats['total_revenue'] ?? 0, 2, ',', '.') }}</div>
                <div class="text-sm text-green-600">R$ {{ number_format($stats['monthly_revenue'] ?? 0, 2, ',', '.') }} este mês</div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Bookings -->
<div class="bg-white rounded-lg shadow">
    <div class="px-6 py-4 border-b border-gray-200">
        <h3 class="text-lg font-semibold text-gray-900">Reservas Recentes</h3>
    </div>
    <div class="p-6">
        @if(isset($recentBookings) && $recentBookings->count() > 0)
            <div class="space-y-4">
                @foreach($recentBookings as $booking)
                    <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                        <div>
                            <h4 class="font-medium">{{ $booking->user->name ?? 'N/A' }}</h4>
                            <p class="text-sm text-gray-500">{{ $booking->property->name ?? 'N/A' }}</p>
                        </div>
                        <div class="text-right">
                            <span class="text-sm font-medium">R$ {{ number_format($booking->total ?? 0, 2, ',', '.') }}</span>
                            <p class="text-xs text-gray-500">{{ $booking->created_at->format('d/m/Y') ?? 'N/A' }}</p>
                        </div>
                    </div>
                @endforeach
            </div>
        @else
            <div class="text-center py-8">
                <i class="fas fa-calendar text-4xl text-gray-300 mb-4"></i>
                <p class="text-gray-500">Nenhuma reserva encontrada</p>
            </div>
        @endif
    </div>
</div>
@endsection
EOF

# Criar view admin/properties/index.blade.php
echo "🏢 Criando view admin/properties/index.blade.php..."
cat > resources/views/admin/properties/index.blade.php << 'EOF'
@extends('layouts.admin')

@section('title', 'Propriedades')
@section('page-title', 'Gestão de Propriedades')

@section('content')
<div class="mb-6">
    <a href="{{ route('admin.properties.create') }}" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
        <i class="fas fa-plus mr-2"></i>Nova Propriedade
    </a>
</div>

<div class="bg-white rounded-lg shadow overflow-hidden">
    @if(isset($properties) && $properties->count() > 0)
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Nome</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Localização</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Preço</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ações</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                @foreach($properties as $property)
                    <tr>
                        <td class="px-6 py-4">
                            <div class="flex items-center">
                                <img class="h-10 w-10 rounded-full object-cover" 
                                     src="{{ $property->photos->first() ? asset('uploads/properties/'.$property->photos->first()->filename) : 'https://via.placeholder.com/40' }}" 
                                     alt="">
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">{{ $property->name }}</div>
                                    <div class="text-sm text-gray-500">{{ $property->type }}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                            {{ $property->city }}, {{ $property->state }}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                            R$ {{ number_format($property->price_per_night, 2, ',', '.') }}
                        </td>
                        <td class="px-6 py-4">
                            @if($property->active)
                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">Ativa</span>
                            @else
                                <span class="px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">Inativa</span>
                            @endif
                        </td>
                        <td class="px-6 py-4 text-sm space-x-2">
                            <a href="{{ route('admin.properties.edit', $property->id) }}" 
                               class="text-blue-600 hover:text-blue-900">Editar</a>
                            <form method="POST" action="{{ route('admin.properties.destroy', $property->id) }}" 
                                  class="inline" onsubmit="return confirm('Tem certeza?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="text-red-600 hover:text-red-900">Excluir</button>
                            </form>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        
        <div class="px-6 py-4">
            {{ $properties->links() }}
        </div>
    @else
        <div class="text-center py-12">
            <i class="fas fa-building text-4xl text-gray-300 mb-4"></i>
            <h3 class="text-lg font-medium text-gray-900 mb-2">Nenhuma propriedade cadastrada</h3>
            <p class="text-gray-500 mb-4">Comece adicionando sua primeira propriedade</p>
            <a href="{{ route('admin.properties.create') }}" 
               class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg">
                <i class="fas fa-plus mr-2"></i>Nova Propriedade
            </a>
        </div>
    @endif
</div>
@endsection
EOF

# Criar views básicas faltantes
echo "📋 Criando views básicas faltantes..."

# admin/bookings/index.blade.php
cat > resources/views/admin/bookings/index.blade.php << 'EOF'
@extends('layouts.admin')
@section('title', 'Reservas')
@section('page-title', 'Gestão de Reservas')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-lg font-semibold mb-4">Reservas</h3>
    <p class="text-gray-500">Sistema de reservas em desenvolvimento...</p>
</div>
@endsection
EOF

# admin/users/index.blade.php
cat > resources/views/admin/users/index.blade.php << 'EOF'
@extends('layouts.admin')
@section('title', 'Usuários')
@section('page-title', 'Gestão de Usuários')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-lg font-semibold mb-4">Usuários</h3>
    <p class="text-gray-500">Sistema de usuários em desenvolvimento...</p>
</div>
@endsection
EOF

# admin/settings.blade.php
cat > resources/views/admin/settings.blade.php << 'EOF'
@extends('layouts.admin')
@section('title', 'Configurações')
@section('page-title', 'Configurações do Sistema')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-lg font-semibold mb-4">Configurações</h3>
    <p class="text-gray-500">Configurações do sistema em desenvolvimento...</p>
</div>
@endsection
EOF

# admin/reports.blade.php
cat > resources/views/admin/reports.blade.php << 'EOF'
@extends('layouts.admin')
@section('title', 'Relatórios')
@section('page-title', 'Relatórios e Estatísticas')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h3 class="text-lg font-semibold mb-4">Relatórios</h3>
    <p class="text-gray-500">Sistema de relatórios em desenvolvimento...</p>
</div>
@endsection
EOF

# Criar views básicas para cliente também
echo "👤 Criando views básicas do cliente..."

# Estrutura cliente
mkdir -p resources/views/client

# Layout cliente
cat > resources/views/layouts/client.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Minha Conta') - Vancouver-Tec</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm border-b">
        <div class="container mx-auto px-4 py-4 flex items-center justify-between">
            <a href="{{ route('site.home') }}" class="text-2xl font-bold text-blue-800">
                <i class="fas fa-home mr-2"></i>Vancouver-Tec
            </a>
            
            <div class="flex items-center space-x-4">
                <span class="text-gray-700">Olá, {{ Auth::user()->name }}!</span>
                <form method="POST" action="{{ route('logout') }}" class="inline">
                    @csrf
                    <button type="submit" class="text-red-600 hover:text-red-800">
                        <i class="fas fa-sign-out-alt mr-1"></i>Sair
                    </button>
                </form>
            </div>
        </div>
    </header>

    <!-- Navigation -->
    <nav class="bg-gray-100 border-b">
        <div class="container mx-auto px-4">
            <div class="flex space-x-8">
                <a href="{{ route('client.dashboard') }}" 
                   class="py-3 px-1 border-b-2 {{ request()->routeIs('client.dashboard') ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700' }}">
                    <i class="fas fa-chart-bar mr-2"></i>Dashboard
                </a>
                <a href="{{ route('client.bookings') }}" 
                   class="py-3 px-1 border-b-2 {{ request()->routeIs('client.bookings*') ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700' }}">
                    <i class="fas fa-calendar-check mr-2"></i>Minhas Reservas
                </a>
                <a href="{{ route('client.profile') }}" 
                   class="py-3 px-1 border-b-2 {{ request()->routeIs('client.profile') ? 'border-blue-600 text-blue-600' : 'border-transparent text-gray-500 hover:text-gray-700' }}">
                    <i class="fas fa-user mr-2"></i>Perfil
                </a>
            </div>
        </div>
    </nav>

    <!-- Content -->
    <main class="container mx-auto px-4 py-8">
        @if (session('success'))
            <div class="mb-6 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg">
                <i class="fas fa-check-circle mr-2"></i>{{ session('success') }}
            </div>
        @endif

        @yield('content')
    </main>
</body>
</html>
EOF

# client/dashboard.blade.php
cat > resources/views/client/dashboard.blade.php << 'EOF'
@extends('layouts.client')

@section('title', 'Meu Dashboard')

@section('content')
<div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900">Meu Dashboard</h1>
    <p class="text-gray-600">Bem-vindo de volta, {{ Auth::user()->name }}!</p>
</div>

<!-- Stats Cards -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <i class="fas fa-calendar-check text-2xl text-blue-600"></i>
            <div class="ml-4">
                <div class="text-2xl font-bold text-gray-900">{{ $stats['total_bookings'] ?? 0 }}</div>
                <div class="text-sm text-gray-500">Total de Reservas</div>
            </div>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <i class="fas fa-clock text-2xl text-green-600"></i>
            <div class="ml-4">
                <div class="text-2xl font-bold text-gray-900">{{ $stats['upcoming_bookings'] ?? 0 }}</div>
                <div class="text-sm text-gray-500">Próximas Viagens</div>
            </div>
        </div>
    </div>
    
    <div class="bg-white rounded-lg shadow p-6">
        <div class="flex items-center">
            <i class="fas fa-dollar-sign text-2xl text-yellow-600"></i>
            <div class="ml-4">
                <div class="text-2xl font-bold text-gray-900">R$ {{ number_format($stats['total_spent'] ?? 0, 0, ',', '.') }}</div>
                <div class="text-sm text-gray-500">Total Gasto</div>
            </div>
        </div>
    </div>
</div>

<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Dashboard do Cliente</h2>
    <p class="text-gray-600">Sistema em desenvolvimento. Em breve você terá acesso a todas as funcionalidades!</p>
</div>
@endsection
EOF

# Views básicas restantes do cliente
cat > resources/views/client/bookings.blade.php << 'EOF'
@extends('layouts.client')
@section('title', 'Minhas Reservas')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Minhas Reservas</h2>
    <p class="text-gray-600">Sistema de reservas em desenvolvimento...</p>
</div>
@endsection
EOF

cat > resources/views/client/profile.blade.php << 'EOF'
@extends('layouts.client')
@section('title', 'Meu Perfil')
@section('content')
<div class="bg-white rounded-lg shadow p-6">
    <h2 class="text-xl font-semibold mb-4">Meu Perfil</h2>
    <p class="text-gray-600">Configurações de perfil em desenvolvimento...</p>
</div>
@endsection
EOF

echo "✅ Script 12a-fix-admin-views.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ View admin.dashboard criada"
echo "   ✅ Views básicas de propriedades, reservas e usuários"
echo "   ✅ Layout administrativo funcional"
echo "   ✅ Views básicas do cliente criadas"
echo "   ✅ Layout do cliente funcional"
echo ""
echo "🚀 Para executar a correção:"
echo "   chmod +x 12a-fix-admin-views.sh && ./12a-fix-admin-views.sh"
echo ""
echo "📋 Isso deve resolver o erro 'View [admin.dashboard] not found'"
echo "⚠️ Algumas views são temporárias e serão melhoradas posteriormente"