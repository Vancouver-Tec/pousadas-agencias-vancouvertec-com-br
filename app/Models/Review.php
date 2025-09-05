<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'property_id',
        'booking_id',
        'rating',
        'cleanliness_rating',
        'location_rating',
        'value_rating',
        'service_rating',
        'comment',
        'owner_response',
        'owner_response_at',
        'is_verified',
        'is_public',
    ];

    protected $casts = [
        'is_verified' => 'boolean',
        'is_public' => 'boolean',
        'owner_response_at' => 'datetime',
    ];

    // Relationships
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    // Scopes
    public function scopePublic($query)
    {
        return $query->where('is_public', true);
    }

    public function scopeVerified($query)
    {
        return $query->where('is_verified', true);
    }

    // Helper methods
    public function getAverageRatingAttribute(): float
    {
        $ratings = collect([
            $this->rating,
            $this->cleanliness_rating,
            $this->location_rating,
            $this->value_rating,
            $this->service_rating,
        ])->filter()->values();

        return $ratings->isEmpty() ? 0 : $ratings->avg();
    }

    protected static function boot()
    {
        parent::boot();
        
        static::created(function ($review) {
            $review->property->updateRating();
        });
        
        static::updated(function ($review) {
            $review->property->updateRating();
        });
        
        static::deleted(function ($review) {
            $review->property->updateRating();
        });
    }
}
