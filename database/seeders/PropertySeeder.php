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
