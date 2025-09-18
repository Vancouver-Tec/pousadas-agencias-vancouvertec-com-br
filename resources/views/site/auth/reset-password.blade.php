@extends('layouts.auth')

@section('title', 'Redefinir Senha')

@section('content')
<div>
    <!-- Header -->
    <div class="text-center mb-8">
        <h2 class="text-3xl font-bold text-gray-900">Redefinir senha</h2>
        <p class="mt-2 text-sm text-gray-600">
            Digite sua nova senha
        </p>
    </div>

    <!-- Form -->
    <form class="space-y-6" action="{{ route('password.update') }}" method="POST">
        @csrf
        
        <!-- Hidden Token -->
        <input type="hidden" name="token" value="{{ $token }}">

        <!-- Email -->
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-envelope mr-2"></i>Email
            </label>
            <input id="email" 
                   name="email" 
                   type="email" 
                   required 
                   readonly
                   class="appearance-none rounded-lg relative block w-full px-3 py-3 border border-gray-300 bg-gray-50 text-gray-900"
                   value="{{ $email ?? old('email') }}">
            @error('email')
                <p class="mt-1 text-sm text-red-600">{{ $message }}</p>
            @enderror
        </div>

        <!-- New Password -->
        <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Nova senha
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

        <!-- Confirm Password -->
        <div>
            <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">
                <i class="fas fa-lock mr-2"></i>Confirmar nova senha
            </label>
            <div class="relative">
                <input id="password_confirmation" 
                       name="password_confirmation" 
                       type="password" 
                       required 
                       class="appearance-none rounded-lg relative block w-full px-3 py-3 pr-10 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                       placeholder="Confirme sua nova senha">
                <button type="button" 
                        class="absolute inset-y-0 right-0 pr-3 flex items-center"
                        onclick="togglePassword('password_confirmation', 'password-confirmation-icon')">
                    <i id="password-confirmation-icon" class="fas fa-eye text-gray-400 hover:text-gray-600"></i>
                </button>
            </div>
        </div>

        <!-- Submit Button -->
        <div>
            <button type="submit" 
                    class="group relative w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white booking-blue hover:booking-blue-light focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-colors">
                <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                    <i class="fas fa-key text-blue-300"></i>
                </span>
                Redefinir senha
            </button>
        </div>
    </form>
</div>
@endsection
