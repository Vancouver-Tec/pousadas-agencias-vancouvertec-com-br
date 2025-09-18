@extends('layouts.auth')

@section('title', 'Cadastro')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Crie sua conta</h2>
        <p class="mt-2 text-sm text-gray-600">
            Ou 
            <a href="{{ route('login') }}" class="font-medium text-blue-600 hover:text-blue-500">
                faça login na sua conta existente
            </a>
        </p>
    </div>

    <!-- Form -->
    <form class="space-y-6" action="{{ route('register') }}" method="POST">
        @csrf
        
        <!-- Name -->
        <div>
            <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-user mr-2"></i>Nome completo
            </label>
            <input id="name" 
                   name="name" 
                   type="text" 
                   required 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border @error('name') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="Digite seu nome completo"
                   value="{{ old('name') }}">
            @error('name')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

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
                   placeholder="Digite seu email"
                   value="{{ old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- Phone -->
        <div>
            <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-phone mr-2"></i>Telefone (opcional)
            </label>
            <input id="phone" 
                   name="phone" 
                   type="tel" 
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                   placeholder="(11) 99999-9999"
                   value="{{ old('phone') }}">
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
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border @error('password') border-red-300 @else border-gray-300 @enderror placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Mínimo 8 caracteres">
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

        <!-- Password Confirmation -->
        <div>
            <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Confirmar senha
            </label>
            <div class="relative">
                <input id="password_confirmation" 
                       name="password_confirmation" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Confirme sua senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password_confirmation', 'password-confirmation-icon')">
                    <i id="password-confirmation-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        </div>

        <!-- Terms -->
        <div class="flex items-start">
            <input id="terms" 
                   name="terms" 
                   type="checkbox" 
                   required
                   class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded mt-1 @error('terms') border-red-300 @enderror">
            <label for="terms" class="ml-2 block text-sm text-gray-900">
                Eu aceito os 
                <a href="#" class="text-blue-600 hover:text-blue-500">Termos de Uso</a> e
                <a href="#" class="text-blue-600 hover:text-blue-500">Política de Privacidade</a>
            </label>
        </div>
        @error('terms')
            <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
        @enderror

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-user-plus text-blue-300"></i>
                </span>
                Criar conta
            </button>
        </div>
    </form>
</div>
@endsection
