<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasMany;

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
        'cancelled_at'
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'price_per_night' => 'decimal:2',
        'subtotal' => 'decimal:2',
        'taxes' => 'decimal:2',
        'fees' => 'decimal:2',
        'total' => 'decimal:2',
        'cancelled_at' => 'datetime'
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class);
    }
}
