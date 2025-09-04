<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PropertyController extends Controller
{
    public function index()
    {
        return response()->json(['message' => 'Lista de propriedades API']);
    }
    
    public function show($id)
    {
        return response()->json(['message' => 'Propriedade API', 'id' => $id]);
    }
    
    public function search(Request $request)
    {
        return response()->json(['message' => 'Busca API', 'params' => $request->all()]);
    }
}
