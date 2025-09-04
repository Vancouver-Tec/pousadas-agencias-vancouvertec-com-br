<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function showLogin()
    {
        return response()->json(['message' => 'Página de login']);
    }
    
    public function login(Request $request)
    {
        return response()->json(['message' => 'Fazendo login']);
    }
    
    public function showRegister()
    {
        return response()->json(['message' => 'Página de registro']);
    }
    
    public function register(Request $request)
    {
        return response()->json(['message' => 'Fazendo registro']);
    }
    
    public function logout()
    {
        return response()->json(['message' => 'Fazendo logout']);
    }
}
