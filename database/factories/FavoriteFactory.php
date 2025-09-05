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
