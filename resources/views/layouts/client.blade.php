<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Minha Conta') - Vancouver-Tec Pousadas</title>
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
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 30px;
        }
        
        .sidebar {
            background: white;
            border-radius: 8px;
            padding: 20px;
            height: fit-content;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .sidebar-header {
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
            margin-bottom: 15px;
        }
        
        .sidebar-header h3 {
            color: #0071c2;
            font-size: 1.1rem;
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 12px;
            color: #666;
            text-decoration: none;
            border-radius: 6px;
            transition: all 0.2s;
        }
        
        .sidebar-menu a:hover,
        .sidebar-menu a.active {
            background: #0071c2;
            color: white;
        }
        
        .sidebar-menu a .icon {
            margin-right: 10px;
            width: 20px;
        }
        
        .main-content {
            background: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .page-header {
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .page-header h1 {
            color: #333;
            font-size: 2rem;
            margin-bottom: 5px;
        }
        
        .page-header p {
            color: #666;
        }
        
        .btn {
            padding: 10px 20px;
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
            background: #f8f9fa;
            color: #495057;
            border-color: #dee2e6;
        }
        
        .btn-secondary:hover {
            background: #e2e6ea;
            border-color: #dae0e5;
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #0071c2 0%, #005999 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-number {
            font-size: 2rem;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .stat-label {
            opacity: 0.9;
        }
        
        .card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 20px;
        }
        
        .card-header {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0e0;
            font-weight: 600;
        }
        
        .card-body {
            padding: 20px;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .table th,
        .table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        
        .table th {
            background: #f8f9fa;
            font-weight: 600;
        }
        
        .badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-success {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-warning {
            background: #fff3cd;
            color: #856404;
        }
        
        .badge-danger {
            background: #f8d7da;
            color: #721c24;
        }
        
        .badge-info {
            background: #d1ecf1;
            color: #0c5460;
        }
        
        @media (max-width: 768px) {
            .container {
                grid-template-columns: 1fr;
                padding: 10px;
            }
            
            .sidebar {
                order: 2;
            }
            
            .main-content {
                order: 1;
            }
            
            .stats-grid {
                grid-template-columns: 1fr 1fr;
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
                <span>Olá, {{ Auth::user()->name }}!</span>
                <a href="{{ route('home') }}">Ver Site</a>
                <form action="{{ route('logout') }}" method="POST" style="display: inline;">
                    @csrf
                    <button type="submit" class="btn btn-secondary">Sair</button>
                </form>
            </div>
        </div>
    </nav>

    <div class="container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h3>Minha Conta</h3>
            </div>
            <ul class="sidebar-menu">
                <li><a href="{{ route('client.dashboard') }}" class="{{ request()->routeIs('client.dashboard') ? 'active' : '' }}">
                    <span class="icon">📊</span> Dashboard
                </a></li>
                <li><a href="{{ route('client.bookings') }}" class="{{ request()->routeIs('client.bookings*') ? 'active' : '' }}">
                    <span class="icon">📅</span> Minhas Reservas
                </a></li>
                <li><a href="{{ route('client.favorites') }}" class="{{ request()->routeIs('client.favorites') ? 'active' : '' }}">
                    <span class="icon">❤️</span> Favoritos
                </a></li>
                <li><a href="{{ route('client.profile') }}" class="{{ request()->routeIs('client.profile') ? 'active' : '' }}">
                    <span class="icon">👤</span> Perfil
                </a></li>
            </ul>
        </aside>

        <main class="main-content">
            @if(session('success'))
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-error">
                    {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>

    @yield('scripts')
</body>
</html>
