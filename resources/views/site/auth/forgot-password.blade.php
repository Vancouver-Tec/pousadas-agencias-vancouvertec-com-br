@extends('layouts.auth')

@section('title', 'Recuperar Senha')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Esqueceu sua senha?</h2>
        <p class="mt-2 text-sm text-gray-600">
            Digite seu email e enviaremos um link para redefinir sua senha
        </p>
    </div>

    <!-- Success Message -->
    @if (session('status'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg">
            <i class="fas fa-check-circle mr-2"></i>{{ session('status') }}
        </div>
    @endif

    <!-- Form -->
    <form class="space-y-6" action="{{ route('password.email') }}" method="POST">
        @csrf
        
        <!-- Email -->
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2"></i>Email
            </label>
            <input id="email" 
                   name="email" 
                   type="email" 
                   required 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('email') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="Digite seu email cadastrado"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-paper-plane text-blue-300"></i>
                </span>
                Enviar link de recuperação
            </button>
        </div>

        <!-- Back to Login -->
        <div class="text-center">
            <a href="{{ route('login') }}" class="text-sm text-blue-600 hover:text-blue-500">
                <i class="fas fa-arrow-left mr-2"></i>Voltar para o login
            </a>
        </div>
    </form>
</div>
@endsection
