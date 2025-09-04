# 🏨 Sistema de Pousadas & Agências - Vancouver-Tec

Sistema completo para gerenciamento de pousadas, hotéis e agências de turismo com inspiração no layout do Booking.com.

## 🌟 Características

- **Multi-idioma**: Português, Inglês e Espanhol
- **Pagamentos**: Integração Stripe (nacional/internacional)
- **Painéis**: Administrativo e Cliente
- **Site Editável**: Interface moderna e responsiva
- **Gerenciamento Completo**: Reservas, clientes, propriedades

## 🛠️ Tecnologias

- **Backend**: Laravel 11.x
- **Banco**: MySQL 8.0+
- **Frontend**: Blade + Tailwind CSS + Alpine.js
- **Pagamentos**: Stripe API
- **Multi-idioma**: Laravel Localization

## ⚡ Instalação

```bash
# Clone o repositório
git clone https://github.com/Vancouver-Tec/pousadas-agencias-vancouvertec-com-br.git
cd pousadas-agencias-vancouvertec-com-br

# Execute o setup
chmod +x scripts/01-setup-inicial.sh
./scripts/01-setup-inicial.sh

# Configure o banco
cp .env.example .env
# Edite as configurações do banco no .env

# Execute as migrations
php artisan migrate --seed

# Inicie o servidor
php artisan serve
```

## 📁 Estrutura do Projeto

```
├── app/
│   ├── Http/Controllers/
│   │   ├── Admin/          # Controllers do painel admin
│   │   ├── Client/         # Controllers do painel cliente
│   │   └── Site/           # Controllers do site público
│   ├── Models/             # Modelos Eloquent
│   └── Services/           # Serviços (Stripe, etc.)
├── resources/
│   ├── views/
│   │   ├── admin/          # Views do painel admin
│   │   ├── client/         # Views do painel cliente
│   │   └── site/           # Views do site público
│   └── lang/               # Arquivos de tradução
│       ├── pt/
│       ├── en/
│       └── es/
├── database/
│   ├── migrations/         # Migrações do banco
│   └── seeders/           # Seeds iniciais
└── public/
    ├── assets/            # Assets compilados
    └── uploads/           # Uploads de imagens
```

## 🌐 Funcionalidades

### Site Público
- [x] Homepage inspirada no Booking.com
- [x] Sistema de busca avançada
- [x] Listagem de propriedades
- [x] Sistema de reservas
- [x] Multi-idioma

### Painel Cliente
- [x] Dashboard personalizado
- [x] Gerenciar reservas
- [x] Perfil e configurações
- [x] Histórico de pagamentos

### Painel Admin
- [x] Dashboard administrativo
- [x] Gestão de propriedades
- [x] Gestão de usuários
- [x] Relatórios e analytics
- [x] Configurações do sistema

## 🚀 Deploy

### Desenvolvimento
```bash
php artisan serve
npm run dev
```

### Produção
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
npm run build
```

## 📝 Licença

Este projeto é propriedade da Vancouver-Tec. Todos os direitos reservados.

## 👥 Equipe

- **Desenvolvimento**: Vancouver-Tec Team
- **Design**: Baseado no Booking.com
- **Suporte**: suporte@vancouvertec.com.br

## 📞 Contato

- **Site**: https://vancouvertec.com.br
- **Email**: contato@vancouvertec.com.br
- **Suporte**: suporte@vancouvertec.com.br
