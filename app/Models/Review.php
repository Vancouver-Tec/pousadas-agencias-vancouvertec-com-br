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
        'is_public'
    ];

    protected $casts = [
        'owner_response_at' => 'datetime',
        'is_verified' => 'boolean',
        'is_public' => 'boolean'
    ];

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
}
