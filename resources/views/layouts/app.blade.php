<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Vancouver-Tec Pousadas')</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            color: #333;
            line-height: 1.6;
        }
        
        .navbar {
            background: white;
            border-bottom: 1px solid #e0e0e0;
            padding: 12px 0;
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .navbar-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 1.5rem;
            font-weight: bold;
            color: #0071c2;
            text-decoration: none;
        }
        
        .navbar-links {
            display: flex;
            gap: 20px;
            align-items: center;
        }
        
        .navbar-links a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 4px;
            transition: all 0.2s;
        }
        
        .navbar-links a:hover {
            background: #f0f0f0;
        }
        
        .btn {
            padding: 8px 16px;
            border-radius: 4px;
            text-decoration: none;
            font-weight: 500;
            border: 1px solid transparent;
            cursor: pointer;
            display: inline-block;
            transition: all 0.2s;
            background: none;
            font-size: 14px;
        }
        
        .btn-primary {
            background: #0071c2;
            color: white;
            border-color: #0071c2;
        }
        
        .btn-primary:hover {
            background: #005999;
            border-color: #005999;
        }
        
        .btn-secondary {
            background: transparent;
            color: #0071c2;
            border-color: #0071c2;
        }
        
        .btn-secondary:hover {
            background: #0071c2;
            color: white;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .alert {
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
            transition: border-color 0.2s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #0071c2;
            box-shadow: 0 0 0 2px rgba(0,113,194,0.1);
        }
        
        .invalid-feedback {
            color: #dc3545;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .is-invalid {
            border-color: #dc3545;
        }
        
        .footer {
            background: #003580;
            color: white;
            text-align: center;
            padding: 40px 20px;
            margin-top: 60px;
        }
        
        @media (max-width: 768px) {
            .navbar-content {
                flex-direction: column;
                gap: 10px;
            }
            
            .navbar-links {
                flex-wrap: wrap;
                justify-content: center;
            }
            
            .container {
                padding: 10px;
            }
        }
    </style>
    @yield('styles')
</head>
<body>
    <nav class="navbar">
        <div class="navbar-content">
            <a href="{{ route('home') }}" class="logo">🏨 Vancouver-Tec</a>
            <div class="navbar-links">
                @auth
                    <span>Olá, {{ Auth::user()->name }}!</span>
                    @if(Auth::user()->isAdmin())
                        <a href="{{ route('admin.dashboard') }}">Dashboard Admin</a>
                    @else
                        <a href="{{ route('client.dashboard') }}">Minha Conta</a>
                    @endif
                    <form action="{{ route('logout') }}" method="POST" style="display: inline;">
                        @csrf
                        <button type="submit" class="btn btn-secondary">Sair</button>
                    </form>
                @else
                    <a href="{{ route('login') }}">Entrar</a>
                    <a href="{{ route('register') }}" class="btn btn-primary">Cadastrar</a>
                @endauth
            </div>
        </div>
    </nav>

    <main>
        @if(session('success'))
            <div class="container">
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            </div>
        @endif

        @if(session('error'))
            <div class="container">
                <div class="alert alert-error">
                    {{ session('error') }}
                </div>
            </div>
        @endif

        @yield('content')
    </main>

    <footer class="footer">
        <div>
            <p>&copy; {{ date('Y') }} Vancouver-Tec Pousadas. Todos os direitos reservados.</p>
            <p>Sistema de reservas para pousadas e agências de turismo.</p>
        </div>
    </footer>

    @yield('scripts')
</body>
</html>
