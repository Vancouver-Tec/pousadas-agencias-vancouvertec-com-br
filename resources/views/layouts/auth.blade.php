<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Autenticação') - Vancouver-Tec</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .booking-blue { background-color: #003580; }
        .booking-blue-light { background-color: #0071c2; }
        .booking-gradient { background: linear-gradient(135deg, #003580 0%, #0071c2 100%); }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Header Simples -->
    <header class="bg-white shadow-sm border-b">
        <div class="container mx-auto px-4 py-4">
            <a href="{{ route('site.home') }}" class="text-2xl font-bold text-blue-800">
                <i class="fas fa-home mr-2"></i>Vancouver-Tec
            </a>
        </div>
    </header>

    <!-- Conteúdo Principal -->
    <main class="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
            @yield('content')
        </div>
    </main>

    <!-- Scripts -->
    <script>
        // Show/hide password functionality
        function togglePassword(inputId, iconId) {
            const input = document.getElementById(inputId);
            const icon = document.getElementById(iconId);
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }

        // Auto-hide alerts
        setTimeout(() => {
            const alerts = document.querySelectorAll('.alert-auto-hide');
            alerts.forEach(alert => {
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 300);
            });
        }, 5000);
    </script>
    
    @stack('scripts')
</body>
</html>
