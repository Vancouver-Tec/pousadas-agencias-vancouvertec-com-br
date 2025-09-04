<?php

namespace App\Http\Controllers\Client;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Dashboard do cliente']);
    }
    
    public function bookings()
    {
        return response()->json(['message' => 'Reservas do cliente']);
    }
    
    public function profile()
    {
        return response()->json(['message' => 'Perfil do cliente']);
    }
    
    public function updateProfile(Request $request)
    {
        return response()->json(['message' => 'Perfil atualizado']);
    }
}
