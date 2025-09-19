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
