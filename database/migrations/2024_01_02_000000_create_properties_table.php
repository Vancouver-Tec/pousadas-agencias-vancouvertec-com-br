<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description');
            $table->enum('type', ['hotel', 'pousada', 'resort', 'apartment', 'house']);
            $table->text('address');
            $table->string('city');
            $table->string('state');
            $table->string('country');
            $table->string('zip_code');
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->decimal('price_per_night', 10, 2);
            $table->integer('max_guests')->default(2);
            $table->integer('bedrooms')->default(1);
            $table->integer('bathrooms')->default(1);
            $table->json('amenities')->nullable(); // WiFi, Pool, Parking, etc.
            $table->json('images')->nullable(); // Array de URLs das imagens
            $table->decimal('rating', 3, 2)->default(0);
            $table->integer('reviews_count')->default(0);
            $table->boolean('is_active')->default(true);
            $table->boolean('instant_book')->default(false);
            $table->json('check_in_hours')->nullable(); // {"from": "14:00", "to": "22:00"}
            $table->json('check_out_hours')->nullable(); // {"from": "08:00", "to": "12:00"}
            $table->text('house_rules')->nullable();
            $table->text('cancellation_policy')->nullable();
            $table->timestamps();
            
            $table->index(['city', 'is_active']);
            $table->index(['type', 'is_active']);
            $table->index('price_per_night');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
