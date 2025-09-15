<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Vancouver-Tec Pousadas')</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Custom CSS -->
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
        .booking-gradient { background: linear-gradient(135deg, #003580 0%, #0071c2 100%); }
        
        .property-card:hover .property-image {
            transform: scale(1.05);
        }
        
        .property-image {
            transition: transform 0.3s ease;
        }
        
        .search-suggestions {
            max-height: 300px;
            overflow-y: auto;
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header -->
    <header class="booking-blue text-white shadow-lg">
        <div class="container mx-auto px-4">
            <div class="flex items-center justify-between h-16">
                <!-- Logo -->
                <div class="flex items-center">
                    <a href="{{ route('site.home') }}" class="text-xl font-bold">
                        <i class="fas fa-home mr-2"></i>
                        Vancouver-Tec
                    </a>
                </div>
                
                <!-- Navigation -->
                <nav class="hidden md:flex space-x-6">
                    <a href="{{ route('site.home') }}" class="hover:text-blue-200 transition">Home</a>
                    <a href="{{ route('site.properties.index') }}" class="hover:text-blue-200 transition">Propriedades</a>
                    <a href="#" class="hover:text-blue-200 transition">Sobre</a>
                    <a href="#" class="hover:text-blue-200 transition">Contato</a>
                </nav>
                
                <!-- User Menu -->
                <div class="flex items-center space-x-4">
                    @auth
                        <div class="relative group">
                            <button class="flex items-center space-x-2 hover:text-blue-200">
                                <i class="fas fa-user-circle text-xl"></i>
                                <span>{{ Auth::user()->name }}</span>
                                <i class="fas fa-chevron-down text-sm"></i>
                            </button>
                            <div class="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg py-2 hidden group-hover:block">
                                <a href="{{ route('client.dashboard') }}" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Minha Conta</a>
                                <a href="#" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Minhas Reservas</a>
                                <a href="#" class="block px-4 py-2 text-gray-800 hover:bg-gray-100">Favoritos</a>
                                <hr class="my-2">
                                <form method="POST" action="{{ route('logout') }}">
                                    @csrf
                                    <button type="submit" class="block w-full text-left px-4 py-2 text-gray-800 hover:bg-gray-100">Sair</button>
                                </form>
                            </div>
                        </div>
                    @else
                        <a href="{{ route('login') }}" class="hover:text-blue-200">Entrar</a>
                        <a href="{{ route('register') }}" class="bg-white text-blue-800 px-4 py-2 rounded-lg hover:bg-blue-50 transition">Cadastrar</a>
                    @endauth
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main>
        @yield('content')
    </main>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white mt-16">
        <div class="container mx-auto px-4 py-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
                <div>
                    <h3 class="text-lg font-bold mb-4">Vancouver-Tec</h3>
                    <p class="text-gray-300">Sua plataforma completa para hospedagens e turismo no Brasil.</p>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Links Rápidos</h4>
                    <ul class="space-y-2 text-gray-300">
                        <li><a href="#" class="hover:text-white">Como funciona</a></li>
                        <li><a href="#" class="hover:text-white">Cadastrar propriedade</a></li>
                        <li><a href="#" class="hover:text-white">Ajuda</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Suporte</h4>
                    <ul class="space-y-2 text-gray-300">
                        <li><a href="#" class="hover:text-white">Central de Ajuda</a></li>
                        <li><a href="#" class="hover:text-white">Contato</a></li>
                        <li><a href="#" class="hover:text-white">Termos de Uso</a></li>
                    </ul>
                </div>
                <div>
                    <h4 class="font-bold mb-4">Redes Sociais</h4>
                    <div class="flex space-x-4">
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-facebook text-xl"></i></a>
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-instagram text-xl"></i></a>
                        <a href="#" class="text-gray-300 hover:text-white"><i class="fab fa-twitter text-xl"></i></a>
                    </div>
                </div>
            </div>
            <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-300">
                <p>&copy; {{ date('Y') }} Vancouver-Tec. Todos os direitos reservados.</p>
            </div>
        </div>
    </footer>

    <!-- JavaScript Global -->
    <script>
        // CSRF Token para requisições AJAX
        window.Laravel = {
            csrfToken: document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        };
        
        // Função para mostrar/ocultar menu mobile
        function toggleMobileMenu() {
            const menu = document.getElementById('mobile-menu');
            menu.classList.toggle('hidden');
        }
    </script>
    
    @stack('scripts')
</body>
</html>
