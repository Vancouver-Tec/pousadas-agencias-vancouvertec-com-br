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
