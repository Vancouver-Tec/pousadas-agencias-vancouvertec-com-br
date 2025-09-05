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
