#!/bin/bash

# 🏛️ Script 11 - Painel Administrativo Completo
# Vancouver-Tec Pousadas & Agências
# Dashboard admin com CRUD, relatórios e gestão completa

echo "🏛️ Iniciando implementação do painel administrativo..."

# 1. Atualizar AdminDashboardController
echo "📊 Criando AdminDashboardController completo..."
cat > app/Http/Controllers/Admin/DashboardController.php << 'EOF'
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Property;
use App\Models\User;
use App\Models\Booking;
use App\Models\Payment;
use App\Models\Review;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        // Estatísticas gerais
        $stats = [
            'total_properties' => Property::count(),
            'active_properties' => Property::where('active', true)->count(),
            'total_bookings' => Booking::count(),
            'pending_bookings' => Booking::where('status', 'pending')->count(),
            'total_users' => User::where('role', 'client')->count(),
            'total_revenue' => Payment::where('status', 'completed')->sum('amount'),
            'monthly_revenue' => Payment::where('status', 'completed')
                                       ->whereMonth('created_at', now()->month)
                                       ->sum('amount'),
            'average_rating' => Review::avg('rating') ?? 0
        ];

        // Reservas recentes
        $recentBookings = Booking::with(['user', 'property'])
                                ->orderBy('created_at', 'desc')
                                ->limit(10)
                                ->get();

        // Propriedades mais reservadas
        $topProperties = Property::withCount('bookings')
                                ->orderBy('bookings_count', 'desc')
                                ->limit(5)
                                ->get();

        // Gráfico de receita dos últimos 12 meses
        $monthlyRevenue = Payment::select(
                DB::raw('MONTH(created_at) as month'),
                DB::raw('YEAR(created_at) as year'),
                DB::raw('SUM(amount) as total')
            )
            ->where('status', 'completed')
            ->where('created_at', '>=', now()->subMonths(12))
            ->groupBy('year', 'month')
            ->orderBy('year', 'desc')
            ->orderBy('month', 'desc')
            ->get();

        return view('admin.dashboard', compact(
            'stats', 
            'recentBookings', 
            'topProperties',
            'monthlyRevenue'
        ));
    }

    public function properties()
    {
        $properties = Property::with(['photos'])
                             ->orderBy('created_at', 'desc')
                             ->paginate(15);

        return view('admin.properties.index', compact('properties'));
    }

    public function createProperty()
    {
        return view('admin.properties.create');
    }

    public function storeProperty(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|string',
            'address' => 'required|string|max:255',
            'city' => 'required|string|max:255',
            'state' => 'required|string|max:255',
            'zip_code' => 'required|string|max:20',
            'price_per_night' => 'required|numeric|min:0',
            'max_guests' => 'required|integer|min:1',
            'bedrooms' => 'required|integer|min:1',
            'bathrooms' => 'required|integer|min:1',
            'amenities' => 'array',
            'photos.*' => 'image|mimes:jpeg,png,jpg|max:2048'
        ]);

        $property = Property::create($request->except('photos', 'amenities') + [
            'amenities' => $request->amenities ?? [],
            'active' => $request->boolean('active', true),
            'featured' => $request->boolean('featured', false)
        ]);

        // Upload de fotos
        if ($request->hasFile('photos')) {
            foreach ($request->file('photos') as $index => $photo) {
                $filename = time() . '_' . $index . '.' . $photo->getClientOriginalExtension();
                $photo->move(public_path('uploads/properties'), $filename);
                
                $property->photos()->create([
                    'filename' => $filename,
                    'original_name' => $photo->getClientOriginalName(),
                    'sort_order' => $index,
                    'is_primary' => $index === 0
                ]);
            }
        }

        return redirect()->route('admin.properties')
                        ->with('success', 'Propriedade criada com sucesso!');
    }

    public function editProperty($id)
    {
        $property = Property::with('photos')->findOrFail($id);
        return view('admin.properties.edit', compact('property'));
    }

    public function updateProperty(Request $request, $id)
    {
        $property = Property::findOrFail($id);
        
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'type' => 'required|string',
            'address' => 'required|string|max:255',
            'city' => 'required|string|max:255',
            'state' => 'required|string|max:255',
            'zip_code' => 'required|string|max:20',
            'price_per_night' => 'required|numeric|min:0',
            'max_guests' => 'required|integer|min:1',
            'bedrooms' => 'required|integer|min:1',
            'bathrooms' => 'required|integer|min:1',
            'amenities' => 'array',
            'new_photos.*' => 'image|mimes:jpeg,png,jpg|max:2048'
        ]);

        $property->update($request->except('new_photos', 'amenities') + [
            'amenities' => $request->amenities ?? [],
            'active' => $request->boolean('active'),
            'featured' => $request->boolean('featured')
        ]);

        // Upload de novas fotos
        if ($request->hasFile('new_photos')) {
            $currentPhotosCount = $property->photos()->count();
            
            foreach ($request->file('new_photos') as $index => $photo) {
                $filename = time() . '_' . ($currentPhotosCount + $index) . '.' . $photo->getClientOriginalExtension();
                $photo->move(public_path('uploads/properties'), $filename);
                
                $property->photos()->create([
                    'filename' => $filename,
                    'original_name' => $photo->getClientOriginalName(),
                    'sort_order' => $currentPhotosCount + $index,
                    'is_primary' => false
                ]);
            }
        }

        return redirect()->route('admin.properties')
                        ->with('success', 'Propriedade atualizada com sucesso!');
    }

    public function destroyProperty($id)
    {
        $property = Property::findOrFail($id);
        
        // Remover fotos do disco
        foreach ($property->photos as $photo) {
            $filePath = public_path('uploads/properties/' . $photo->filename);
            if (file_exists($filePath)) {
                unlink($filePath);
            }
        }
        
        $property->delete();

        return redirect()->route('admin.properties')
                        ->with('success', 'Propriedade removida com sucesso!');
    }

    public function bookings()
    {
        $bookings = Booking::with(['user', 'property', 'payment'])
                          ->orderBy('created_at', 'desc')
                          ->paginate(20);

        return view('admin.bookings.index', compact('bookings'));
    }

    public function showBooking($id)
    {
        $booking = Booking::with(['user', 'property', 'payment', 'review'])
                         ->findOrFail($id);

        return view('admin.bookings.show', compact('booking'));
    }

    public function updateBookingStatus(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        
        $request->validate([
            'status' => 'required|in:pending,confirmed,cancelled,completed'
        ]);

        $booking->update(['status' => $request->status]);

        return back()->with('success', 'Status da reserva atualizado!');
    }

    public function users()
    {
        $users = User::orderBy('created_at', 'desc')->paginate(20);
        return view('admin.users.index', compact('users'));
    }

    public function showUser($id)
    {
        $user = User::with(['bookings.property', 'reviews'])
                   ->findOrFail($id);

        return view('admin.users.show', compact('user'));
    }

    public function updateUserStatus(Request $request, $id)
    {
        $user = User::findOrFail($id);
        
        $request->validate([
            'active' => 'required|boolean',
            'role' => 'required|in:client,admin'
        ]);

        $user->update([
            'active' => $request->active,
            'role' => $request->role
        ]);

        return back()->with('success', 'Usuário atualizado com sucesso!');
    }

    public function settings()
    {
        return view('admin.settings');
    }

    public function reports()
    {
        // Relatório de receita por período
        $revenueData = Payment::select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(amount) as total'),
                DB::raw('COUNT(*) as transactions')
            )
            ->where('status', 'completed')
            ->where('created_at', '>=', now()->subDays(30))
            ->groupBy('date')
            ->orderBy('date', 'desc')
            ->get();

        // Top propriedades por receita
        $topPropertiesByRevenue = Property::select('properties.*')
            ->join('bookings', 'properties.id', '=', 'bookings.property_id')
            ->join('payments', 'bookings.id', '=', 'payments.booking_id')
            ->where('payments.status', 'completed')
            ->selectRaw('properties.*, SUM(payments.amount) as total_revenue')
            ->groupBy('properties.id')
            ->orderBy('total_revenue', 'desc')
            ->limit(10)
            ->get();

        return view('admin.reports', compact('revenueData', 'topPropertiesByRevenue'));
    }
}
EOF

echo "✅ Script 11-painel-admin.sh (Parte A) criado com sucesso!"
echo ""
echo "📋 Parte A implementada:"
echo "   ✅ AdminDashboardController completo"
echo "   ✅ Dashboard com estatísticas e gráficos"
echo "   ✅ CRUD completo de propriedades"
echo "   ✅ Gestão de reservas e usuários"
echo "   ✅ Sistema de upload de fotos"
echo "   ✅ Relatórios avançados"
echo ""
echo "🔄 Para executar:"
echo "   chmod +x 11-painel-admin.sh && ./11-painel-admin.sh"
echo ""
echo "⚠️ Script extenso - aguarde 'continuar' para Parte B (Views Admin)!"