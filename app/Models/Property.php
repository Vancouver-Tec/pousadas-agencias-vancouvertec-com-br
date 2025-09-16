<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Property extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'description', 'type', 'property_type', 'address',
        'city', 'state', 'country', 'zip_code', 'latitude', 'longitude',
        'price_per_night', 'max_guests', 'bedrooms', 'bathrooms',
        'amenities', 'rating', 'average_rating', 'reviews_count',
        'active', 'featured', 'instant_book'
    ];

    protected $casts = [
        'amenities' => 'array',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
        'price_per_night' => 'decimal:2',
        'rating' => 'decimal:2',
        'average_rating' => 'decimal:2',
        'active' => 'boolean',
        'featured' => 'boolean',
        'instant_book' => 'boolean'
    ];

    // Relacionamentos
    public function photos(): HasMany
    {
        return $this->hasMany(PropertyPhoto::class)->orderBy('sort_order');
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class)->where('is_public', true);
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->where('active', true);
    }

    public function scopeFeatured($query)
    {
        return $query->where('featured', true);
    }

    public function scopeAvailable($query, $checkIn, $checkOut)
    {
        return $query->whereDoesntHave('bookings', function($bookingQuery) use ($checkIn, $checkOut) {
            $bookingQuery->where('status', '!=', 'cancelled')
                        ->where(function($dateQuery) use ($checkIn, $checkOut) {
                            $dateQuery->whereBetween('check_in', [$checkIn, $checkOut])
                                     ->orWhereBetween('check_out', [$checkIn, $checkOut]);
                        });
        });
    }

    // Accessors - Tratamento seguro de dados
    public function getMainPhotoAttribute()
    {
        $photo = $this->photos()->where('is_primary', true)->first();
        return $photo ? $photo->filename : 'property-placeholder.svg';
    }

    public function getFormattedPriceAttribute()
    {
        return 'R$ ' . number_format($this->price_per_night, 2, ',', '.');
    }

    public function getCityNameAttribute()
    {
        return $this->city ?? 'Cidade não informada';
    }

    public function getStateNameAttribute()
    {
        return $this->state ?? 'Estado não informado';
    }

    public function getAverageRatingFormatAttribute()
    {
        return number_format($this->average_rating ?: $this->rating ?: 0, 1);
    }
}
