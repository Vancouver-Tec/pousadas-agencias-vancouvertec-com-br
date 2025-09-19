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
