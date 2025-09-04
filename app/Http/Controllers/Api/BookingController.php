<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Lista de reservas API']);
    }
    
    public function show($id)
    {
        return response()->json(['message' => 'Reserva API', 'id' => $id]);
    }
    
    public function store(Request $request)
    {
        return response()->json(['message' => 'Reserva criada API']);
    }
}
