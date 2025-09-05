#!/bin/bash

# ===========================================
# DASHBOARD CLIENTE - Sistema Pousadas
# Vancouver-Tec - Painel completo do cliente
# ===========================================

echo "🚀 Criando Dashboard do Cliente..."

# ===========================================
# ATUALIZAR CLIENT DASHBOARD CONTROLLER
# ===========================================

echo "🎮 Atualizando ClientDashboardController..."
cat > app/Http/Controllers/Client/DashboardController.php << 'EOF'
<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Property;
use App\Models\Favorite;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class DashboardController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        $stats = [
            'total_bookings' => $user->bookings()->count(),
            'active_bookings' => $user->bookings()->whereIn('status', ['confirmed', 'pending'])->count(),
            'completed_bookings' => $user->bookings()->where('status', 'completed')->count(),
            'favorites' => $user->favorites()->count(),
        ];
        
        $recentBookings = $user->bookings()
            ->with('property')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();
            
        $upcomingBookings = $user->bookings()
            ->with('property')
            ->where('status', 'confirmed')
            ->where('check_in', '>=', now())
            ->orderBy('check_in')
            ->limit(3)
            ->get();
        
        return view('client.dashboard', compact('stats', 'recentBookings', 'upcomingBookings'));
    }
    
    public function bookings()
    {
        $bookings = Auth::user()->bookings()
            ->with(['property', 'payments'])
            ->orderBy('created_at', 'desc')
            ->paginate(10);
        
        return view('client.bookings', compact('bookings'));
    }
    
    public function bookingShow($id)
    {
        $booking = Auth::user()->bookings()
            ->with(['property', 'payments', 'review'])
            ->findOrFail($id);
        
        return view('client.booking-show', compact('booking'));
    }
    
    public function profile()
    {
        $user = Auth::user();
        return view('client.profile', compact('user'));
    }
    
    public function updateProfile(Request $request)
    {
        $user = Auth::user();
        
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:20',
            'document' => 'nullable|string|max:20',
            'birth_date' => 'nullable|date',
            'address' => 'nullable|string|max:500',
            'city' => 'nullable|string|max:100',
            'state' => 'nullable|string|max:100',
            'country' => 'nullable|string|max:100',
            'zip_code' => 'nullable|string|max:20',
            'preferred_language' => 'required|in:pt,en,es',
        ], [
            'name.required' => 'O nome é obrigatório.',
            'email.required' => 'O e-mail é obrigatório.',
            'email.email' => 'Digite um e-mail válido.',
            'email.unique' => 'Este e-mail já está sendo usado.',
            'preferred_language.required' => 'Selecione um idioma.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput();
        }

        $user->update($request->only([
            'name', 'email', 'phone', 'document', 'birth_date',
            'address', 'city', 'state', 'country', 'zip_code', 'preferred_language'
        ]));

        return back()->with('success', 'Perfil atualizado com sucesso!');
    }
    
    public function updatePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'password' => 'required|string|min:6|confirmed',
        ], [
            'current_password.required' => 'A senha atual é obrigatória.',
            'password.required' => 'A nova senha é obrigatória.',
            'password.min' => 'A nova senha deve ter pelo menos 6 caracteres.',
            'password.confirmed' => 'A confirmação da senha não confere.',
        ]);

        if ($validator->fails()) {
            return back()
                ->withErrors($validator)
                ->withInput();
        }

        $user = Auth::user();

        if (!Hash::check($request->current_password, $user->password)) {
            return back()
                ->withErrors(['current_password' => 'Senha atual incorreta.']);
        }

        $user->update([
            'password' => Hash::make($request->password)
        ]);

        return back()->with('success', 'Senha alterada com sucesso!');
    }
    
    public function favorites()
    {
        $favorites = Auth::user()->favorites()
            ->with('property')
            ->orderBy('created_at', 'desc')
            ->paginate(12);
        
        return view('client.favorites', compact('favorites'));
    }
    
    public function toggleFavorite($propertyId)
    {
        $user = Auth::user();
        $property = Property::findOrFail($propertyId);
        
        $favorite = $user->favorites()->where('property_id', $propertyId)->first();
        
        if ($favorite) {
            $favorite->delete();
            $message = 'Propriedade removida dos favoritos.';
        } else {
            $user->favorites()->create(['property_id' => $propertyId]);
            $message = 'Propriedade adicionada aos favoritos!';
        }
        
        return response()->json(['success' => true, 'message' => $message]);
    }
}
EOF

# ===========================================
# VIEWS DO CLIENTE
# ===========================================

echo "🎨 Criando layout do cliente..."
mkdir -p resources/views/client
cat > resources/views/layouts/client.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Minha Conta') - Vancouver-Tec Pousadas</title>
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
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 30px;
        }
        
        .sidebar {
            background: white;
            border-radius: 8px;
            padding: 20px;
            height: fit-content;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .sidebar-header {
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
            margin-bottom: 15px;
        }
        
        .sidebar-header h3 {
            color: #0071c2;
            font-size: 1.1rem;
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px;
            color: #666;
            text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s;
        }
        
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: #0071c2;
            color: white;
        }
        
        .sidebar-menu a .icon {
            margin-right: 10px;
            width: 20px;
        }
        
        .main-content {
            background: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .page-header {
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .page-header h1 {
            color: #333;
            font-size: 2rem;
            margin-bottom: 5px;
        }
        
        .page-header p {
            color: #666;
        }
        
        .btn {
            padding: 10px 20px;
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
            background: #f8f9fa;
            color: #495057;
            border-color: #dee2e6;
        }
        
        .btn-secondary:hover {
            background: #e2e6ea;
            border-color: #dae0e5;
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #0071c2 0%, #005999 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            opacity: 0.9;
        }
        
        .card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 20px;
        }
        
        .card-header {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0e0;
            font-weight: 600;
        }
        
        .card-body {
            padding: 20px;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th,
        .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .table th {
            background: #f8f9fa;
            font-weight: 600;
        }
        
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-success {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }
        
        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }
        
        .badge-info {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        @media (max-width: 768px) {
            .container {
                grid-template-columns: 1fr;
                padding: 10px;
            }
            
            .sidebar {
                order: 2;
            }
            
            .main-content {
                order: 1;
            }
            
            .stats-grid {
                grid-template-columns: 1fr 1fr;
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
                <span>Olá, {{ Auth::user()->name }}!</span>
                <a href="{{ route('home') }}">Ver Site</a>
                <form action="{{ route('logout') }}" method="POST" style="display: inline;">
                    @csrf
                    <button type="submit" class="btn btn-secondary">Sair</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h3>Minha Conta</h3>
            </div>
            <ul class="sidebar-menu">
                <li><a href="{{ route('client.dashboard') }}" class="{{ request()->routeIs('client.dashboard') ? 'active' : '' }}">
                    <span class="icon">📊</span> Dashboard
                </a></li>
                <li><a href="{{ route('client.bookings') }}" class="{{ request()->routeIs('client.bookings*') ? 'active' : '' }}">
                    <span class="icon">📅</span> Minhas Reservas
                </a></li>
                <li><a href="{{ route('client.favorites') }}" class="{{ request()->routeIs('client.favorites') ? 'active' : '' }}">
                    <span class="icon">❤️</span> Favoritos
                </a></li>
                <li><a href="{{ route('client.profile') }}" class="{{ request()->routeIs('client.profile') ? 'active' : '' }}">
                    <span class="icon">👤</span> Perfil
                </a></li>
            </ul>
        </aside>

        <main class="main-content">
            @if(session('success'))
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-error">
                    {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>

    @yield('scripts')
</body>
</html>
EOF

echo "📊 Criando view Dashboard..."
cat > resources/views/client/dashboard.blade.php << 'EOF'
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
EOF

echo "📅 Criando view Bookings..."
cat > resources/views/client/bookings.blade.php << 'EOF'
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
EOF

echo "✅ Dashboard do Cliente criado!"
echo ""
echo "📋 Execute agora:"
echo "php artisan serve"
echo ""
echo "🎯 Próximo: Detalhes da reserva e favoritos (06d-booking-details.sh)"