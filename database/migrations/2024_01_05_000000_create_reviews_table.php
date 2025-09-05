<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('property_id')->constrained()->onDelete('cascade');
            $table->foreignId('booking_id')->constrained()->onDelete('cascade');
            $table->integer('rating'); // 1-5
            $table->integer('cleanliness_rating')->nullable(); // 1-5
            $table->integer('location_rating')->nullable(); // 1-5
            $table->integer('value_rating')->nullable(); // 1-5
            $table->integer('service_rating')->nullable(); // 1-5
            $table->text('comment');
            $table->text('owner_response')->nullable();
            $table->timestamp('owner_response_at')->nullable();
            $table->boolean('is_verified')->default(false);
            $table->boolean('is_public')->default(true);
            $table->timestamps();
            
            $table->unique(['user_id', 'booking_id']);
            $table->index(['property_id', 'is_public']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
