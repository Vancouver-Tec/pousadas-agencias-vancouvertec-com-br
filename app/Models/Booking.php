<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'property_id',
        'booking_number',
        'check_in',
        'check_out',
        'guests',
        'nights',
        'price_per_night',
        'subtotal',
        'taxes',
        'fees',
        'total',
        'status',
        'payment_status',
        'payment_method',
        'stripe_payment_intent_id',
        'special_requests',
        'cancellation_reason',
        'cancelled_at',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'price_per_night' => 'decimal:2',
        'subtotal' => 'decimal:2',
        'taxes' => 'decimal:2',
        'fees' => 'decimal:2',
        'total' => 'decimal:2',
        'cancelled_at' => 'datetime',
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

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class);
    }

    // Scopes
    public function scopeActive($query)
    {
        return $query->whereIn('status', ['confirmed', 'pending']);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    // Helper methods
    public static function generateBookingNumber(): string
    {
        return 'VT' . date('Ymd') . str_pad(rand(0, 9999), 4, '0', STR_PAD_LEFT);
    }

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($booking) {
            if (empty($booking->booking_number)) {
                $booking->booking_number = self::generateBookingNumber();
            }
        });
    }

    public function canBeCancelled(): bool
    {
        return $this->status === 'confirmed' && 
               $this->check_in->gt(now()->addHours(24));
    }

    public function canBeReviewed(): bool
    {
        return $this->status === 'completed' && 
               $this->check_out->lt(now()) && 
               !$this->review;
    }
}
