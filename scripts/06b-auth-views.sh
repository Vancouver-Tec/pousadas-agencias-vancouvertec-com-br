#!/bin/bash

# ===========================================
# VIEWS DE AUTENTICAÇÃO - Sistema Pousadas
# Vancouver-Tec - Login e Register (PARTE 2)
# ===========================================

echo "🔐 Criando views de autenticação..."

# ===========================================
# VIEW DE LOGIN
# ===========================================

echo "🔐 Criando view de login..."
mkdir -p resources/views/auth
cat > resources/views/auth/login.blade.php << 'EOF'
@extends('layouts.app')

@section('title', 'Entrar - Vancouver-Tec Pousadas')

@section('styles')
<style>
    .auth-container {
        min-height: calc(100vh - 200px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }
    
    .auth-card {
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        padding: 40px;
        width: 100%;
        max-width: 400px;
    }
    
    .auth-header {
        text-align: center;
        margin-bottom: 30px;
    }
    
    .auth-header h1 {
        color: #333;
        font-size: 2rem;
        margin-bottom: 10px;
    }
    
    .auth-header p {
        color: #666;
    }
    
    .form-check {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 20px;
    }
    
    .form-check input[type="checkbox"] {
        transform: scale(1.1);
    }
    
    .auth-footer {
        text-align: center;
        margin-top: 30px;
        padding-top: 20px;
        border-top: 1px solid #eee;
    }
    
    .auth-footer a {
        color: #0071c2;
        text-decoration: none;
        font-weight: 500;
    }
    
    .auth-footer a:hover {
        text-decoration: underline;
    }
</style>
@endsection

@section('content')
<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <h1>Entrar</h1>
            <p>Acesse sua conta para gerenciar suas reservas</p>
        </div>

        <form action="{{ route('login') }}" method="POST">
            @csrf
            
            <div class="form-group">
                <label for="email">E-mail</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    class="form-control @error('email') is-invalid @enderror"
                    value="{{ old('email') }}"
                    required
                    autocomplete="email"
                    autofocus
                >
                @error('email')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-group">
                <label for="password">Senha</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    class="form-control @error('password') is-invalid @enderror"
                    required
                    autocomplete="current-password"
                >
                @error('password')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-check">
                <input type="checkbox" id="remember" name="remember" {{ old('remember') ? 'checked' : '' }}>
                <label for="remember">Lembrar de mim</label>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 16px;">
                Entrar
            </button>
        </form>

        <div class="auth-footer">
            <p>Não tem uma conta? <a href="{{ route('register') }}">Cadastre-se aqui</a></p>
        </div>
    </div>
</div>
@endsection
EOF

# ===========================================
# VIEW DE REGISTRO
# ===========================================

echo "📝 Criando view de registro..."
cat > resources/views/auth/register.blade.php << 'EOF'
@extends('layouts.app')

@section('title', 'Cadastrar - Vancouver-Tec Pousadas')

@section('styles')
<style>
    .auth-container {
        min-height: calc(100vh - 200px);
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }
    
    .auth-card {
        background: white;
        border-radius: 8px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        padding: 40px;
        width: 100%;
        max-width: 500px;
    }
    
    .auth-header {
        text-align: center;
        margin-bottom: 30px;
    }
    
    .auth-header h1 {
        color: #333;
        font-size: 2rem;
        margin-bottom: 10px;
    }
    
    .auth-header p {
        color: #666;
    }
    
    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 15px;
    }
    
    .auth-footer {
        text-align: center;
        margin-top: 30px;
        padding-top: 20px;
        border-top: 1px solid #eee;
    }
    
    .auth-footer a {
        color: #0071c2;
        text-decoration: none;
        font-weight: 500;
    }
    
    .auth-footer a:hover {
        text-decoration: underline;
    }
    
    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }
    }
</style>
@endsection

@section('content')
<div class="auth-container">
    <div class="auth-card">
        <div class="auth-header">
            <h1>Criar Conta</h1>
            <p>Cadastre-se para fazer suas reservas</p>
        </div>

        <form action="{{ route('register') }}" method="POST">
            @csrf
            
            <div class="form-group">
                <label for="name">Nome Completo *</label>
                <input 
                    type="text" 
                    id="name" 
                    name="name" 
                    class="form-control @error('name') is-invalid @enderror"
                    value="{{ old('name') }}"
                    required
                    autocomplete="name"
                    autofocus
                >
                @error('name')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-group">
                <label for="email">E-mail *</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    class="form-control @error('email') is-invalid @enderror"
                    value="{{ old('email') }}"
                    required
                    autocomplete="email"
                >
                @error('email')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="password">Senha *</label>
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        class="form-control @error('password') is-invalid @enderror"
                        required
                        autocomplete="new-password"
                    >
                    @error('password')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="password_confirmation">Confirmar Senha *</label>
                    <input 
                        type="password" 
                        id="password_confirmation" 
                        name="password_confirmation" 
                        class="form-control"
                        required
                        autocomplete="new-password"
                    >
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="phone">Telefone</label>
                    <input 
                        type="text" 
                        id="phone" 
                        name="phone" 
                        class="form-control @error('phone') is-invalid @enderror"
                        value="{{ old('phone') }}"
                        placeholder="(11) 99999-9999"
                    >
                    @error('phone')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <div class="form-group">
                    <label for="document">CPF/RG</label>
                    <input 
                        type="text" 
                        id="document" 
                        name="document" 
                        class="form-control @error('document') is-invalid @enderror"
                        value="{{ old('document') }}"
                        placeholder="000.000.000-00"
                    >
                    @error('document')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>
            </div>

            <div class="form-group">
                <label for="birth_date">Data de Nascimento</label>
                <input 
                    type="date" 
                    id="birth_date" 
                    name="birth_date" 
                    class="form-control @error('birth_date') is-invalid @enderror"
                    value="{{ old('birth_date') }}"
                >
                @error('birth_date')
                    <div class="invalid-feedback">{{ $message }}</div>
                @enderror
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 16px;">
                Criar Conta
            </button>
        </form>

        <div class="auth-footer">
            <p>Já tem uma conta? <a href="{{ route('login') }}">Entre aqui</a></p>
        </div>
    </div>
</div>
@endsection
EOF

echo "✅ Views de autenticação criadas!"
echo ""
echo "🔄 Execute:"
echo "chmod +x 06b-auth-views.sh && ./06b-auth-views.sh"
echo ""
echo "🎯 Próximo: Dashboard do cliente (06c-dashboard-cliente.sh)"