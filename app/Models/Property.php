<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Property extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'type',
        'address',
        'city',
        'state',
        'country',
        'zip_code',
        'latitude',
        'longitude',
        'price_per_night',
        'max_guests',
        'bedrooms',
        'bathrooms',
        'amenities',
        'images',
        'rating',
        'reviews_count',
        'is_active',
        'instant_book',
        'check_in_hours',
        'check_out_hours',
        'house_rules',
        'cancellation_policy',
    ];

    protected $casts = [
        'price_per_night' => 'decimal:2',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'rating' => 'decimal:2',
        'is_active' => 'boolean',
        'instant_book' => 'boolean',
        'amenities' => 'array',
        'images' => 'array',
        'check_in_hours' => 'array',
        'check_out_hours' => 'array',
    ];

    // Relationships
    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByType($query, $type)
    {
        return $query->where('type', $type);
    }

    public function scopeByCity($query, $city)
    {
        return $query->where('city', 'like', "%{$city}%");
    }

    public function scopePriceRange($query, $min, $max)
    {
        return $query->whereBetween('price_per_night', [$min, $max]);
    }

    // Helper methods
    public function getFullAddressAttribute(): string
    {
        return "{$this->address}, {$this->city}, {$this->state}, {$this->country}";
    }

    public function getMainImageAttribute(): ?string
    {
        return $this->images[0] ?? null;
    }

    public function updateRating(): void
    {
        $avgRating = $this->reviews()->where('is_public', true)->avg('rating');
        $reviewsCount = $this->reviews()->where('is_public', true)->count();
        
        $this->update([
            'rating' => round($avgRating, 2),
            'reviews_count' => $reviewsCount,
        ]);
    }

    public function isAvailable($checkIn, $checkOut): bool
    {
        return !$this->bookings()
            ->whereIn('status', ['confirmed', 'pending'])
            ->where(function ($query) use ($checkIn, $checkOut) {
                $query->whereBetween('check_in', [$checkIn, $checkOut])
                    ->orWhereBetween('check_out', [$checkIn, $checkOut])
                    ->orWhere(function ($query) use ($checkIn, $checkOut) {
                        $query->where('check_in', '<=', $checkIn)
                            ->where('check_out', '>=', $checkOut);
                    });
            })->exists();
    }
}
