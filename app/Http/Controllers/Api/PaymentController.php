<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function createPaymentIntent(Request $request)
    {
        return response()->json(['message' => 'Payment Intent criado']);
    }
    
    public function confirmPayment(Request $request)
    {
        return response()->json(['message' => 'Pagamento confirmado']);
    }
}
