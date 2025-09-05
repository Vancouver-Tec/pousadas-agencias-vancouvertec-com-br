@extends('layouts.client')

@section('title', 'Dashboard')

@section('content')
<div class="page-header">
    <h1>Dashboard</h1>
    <p>Bem-vindo(a) de volta! Aqui está um resumo da sua conta.</p>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-number">{{ $stats['total_bookings'] }}</div>
        <div class="stat-label">Total de Reservas</div>
    </div>
    <div class="stat-card">
        <div class="stat-number">{{ $stats['active_bookings'] }}</div>
        <div class="stat-label">Reservas Ativas</div>
    </div>
    <div class="stat-card">
        <div class="stat-number">{{ $stats['completed_bookings'] }}</div>
        <div class="stat-label">Reservas Concluídas</div>
    </div>
    <div class="stat-card">
        <div class="stat-number">{{ $stats['favorites'] }}</div>
        <div class="stat-label">Favoritos</div>
    </div>
</div>

@if($upcomingBookings->count() > 0)
<div class="card">
    <div class="card-header">
        Próximas Viagens
    </div>
    <div class="card-body">
        @foreach($upcomingBookings as $booking)
        <div style="display: flex; justify-content: space-between; align-items: center; padding: 15px 0; border-bottom: 1px solid #eee;">
            <div>
                <strong>{{ $booking->property->name }}</strong><br>
                <small style="color: #666;">{{ $booking->property->city }}, {{ $booking->property->state }}</small><br>
                <small style="color: #0071c2;">{{ $booking->check_in->format('d/m/Y') }} - {{ $booking->check_out->format('d/m/Y') }}</small>
            </div>
            <div style="text-align: right;">
                <span class="badge badge-info">{{ ucfirst($booking->status) }}</span><br>
                <small style="color: #666;">{{ $booking->nights }} {{ $booking->nights == 1 ? 'noite' : 'noites' }}</small>
            </div>
        </div>
        @endforeach
        <div style="text-align: center; margin-top: 15px;">
            <a href="{{ route('client.bookings') }}" class="btn btn-primary">Ver Todas as Reservas</a>
        </div>
    </div>
</div>
@endif

<div class="card">
    <div class="card-header">
        Atividade Recente
    </div>
    <div class="card-body">
        @if($recentBookings->count() > 0)
            <table class="table">
                <thead>
                    <tr>
                        <th>Propriedade</th>
                        <th>Data</th>
                        <th>Status</th>
                        <th>Valor</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($recentBookings as $booking)
                    <tr>
                        <td>
                            <strong>{{ $booking->property->name }}</strong><br>
                            <small style="color: #666;">{{ $booking->property->city }}</small>
                        </td>
                        <td>{{ $booking->created_at->format('d/m/Y') }}</td>
                        <td>
                            @if($booking->status === 'confirmed')
                                <span class="badge badge-success">Confirmada</span>
                            @elseif($booking->status === 'pending')
                                <span class="badge badge-warning">Pendente</span>
                            @elseif($booking->status === 'cancelled')
                                <span class="badge badge-danger">Cancelada</span>
                            @else
                                <span class="badge badge-info">{{ ucfirst($booking->status) }}</span>
                            @endif
                        </td>
                        <td>R$ {{ number_format($booking->total, 2, ',', '.') }}</td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        @else
            <p style="text-align: center; color: #666; padding: 40px;">
                Você ainda não fez nenhuma reserva.<br>
                <a href="{{ route('home') }}" class="btn btn-primary" style="margin-top: 10px;">Encontrar Hospedagem</a>
            </p>
        @endif
    </div>
</div>
@endsection
