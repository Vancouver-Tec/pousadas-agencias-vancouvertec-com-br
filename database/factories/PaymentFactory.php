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
