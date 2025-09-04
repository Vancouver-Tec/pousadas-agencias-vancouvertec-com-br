<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    public function create($property)
    {
        return response()->json([
            'message' => 'Criar reserva',
            'property' => $property
        ]);
    }
}
