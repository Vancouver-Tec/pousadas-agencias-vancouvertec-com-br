#!/bin/bash

# ===========================================
# SETUP INICIAL - Sistema Pousadas & Agências
# Vancouver-Tec - Estrutura Laravel Manual
# ===========================================

echo "🚀 Iniciando setup do projeto..."

# Verificar se composer está instalado
if ! command -v composer &> /dev/null; then
    echo "❌ Composer não encontrado. Instale o Composer primeiro."
    exit 1
fi

# Inicializar composer.json
echo "📦 Inicializando composer.json..."
cat > composer.json << 'EOF'
{
    "name": "vancouver-tec/pousadas-agencias",
    "type": "project",
    "description": "Sistema para pousadas e agências de turismo",
    "keywords": ["laravel", "booking", "tourism", "hotels"],
    "license": "proprietary",
    "require": {
        "php": "^8.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.9",
        "stripe/stripe-php": "^10.0"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.0",
        "phpunit/phpunit": "^11.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# Criar estrutura de diretórios Laravel
echo "📁 Criando estrutura de diretórios..."
mkdir -p app/{Broadcasting,Console/{Commands},Events,Exceptions,Http/{Controllers/{Admin,Client,Site,Api},Middleware,Requests},Jobs,Listeners,Mail,Models,Notifications,Observers,Policies,Providers,Rules,Services}
mkdir -p bootstrap/{cache,providers}
mkdir -p config
mkdir -p database/{factories,migrations,seeders}
mkdir -p public/{assets,uploads,css,js,images}
mkdir -p resources/{css,js,views/{admin,client,site,components,layouts,auth},lang/{pt,en,es}}
mkdir -p routes
mkdir -p storage/{app/{public},framework/{cache/{data},sessions,testing,views},logs}
mkdir -p tests/{Feature,Unit}
mkdir -p scripts

# Criar .env.example
echo "⚙️ Criando .env.example..."
cat > .env.example << 'EOF'
APP_NAME="Vancouver-Tec Pousadas"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=America/Sao_Paulo
APP_URL=http://localhost
APP_LOCALE=pt
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=pt_BR

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=pousadas_agencias
DB_USERNAME=root
DB_PASSWORD=

STRIPE_KEY=
STRIPE_SECRET=
STRIPE_WEBHOOK_SECRET=

MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS="noreply@vancouvertec.com.br"
MAIL_FROM_NAME="${APP_NAME}"

CACHE_STORE=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=database
SESSION_DRIVER=file
SESSION_LIFETIME=120

VITE_APP_NAME="${APP_NAME}"
EOF

# Copiar .env
cp .env.example .env

# Criar artisan
echo "🔨 Criando arquivo artisan..."
cat > artisan << 'EOF'
#!/usr/bin/env php
<?php

define('LARAVEL_START', microtime(true));

// Register the Composer autoloader
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel and handle the command
$app = require_once __DIR__.'/bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);

$status = $kernel->handle(
    $input = new Symfony\Component\Console\Input\ArgvInput,
    new Symfony\Component\Console\Output\ConsoleOutput
);

$kernel->terminate($input, $status);

exit($status);
EOF

chmod +x artisan

# Criar bootstrap/app.php
cat > bootstrap/app.php << 'EOF'
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->web(append: [
            App\Http\Middleware\LanguageMiddleware::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
EOF

# Criar public/index.php
cat > public/index.php << 'EOF'
<?php

use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request
(require_once __DIR__.'/../bootstrap/app.php')
    ->handleRequest(Request::capture());
EOF

# Instalar dependências Laravel
echo "🔧 Instalando dependências Laravel..."
composer install --no-scripts

# Gerar chave da aplicação
echo "🔑 Gerando chave da aplicação..."
php artisan key:generate --show > /tmp/app_key.txt
APP_KEY=$(cat /tmp/app_key.txt)
sed -i "s/APP_KEY=.*/APP_KEY=$APP_KEY/" .env
rm /tmp/app_key.txt

# Criar .gitignore
cat > .gitignore << 'EOF'
/node_modules
/public/build
/public/hot
/public/storage
/storage/*.key
/vendor
.env
.env.backup
.env.production
.phpunit.result.cache
Homestead.json
Homestead.yaml
auth.json
npm-debug.log
yarn-error.log
/.fleet
/.idea
/.vscode
*.swp
*.swo
.DS_Store
Thumbs.db
/bootstrap/cache/*.php
/storage/framework/cache/data/*
/storage/framework/sessions/*
/storage/framework/views/*
/storage/logs/*.log
/public/uploads/*
!/public/uploads/.gitkeep
*.sql
*.backup
EOF

# Criar .gitkeep nos diretórios vazios
touch public/uploads/.gitkeep
touch storage/app/public/.gitkeep
touch bootstrap/cache/.gitkeep
touch storage/framework/cache/data/.gitkeep
touch storage/framework/sessions/.gitkeep
touch storage/framework/views/.gitkeep
touch storage/logs/.gitkeep

# Criar welcome.php na raiz
cat > welcome.php << 'EOF'
<?php
// Redirecionamento para Laravel
header('Location: /public');
exit;
EOF

echo "✅ Estrutura Laravel criada com sucesso!"
echo ""
echo "📋 Execute os comandos:"
echo "1. Configure o banco no .env"
echo "2. php artisan migrate"
echo "3. php artisan serve"
echo ""
echo "🎯 Pronto para o próximo script!"