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
