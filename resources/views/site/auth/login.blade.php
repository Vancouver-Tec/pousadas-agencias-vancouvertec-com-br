@extends('layouts.auth')

@section('title', 'Login')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Entre na sua conta</h2>
        <p class="mt-2 text-sm text-gray-600">
            Ou 
            <a href="{{ route('register') }}" class="font-medium text-blue-600 hover:text-blue-500">
                crie uma conta gratuita
            </a>
        </p>
    </div>

    <!-- Alerts -->
    @if (session('status'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg alert-auto-hide">
            <i class="fas fa-check-circle mr-2"></i>{{ session('status') }}
        </div>
    @endif

    @if (session('success'))
        <div class="mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg alert-auto-hide">
            <i class="fas fa-check-circle mr-2"></i>{{ session('success') }}
        </div>
    @endif

    <!-- Form -->
    <form class="space-y-6" action="{{ route('login') }}" method="POST">
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
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('email') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10"
                   placeholder="Digite seu email"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Password -->
        <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Senha
            </label>
            <div class="relative">
                <input id="password" 
                       name="password" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border @error('password') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10"
                       placeholder="Digite sua senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password', 'password-icon')">
                    <i id="password-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
            @error('password')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Remember & Forgot -->
        <div class="flex items-center justify-between">
            <div class="flex items-center">
                <input id="remember" 
                       name="remember" 
                       type="checkbox" 
                       class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                <label for="remember" class="ml-2 block text-sm text-gray-900">
                    Lembrar de mim
                </label>
            </div>

            <div class="text-sm">
                <a href="{{ route('password.request') }}" class="font-medium text-blue-600 hover:text-blue-500">
                    Esqueceu sua senha?
                </a>
            </div>
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-sign-in-alt text-blue-300"></i>
                </span>
                Entrar
            </button>
        </div>

        <!-- Social Login (placeholder) -->
        <div class="mt-6">
            <div class="relative">
                <div class="absolute inset-0 flex items-center">
                    <div class="w-full border-t border-gray-300"></div>
                </div>
                <div class="relative flex justify-center text-sm">
                    <span class="px-2 bg-gray-50 text-gray-500">Ou continue com</span>
                </div>
            </div>

            <div class="mt-6 grid grid-cols-2 gap-3">
                <button type="button" class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                    <i class="fab fa-google text-red-500"></i>
                    <span class="ml-2">Google</span>
                </button>

                <button type="button" class="w-full inline-flex justify-center py-2 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                    <i class="fab fa-facebook text-blue-600"></i>
                    <span class="ml-2">Facebook</span>
                </button>
            </div>
        </div>
    </form>
</div>
@endsection
