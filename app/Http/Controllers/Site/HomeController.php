<?php

namespace App\Http\Controllers\Site;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class HomeController extends Controller
{
    public function index()
    {
        return view('site.home', [
            'title' => 'Encontre sua próxima estadia',
            'subtitle' => 'Encontre ofertas em hotéis, casas, apartamentos e muito mais...'
        ]);
    }
}
