<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    public function search(Request $request)
    {
        return response()->json([
            'message' => 'Busca funcionando',
            'params' => $request->all()
        ]);
    }
    
    public function show($id)
    {
        return response()->json([
            'message' => 'Propriedade encontrada',
            'id' => $id
        ]);
    }
}
