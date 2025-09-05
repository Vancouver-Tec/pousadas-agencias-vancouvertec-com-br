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
