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
