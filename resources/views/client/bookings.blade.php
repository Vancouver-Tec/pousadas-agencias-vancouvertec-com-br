@extends('layouts.client')

@section('title', 'Minhas Reservas')

@section('content')
<div class="page-header">
    <h1>Minhas Reservas</h1>
    <p>Gerencie todas as suas reservas em um só lugar.</p>
</div>

@if($bookings->count() > 0)
    @foreach($bookings as $booking)
    <div class="card">
        <div class="card-body">
            <div style="display: grid; grid-template-columns: 120px 1fr auto; gap: 20px; align-items: center;">
                <div>
                    @if($booking->property->images && count($booking->property->images) > 0)
                        <img src="{{ $booking->property->images[0] }}" alt="{{ $booking->property->name }}" 
                             style="width: 120px; height: 80px; object-fit: cover; border-radius: 6px;">
                    @else
                        <div style="width: 120px; height: 80px; background: #f0f0f0; border-radius: 6px; display: flex; align-items: center; justify-content: center; color: #999;">
                            🏨
                        </div>
                    @endif
                </div>
                
                <div>
                    <h3 style="margin-bottom: 8px;">{{ $booking->property->name }}</h3>
                    <p style="color: #666; margin-bottom: 8px;">{{ $booking->property->city }}, {{ $booking->property->state }}</p>
                    
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-bottom: 10px;">
                        <div>
                            <small style="color: #999;">Check-in</small><br>
                            <strong>{{ $booking->check_in->format('d/m/Y') }}</strong>
                        </div>
                        <div>
                            <small style="color: #999;">Check-out</small><br>
                            <strong>{{ $booking->check_out->format('d/m/Y') }}</strong>
                        </div>
                        <div>
                            <small style="color: #999;">Hóspedes</small><br>
                            <strong>{{ $booking->guests }} {{ $booking->guests == 1 ? 'pessoa' : 'pessoas' }}</strong>
                        </div>
                    </div>
                    
                    <div style="display: flex; gap: 15px; align-items: center;">
                        @if($booking->status === 'confirmed')
                            <span class="badge badge-success">Confirmada</span>
                        @elseif($booking->status === 'pending')
                            <span class="badge badge-warning">Pendente</span>
                        @elseif($booking->status === 'cancelled')
                            <span class="badge badge-danger">Cancelada</span>
                        @else
                            <span class="badge badge-info">{{ ucfirst($booking->status) }}</span>
                        @endif
                        
                        <small style="color: #666;">
                            Reserva #{{ $booking->booking_number }}
                        </small>
                    </div>
                </div>
                
                <div style="text-align: right;">
                    <div style="font-size: 1.5rem; font-weight: bold; color: #0071c2; margin-bottom: 10px;">
                        R$ {{ number_format($booking->total, 2, ',', '.') }}
                    </div>
                    <div style="margin-bottom: 15px;">
                        <small style="color: #666;">{{ $booking->nights }} {{ $booking->nights == 1 ? 'noite' : 'noites' }}</small>
                    </div>
                    <a href="{{ route('client.booking.show', $booking->id) }}" class="btn btn-primary">Ver Detalhes</a>
                </div>
            </div>
        </div>
    </div>
    @endforeach
    
    <div style="margin-top: 30px;">
        {{ $bookings->links() }}
    </div>
@else
    <div class="card">
        <div class="card-body" style="text-align: center; padding: 60px 20px;">
            <div style="font-size: 4rem; margin-bottom: 20px; opacity: 0.3;">📅</div>
            <h3 style="margin-bottom: 10px;">Nenhuma reserva encontrada</h3>
            <p style="color: #666; margin-bottom: 30px;">Você ainda não fez nenhuma reserva. Que tal começar a planejar sua próxima viagem?</p>
            <a href="{{ route('home') }}" class="btn btn-primary">Encontrar Hospedagem</a>
        </div>
    </div>
@endif
@endsection
