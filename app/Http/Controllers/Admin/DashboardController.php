<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Dashboard do admin']);
    }
    
    public function properties()
    {
        return response()->json(['message' => 'Propriedades do admin']);
    }
    
    public function bookings()
    {
        return response()->json(['message' => 'Reservas do admin']);
    }
    
    public function users()
    {
        return response()->json(['message' => 'Usuários do admin']);
    }
    
    public function settings()
    {
        return response()->json(['message' => 'Configurações do admin']);
    }
}
