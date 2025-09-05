#!/bin/bash

# ===========================================
# SEEDERS & FACTORIES - Sistema Pousadas
# Vancouver-Tec - Dados de teste e demonstração
# ===========================================

echo "🌱 Criando Seeders e Factories..."

# ===========================================
# USER FACTORY
# ===========================================

echo "🏭 Criando UserFactory..."
cat > database/factories/UserFactory.php << 'EOF'
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        $cities = [
            'São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Salvador', 
            'Brasília', 'Fortaleza', 'Recife', 'Porto Alegre', 'Curitiba'
        ];
        
        $states = [
            'SP', 'RJ', 'MG', 'BA', 'DF', 'CE', 'PE', 'RS', 'PR'
        ];
        
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => Hash::make('123456'),
            'role' => fake()->randomElement(['client', 'client', 'client', 'admin']),
            'phone' => fake()->phoneNumber(),
            'document' => fake()->numerify('###.###.###-##'),
            'birth_date' => fake()->dateTimeBetween('-65 years', '-18 years'),
            'address' => fake()->streetAddress(),
            'city' => fake()->randomElement($cities),
            'state' => fake()->randomElement($states),
            'country' => 'Brazil',
            'zip_code' => fake()->numerify('#####-###'),
            'preferred_language' => fake()->randomElement(['pt', 'en', 'es']),
            'is_active' => true,
            'remember_token' => Str::random(10),
        ];
    }

    public function admin()
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'admin',
            'email' => 'admin@vancouvertec.com.br',
            'name' => 'Vancouver-Tec Admin',
        ]);
    }

    public function client()
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'client',
        ]);
    }
}
EOF

# ===========================================
# PROPERTY FACTORY
# ===========================================

echo "🏭 Criando PropertyFactory..."
cat > database/factories/PropertyFactory.php << 'EOF'
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class PropertyFactory extends Factory
{
    public function definition(): array
    {
        $types = ['hotel', 'pousada', 'resort', 'apartment', 'house'];
        $cities = [
            ['name' => 'Gramado', 'state' => 'RS'],
            ['name' => 'Campos do Jordão', 'state' => 'SP'],
            ['name' => 'Búzios', 'state' => 'RJ'],
            ['name' => 'Porto de Galinhas', 'state' => 'PE'],
            ['name' => 'Jericoacoara', 'state' => 'CE'],
            ['name' => 'Florianópolis', 'state' => 'SC'],
            ['name' => 'Salvador', 'state' => 'BA'],
            ['name' => 'Paraty', 'state' => 'RJ'],
            ['name' => 'Tiradentes', 'state' => 'MG'],
            ['name' => 'Monte Verde', 'state' => 'MG']
        ];

        $amenities = [
            'WiFi Gratuito', 'Piscina', 'Academia', 'Estacionamento',
            'Café da Manhã', 'Ar Condicionado', 'TV por Cabo',
            'Frigobar', 'Room Service', 'Spa', 'Restaurante',
            'Bar', 'Lavanderia', 'Pet Friendly'
        ];

        $city = fake()->randomElement($cities);
        $type = fake()->randomElement($types);
        $bedrooms = fake()->numberBetween(1, 5);
        $bathrooms = fake()->numberBetween(1, $bedrooms + 1);
        $maxGuests = $bedrooms * 2;
        
        $images = [
            'https://picsum.photos/800/600?random=' . fake()->numberBetween(1, 100),
            'https://picsum.photos/800/600?random=' . fake()->numberBetween(101, 200),
            'https://picsum.photos/800/600?random=' . fake()->numberBetween(201, 300),
            'https://picsum.photos/800/600?random=' . fake()->numberBetween(301, 400),
        ];

        return [
            'name' => $this->generatePropertyName($type, $city['name']),
            'description' => fake()->paragraphs(3, true),
            'type' => $type,
            'address' => fake()->streetAddress(),
            'city' => $city['name'],
            'state' => $city['state'],
            'country' => 'Brazil',
            'zip_code' => fake()->numerify('#####-###'),
            'latitude' => fake()->latitude(-33, 5),
            'longitude' => fake()->longitude(-74, -34),
            'price_per_night' => fake()->randomFloat(2, 80, 800),
            'max_guests' => $maxGuests,
            'bedrooms' => $bedrooms,
            'bathrooms' => $bathrooms,
            'amenities' => json_encode(fake()->randomElements($amenities, fake()->numberBetween(3, 8))),
            'images' => json_encode($images),
            'rating' => fake()->randomFloat(1, 3.5, 5.0),
            'reviews_count' => fake()->numberBetween(0, 150),
            'is_active' => fake()->boolean(90),
            'instant_book' => fake()->boolean(30),
            'check_in_hours' => json_encode(['from' => '14:00', 'to' => '22:00']),
            'check_out_hours' => json_encode(['from' => '08:00', 'to' => '12:00']),
            'house_rules' => fake()->paragraphs(2, true),
            'cancellation_policy' => 'Cancelamento gratuito até 24 horas antes do check-in.',
        ];
    }

    private function generatePropertyName($type, $city)
    {
        $prefixes = [
            'hotel' => ['Hotel', 'Grand Hotel', 'Luxury Hotel'],
            'pousada' => ['Pousada', 'Pousada do', 'Pousada da'],
            'resort' => ['Resort', 'Grand Resort', 'Paradise Resort'],
            'apartment' => ['Apartamento', 'Loft', 'Studio'],
            'house' => ['Casa', 'Chalé', 'Villa']
        ];

        $suffixes = [
            'das Flores', 'do Sol', 'Vista Mar', 'Encantado', 'Paradise',
            'Real', 'Premium', 'Imperial', 'Tropical', 'Garden'
        ];

        $prefix = fake()->randomElement($prefixes[$type]);
        $suffix = fake()->randomElement($suffixes);

        return "$prefix $suffix - $city";
    }
}
EOF

# ===========================================
# BOOKING FACTORY
# ===========================================

echo "🏭 Criando BookingFactory..."
cat > database/factories/BookingFactory.php << 'EOF'
<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Property;
use Illuminate\Database\Eloquent\Factories\Factory;
use Carbon\Carbon;

class BookingFactory extends Factory
{
    public function definition(): array
    {
        $checkIn = fake()->dateTimeBetween('-6 months', '+3 months');
        $nights = fake()->numberBetween(1, 14);
        $checkOut = Carbon::parse($checkIn)->addDays($nights);
        $pricePerNight = fake()->randomFloat(2, 80, 500);
        $subtotal = $pricePerNight * $nights;
        $taxes = $subtotal * 0.05; // 5% de taxas
        $fees = fake()->randomFloat(2, 10, 50);
        $total = $subtotal + $taxes + $fees;

        return [
            'user_id' => User::where('role', 'client')->inRandomOrder()->first()?->id ?? User::factory()->client(),
            'property_id' => Property::inRandomOrder()->first()?->id ?? Property::factory(),
            'booking_number' => 'BK' . fake()->unique()->numerify('######'),
            'check_in' => $checkIn,
            'check_out' => $checkOut,
            'guests' => fake()->numberBetween(1, 6),
            'nights' => $nights,
            'price_per_night' => $pricePerNight,
            'subtotal' => $subtotal,
            'taxes' => $taxes,
            'fees' => $fees,
            'total' => $total,
            'status' => fake()->randomElement(['pending', 'confirmed', 'cancelled', 'completed']),
            'payment_status' => fake()->randomElement(['pending', 'paid', 'failed', 'refunded']),
            'payment_method' => fake()->randomElement(['credit_card', 'debit_card', 'pix']),
            'stripe_payment_intent_id' => fake()->optional()->regexify('pi_[a-zA-Z0-9]{24}'),
            'special_requests' => fake()->optional()->sentence(),
            'cancellation_reason' => fake()->optional()->sentence(),
            'cancelled_at' => fake()->optional()->dateTime(),
        ];
    }
}
EOF

# ===========================================
# PAYMENT FACTORY
# ===========================================

echo "🏭 Criando PaymentFactory..."
cat > database/factories/PaymentFactory.php << 'EOF'
<?php

namespace Database\Factories;

use App\Models\Booking;
use Illuminate\Database\Eloquent\Factories\Factory;

class PaymentFactory extends Factory
{
    public function definition(): array
    {
        $amount = fake()->randomFloat(2, 50, 1000);
        
        return [
            'booking_id' => Booking::inRandomOrder()->first()?->id ?? Booking::factory(),
            'stripe_payment_intent_id' => fake()->regexify('pi_[a-zA-Z0-9]{24}'),
            'stripe_charge_id' => fake()->regexify('ch_[a-zA-Z0-9]{24}'),
            'amount' => $amount,
            'currency' => 'BRL',
            'status' => fake()->randomElement(['pending', 'succeeded', 'failed', 'cancelled', 'refunded']),
            'payment_method' => fake()->randomElement(['card', 'pix', 'boleto']),
            'stripe_response' => json_encode(['id' => fake()->uuid(), 'status' => 'succeeded']),
            'failure_reason' => fake()->optional()->sentence(),
            'refunded_amount' => 0,
            'paid_at' => fake()->optional()->dateTime(),
            'refunded_at' => fake()->optional()->dateTime(),
        ];
    }
}
EOF

# ===========================================
# REVIEW FACTORY
# ===========================================

echo "🏭 Criando ReviewFactory..."
cat > database/factories/ReviewFactory.php << 'EOF'
<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Property;
use App\Models\Booking;
use Illuminate\Database\Eloquent\Factories\Factory;

class ReviewFactory extends Factory
{
    public function definition(): array
    {
        $rating = fake()->numberBetween(3, 5);
        
        $comments = [
            'Lugar incrível! Superou nossas expectativas.',
            'Muito bom, recomendo para famílias.',
            'Excelente localização e atendimento.',
            'Propriedade bem cuidada e limpa.',
            'Ótima experiência, voltaremos com certeza!',
            'Muito confortável e bem localizado.',
            'Atendimento excepcional da equipe.',
            'Vista maravilhosa e café da manhã delicioso.'
        ];

        return [
            'user_id' => User::where('role', 'client')->inRandomOrder()->first()?->id ?? User::factory()->client(),
            'property_id' => Property::inRandomOrder()->first()?->id ?? Property::factory(),
            'booking_id' => Booking::inRandomOrder()->first()?->id ?? Booking::factory(),
            'rating' => $rating,
            'cleanliness_rating' => fake()->numberBetween($rating - 1, 5),
            'location_rating' => fake()->numberBetween($rating - 1, 5),
            'value_rating' => fake()->numberBetween($rating - 1, 5),
            'service_rating' => fake()->numberBetween($rating - 1, 5),
            'comment' => fake()->randomElement($comments),
            'owner_response' => fake()->optional(0.3)->sentence(),
            'owner_response_at' => fake()->optional()->dateTime(),
            'is_verified' => fake()->boolean(80),
            'is_public' => fake()->boolean(95),
        ];
    }
}
EOF

# ===========================================
# FAVORITE FACTORY
# ===========================================

echo "🏭 Criando FavoriteFactory..."
cat > database/factories/FavoriteFactory.php << 'EOF'
<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Property;
use Illuminate\Database\Eloquent\Factories\Factory;

class FavoriteFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::where('role', 'client')->inRandomOrder()->first()?->id ?? User::factory()->client(),
            'property_id' => Property::inRandomOrder()->first()?->id ?? Property::factory(),
        ];
    }
}
EOF

# ===========================================
# DATABASE SEEDER
# ===========================================

echo "🌱 Criando DatabaseSeeder..."
cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            UserSeeder::class,
            PropertySeeder::class,
            BookingSeeder::class,
            PaymentSeeder::class,
            ReviewSeeder::class,
            FavoriteSeeder::class,
        ]);
    }
}
EOF

# ===========================================
# USER SEEDER
# ===========================================

echo "🌱 Criando UserSeeder..."
cat > database/seeders/UserSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin padrão
        User::factory()->admin()->create([
            'name' => 'Vancouver-Tec Admin',
            'email' => 'admin@vancouvertec.com.br',
        ]);

        // Cliente de teste
        User::factory()->client()->create([
            'name' => 'Cliente Teste',
            'email' => 'cliente@test.com',
        ]);

        // Clientes aleatórios
        User::factory()->client()->count(25)->create();

        // Mais alguns admins
        User::factory()->count(3)->create(['role' => 'admin']);
    }
}
EOF

# ===========================================
# PROPERTY SEEDER
# ===========================================

echo "🌱 Criando PropertySeeder..."
cat > database/seeders/PropertySeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\Property;
use App\Models\User;
use Illuminate\Database\Seeder;

class PropertySeeder extends Seeder
{
    public function run(): void
    {
        // Propriedades especiais destacadas
        $this->createFeaturedProperties();
        
        // Propriedades aleatórias
        Property::factory()->count(50)->create();
    }

    private function createFeaturedProperties()
    {
        $featured = [
            [
                'name' => 'Resort Paradise - Gramado',
                'description' => 'Luxuoso resort em Gramado com vista para as montanhas. Perfeito para lua de mel e relaxamento.',
                'type' => 'resort',
                'city' => 'Gramado',
                'state' => 'RS',
                'price_per_night' => 450.00,
                'max_guests' => 4,
                'bedrooms' => 2,
                'bathrooms' => 2,
                'rating' => 4.8,
                'reviews_count' => 127,
            ],
            [
                'name' => 'Pousada Vista Mar - Búzios',
                'description' => 'Charmosa pousada à beira-mar em Búzios. Vista deslumbrante do oceano.',
                'type' => 'pousada',
                'city' => 'Búzios',
                'state' => 'RJ',
                'price_per_night' => 320.00,
                'max_guests' => 6,
                'bedrooms' => 3,
                'bathrooms' => 2,
                'rating' => 4.6,
                'reviews_count' => 89,
            ],
            [
                'name' => 'Hotel Boutique Centro - São Paulo',
                'description' => 'Moderno hotel boutique no coração de São Paulo. Ideal para viagens de negócios.',
                'type' => 'hotel',
                'city' => 'São Paulo',
                'state' => 'SP',
                'price_per_night' => 280.00,
                'max_guests' => 2,
                'bedrooms' => 1,
                'bathrooms' => 1,
                'rating' => 4.4,
                'reviews_count' => 203,
            ],
            [
                'name' => 'Casa Colonial - Paraty',
                'description' => 'Autêntica casa colonial no centro histórico de Paraty. Experiência única.',
                'type' => 'house',
                'city' => 'Paraty',
                'state' => 'RJ',
                'price_per_night' => 180.00,
                'max_guests' => 8,
                'bedrooms' => 4,
                'bathrooms' => 3,
                'rating' => 4.9,
                'reviews_count' => 156,
            ]
        ];

        foreach ($featured as $data) {
            Property::factory()->create(array_merge($data, [
                'address' => fake()->streetAddress(),
                'country' => 'Brazil',
                'zip_code' => fake()->numerify('#####-###'),
                'latitude' => fake()->latitude(-33, 5),
                'longitude' => fake()->longitude(-74, -34),
                'amenities' => json_encode([
                    'WiFi Gratuito', 'Piscina', 'Café da Manhã',
                    'Ar Condicionado', 'Estacionamento'
                ]),
                'images' => json_encode([
                    'https://picsum.photos/800/600?random=' . rand(1, 1000),
                    'https://picsum.photos/800/600?random=' . rand(1001, 2000),
                    'https://picsum.photos/800/600?random=' . rand(2001, 3000),
                ]),
                'is_active' => true,
                'instant_book' => true,
                'check_in_hours' => json_encode(['from' => '14:00', 'to' => '22:00']),
                'check_out_hours' => json_encode(['from' => '08:00', 'to' => '12:00']),
                'house_rules' => 'Não fumar. Animais permitidos com taxa adicional.',
                'cancellation_policy' => 'Cancelamento gratuito até 48 horas antes.'
            ]));
        }
    }
}
EOF

# ===========================================
# BOOKING SEEDER
# ===========================================

echo "🌱 Criando BookingSeeder..."
cat > database/seeders/BookingSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\Booking;
use Illuminate\Database\Seeder;

class BookingSeeder extends Seeder
{
    public function run(): void
    {
        Booking::factory()->count(150)->create();
    }
}
EOF

# ===========================================
# PAYMENT SEEDER
# ===========================================

echo "🌱 Criando PaymentSeeder..."
cat > database/seeders/PaymentSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\Payment;
use Illuminate\Database\Seeder;

class PaymentSeeder extends Seeder
{
    public function run(): void
    {
        Payment::factory()->count(100)->create();
    }
}
EOF

# ===========================================
# REVIEW SEEDER
# ===========================================

echo "🌱 Criando ReviewSeeder..."
cat > database/seeders/ReviewSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\Review;
use Illuminate\Database\Seeder;

class ReviewSeeder extends Seeder
{
    public function run(): void
    {
        Review::factory()->count(200)->create();
    }
}
EOF

# ===========================================
# FAVORITE SEEDER
# ===========================================

echo "🌱 Criando FavoriteSeeder..."
cat > database/seeders/FavoriteSeeder.php << 'EOF'
<?php

namespace Database\Seeders;

use App\Models\Favorite;
use Illuminate\Database\Seeder;

class FavoriteSeeder extends Seeder
{
    public function run(): void
    {
        Favorite::factory()->count(75)->create();
    }
}
EOF

echo "✅ Seeders e Factories criados!"
echo ""
echo "📋 Execute os comandos:"
echo "php artisan migrate:fresh"
echo "php artisan db:seed"
echo ""
echo "🎯 Dados que serão criados:"
echo "  • 30+ usuários (admin + clientes)"
echo "  • 54+ propriedades (4 destacadas + 50 aleatórias)"
echo "  • 150 reservas"
echo "  • 100 pagamentos"
echo "  • 200 avaliações"
echo "  • 75 favoritos"
echo ""
echo "🔐 Usuários de teste:"
echo "  Admin: admin@vancouvertec.com.br | 123456"
echo "  Cliente: cliente@test.com | 123456"