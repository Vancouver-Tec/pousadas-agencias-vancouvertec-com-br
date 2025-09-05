<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->string('stripe_payment_intent_id');
            $table->string('stripe_charge_id')->nullable();
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3)->default('BRL');
            $table->enum('status', ['pending', 'succeeded', 'failed', 'cancelled', 'refunded']);
            $table->string('payment_method')->nullable();
            $table->json('stripe_response')->nullable();
            $table->text('failure_reason')->nullable();
            $table->decimal('refunded_amount', 10, 2)->default(0);
            $table->timestamp('paid_at')->nullable();
            $table->timestamp('refunded_at')->nullable();
            $table->timestamps();
            
            $table->index('stripe_payment_intent_id');
            $table->index(['booking_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');
    }
};
