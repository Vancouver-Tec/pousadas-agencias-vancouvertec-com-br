#!/bin/bash

# ===========================================
# MODELS E MIGRATIONS - Sistema Pousadas
# Vancouver-Tec - Criar estrutura completa do banco
# ===========================================

echo "🚀 Criando Models e Migrations..."

# ===========================================
# MIGRATIONS
# ===========================================

echo "🗃️ Criando Migration: users..."
cat > database/migrations/2024_01_01_000000_create_users_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', ['client', 'admin'])->default('client');
            $table->string('phone')->nullable();
            $table->string('document')->nullable();
            $table->date('birth_date')->nullable();
            $table->text('address')->nullable();
            $table->string('city')->nullable();
            $table->string('state')->nullable();
            $table->string('country')->default('Brazil');
            $table->string('zip_code')->nullable();
            $table->string('preferred_language', 2)->default('pt');
            $table->boolean('is_active')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
EOF

echo "🏠 Criando Migration: properties..."
cat > database/migrations/2024_01_02_000000_create_properties_table.php << 'EOF'
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
EOF

echo "📅 Criando Migration: bookings..."
cat > database/migrations/2024_01_03_000000_create_bookings_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('property_id')->constrained()->onDelete('cascade');
            $table->string('booking_number')->unique();
            $table->date('check_in');
            $table->date('check_out');
            $table->integer('guests');
            $table->integer('nights');
            $table->decimal('price_per_night', 10, 2);
            $table->decimal('subtotal', 10, 2);
            $table->decimal('taxes', 10, 2)->default(0);
            $table->decimal('fees', 10, 2)->default(0);
            $table->decimal('total', 10, 2);
            $table->enum('status', ['pending', 'confirmed', 'cancelled', 'completed'])->default('pending');
            $table->enum('payment_status', ['pending', 'paid', 'failed', 'refunded'])->default('pending');
            $table->string('payment_method')->nullable();
            $table->string('stripe_payment_intent_id')->nullable();
            $table->text('special_requests')->nullable();
            $table->text('cancellation_reason')->nullable();
            $table->timestamp('cancelled_at')->nullable();
            $table->timestamps();
            
            $table->index(['user_id', 'status']);
            $table->index(['property_id', 'status']);
            $table->index(['check_in', 'check_out']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bookings');
    }
};
EOF

echo "💳 Criando Migration: payments..."
cat > database/migrations/2024_01_04_000000_create_payments_table.php << 'EOF'
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
EOF

echo "⭐ Criando Migration: reviews..."
cat > database/migrations/2024_01_05_000000_create_reviews_table.php << 'EOF'
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
EOF

echo "❤️ Criando Migration: favorites..."
cat > database/migrations/2024_01_06_000000_create_favorites_table.php << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('property_id')->constrained()->onDelete('cascade');
            $table->timestamps();
            
            $table->unique(['user_id', 'property_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};
EOF

# ===========================================
# MODELS
# ===========================================

echo "🏗️ Atualizando Model User..."
cat > app/Models/User.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'phone',
        'document',
        'birth_date',
        'address',
        'city',
        'state',
        'country',
        'zip_code',
        'preferred_language',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'birth_date' => 'date',
        'password' => 'hashed',
        'is_active' => 'boolean',
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

    // Helper methods
    public function isAdmin(): bool
    {
        return $this->role === 'admin';
    }

    public function isClient(): bool
    {
        return $this->role === 'client';
    }

    public function getFullAddressAttribute(): string
    {
        return trim("{$this->address}, {$this->city}, {$this->state}, {$this->country}");
    }
}
EOF

echo "🏠 Criando Model Property..."
cat > app/Models/Property.php << 'EOF'
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
EOF

echo "📅 Criando Model Booking..."
cat > app/Models/Booking.php << 'EOF'
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
EOF

echo "💳 Criando Model Payment..."
cat > app/Models/Payment.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'stripe_payment_intent_id',
        'stripe_charge_id',
        'amount',
        'currency',
        'status',
        'payment_method',
        'stripe_response',
        'failure_reason',
        'refunded_amount',
        'paid_at',
        'refunded_at',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'refunded_amount' => 'decimal:2',
        'stripe_response' => 'array',
        'paid_at' => 'datetime',
        'refunded_at' => 'datetime',
    ];

    // Relationships
    public function booking(): BelongsTo
    {
        return $this->belongsTo(Booking::class);
    }

    // Helper methods
    public function isSuccessful(): bool
    {
        return $this->status === 'succeeded';
    }

    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    public function getFormattedAmountAttribute(): string
    {
        return 'R$ ' . number_format($this->amount, 2, ',', '.');
    }
}
EOF

echo "⭐ Criando Model Review..."
cat > app/Models/Review.php << 'EOF'
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
EOF

echo "❤️ Criando Model Favorite..."
cat > app/Models/Favorite.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Favorite extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'property_id',
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
}
EOF

echo "✅ Models e Migrations criados!"
echo ""
echo "🔄 Execute agora:"
echo "php artisan migrate"
echo ""
echo "🎯 Próximo: Sistema de autenticação completo!"