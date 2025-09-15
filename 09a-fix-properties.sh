#!/bin/bash

# 🔧 Script 09a - Correção das Properties (Alinhamento DB)
# Vancouver-Tec Pousadas & Agências
# Corrige inconsistências entre migrations e código

echo "🔧 Iniciando correções das propriedades..."

# Criar migration para adicionar colunas faltantes
echo "📊 Criando migration de correção..."
php artisan make:migration update_properties_table_columns --table=properties

# Localizar e atualizar a migration criada
MIGRATION_FILE=$(ls -t database/migrations/*update_properties_table_columns.php | head -1)

cat > "$MIGRATION_FILE" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('properties', function (Blueprint $table) {
            // Renomear colunas existentes para padronização
            $table->renameColumn('is_active', 'active');
            
            // Adicionar colunas faltantes
            $table->boolean('featured')->default(false)->after('active');
            $table->string('property_type')->nullable()->after('type');
            $table->decimal('average_rating', 3, 2)->default(0)->after('rating');
            $table->integer('bedrooms')->default(1)->change();
            $table->integer('bathrooms')->default(1)->change();
            
            // Adicionar índices para performance
            $table->index(['active', 'featured']);
            $table->index('average_rating');
        });
    }

    public function down(): void
    {
        Schema::table('properties', function (Blueprint $table) {
            $table->renameColumn('active', 'is_active');
            $table->dropColumn(['featured', 'property_type', 'average_rating']);
            $table->dropIndex(['properties_active_featured_index']);
            $table->dropIndex(['properties_average_rating_index']);
        });
    }
};
EOF

# Criar migration para corrigir cities e states
echo "🏙️ Criando tabelas cities e states..."
php artisan make:migration create_cities_states_tables

CITIES_MIGRATION=$(ls -t database/migrations/*create_cities_states_tables.php | head -1)

cat > "$CITIES_MIGRATION" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Criar tabela states
        Schema::create('states', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('code', 2);
            $table->string('country', 2)->default('BR');
            $table->timestamps();
            
            $table->unique(['code', 'country']);
            $table->index('name');
        });

        // Criar tabela cities
        Schema::create('cities', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->foreignId('state_id')->constrained()->onDelete('cascade');
            $table->string('zip_code')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->timestamps();
            
            $table->index(['state_id', 'name']);
            $table->index('name');
        });

        // Atualizar tabela properties para usar foreign keys
        Schema::table('properties', function (Blueprint $table) {
            // Adicionar colunas temporárias para IDs
            $table->foreignId('city_id')->nullable()->after('address');
            $table->foreignId('state_id')->nullable()->after('city_id');
            
            // Manter colunas antigas temporariamente
            $table->string('city')->nullable()->change();
            $table->string('state')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('properties', function (Blueprint $table) {
            $table->dropForeign(['city_id']);
            $table->dropForeign(['state_id']);
            $table->dropColumn(['city_id', 'state_id']);
            $table->string('city')->nullable(false)->change();
            $table->string('state')->nullable(false)->change();
        });
        
        Schema::dropIfExists('cities');
        Schema::dropIfExists('states');
    }
};
EOF

# Criar tabela property_photos
echo "📸 Criando tabela property_photos..."
php artisan make:migration create_property_photos_table

PHOTOS_MIGRATION=$(ls -t database/migrations/*create_property_photos_table.php | head -1)

cat > "$PHOTOS_MIGRATION" << 'EOF'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('property_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('property_id')->constrained()->onDelete('cascade');
            $table->string('filename');
            $table->string('original_name');
            $table->string('alt_text')->nullable();
            $table->integer('sort_order')->default(0);
            $table->boolean('is_primary')->default(false);
            $table->timestamps();
            
            $table->index(['property_id', 'sort_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('property_photos');
    }
};
EOF

# Corrigir Model Property
echo "📝 Atualizando Model Property..."
cat > app/Models/Property.php << 'EOF'
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
        'name',
        'description', 
        'type',
        'property_type',
        'address',
        'city_id',
        'state_id',
        'country',
        'zip_code',
        'latitude',
        'longitude',
        'price_per_night',
        'max_guests',
        'bedrooms',
        'bathrooms',
        'amenities',
        'rating',
        'average_rating',
        'reviews_count',
        'active',
        'featured',
        'instant_book',
        'check_in_hours',
        'check_out_hours',
        'house_rules',
        'cancellation_policy'
    ];

    protected $casts = [
        'amenities' => 'array',
        'check_in_hours' => 'array', 
        'check_out_hours' => 'array',
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
    public function city(): BelongsTo
    {
        return $this->belongsTo(City::class);
    }

    public function state(): BelongsTo
    {
        return $this->belongsTo(State::class);
    }

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
                                     ->orWhereBetween('check_out', [$checkIn, $checkOut])
                                     ->orWhere(function($overlapQuery) use ($checkIn, $checkOut) {
                                         $overlapQuery->where('check_in', '<=', $checkIn)
                                                     ->where('check_out', '>=', $checkOut);
                                     });
                        });
        });
    }

    // Accessors
    public function getMainPhotoAttribute()
    {
        $photo = $this->photos()->where('is_primary', true)->first();
        return $photo ? $photo->filename : 'property-placeholder.svg';
    }

    public function getFormattedPriceAttribute()
    {
        return 'R$ ' . number_format($this->price_per_night, 2, ',', '.');
    }

    public function getRatingStarsAttribute()
    {
        $rating = $this->average_rating ?: $this->rating;
        $stars = '';
        for ($i = 1; $i <= 5; $i++) {
            $stars .= $i <= $rating ? '★' : '☆';
        }
        return $stars;
    }
}
EOF

# Criar Models City, State e PropertyPhoto
echo "🏙️ Criando Models auxiliares..."

cat > app/Models/City.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class City extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'state_id',
        'zip_code',
        'latitude',
        'longitude'
    ];

    protected $casts = [
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8'
    ];

    public function state(): BelongsTo
    {
        return $this->belongsTo(State::class);
    }

    public function properties(): HasMany
    {
        return $this->hasMany(Property::class);
    }
}
EOF

cat > app/Models/State.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class State extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'code',
        'country'
    ];

    public function cities(): HasMany
    {
        return $this->hasMany(City::class);
    }

    public function properties(): HasMany
    {
        return $this->hasMany(Property::class);
    }
}
EOF

cat > app/Models/PropertyPhoto.php << 'EOF'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PropertyPhoto extends Model
{
    use HasFactory;

    protected $fillable = [
        'property_id',
        'filename',
        'original_name',
        'alt_text',
        'sort_order',
        'is_primary'
    ];

    protected $casts = [
        'is_primary' => 'boolean',
        'sort_order' => 'integer'
    ];

    public function property(): BelongsTo
    {
        return $this->belongsTo(Property::class);
    }

    public function getUrlAttribute()
    {
        return asset('uploads/properties/' . $this->filename);
    }
}
EOF

# Criar Models restantes
echo "👤 Criando Models de Booking e Review..."

cat > app/Models/Booking.php << 'EOF'
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
EOF

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
EOF

echo "✅ Script 09a-fix-properties.sh criado com sucesso!"
echo ""
echo "🔧 Correções implementadas:"
echo "   ✅ Migration para renomear is_active → active"
echo "   ✅ Adicionada coluna featured"
echo "   ✅ Criadas tabelas cities e states"
echo "   ✅ Criada tabela property_photos"
echo "   ✅ Models atualizados com relacionamentos corretos"
echo ""
echo "💡 Para executar: chmod +x 09a-fix-properties.sh && ./09a-fix-properties.sh"
echo ""
echo "⚠️  Após executar, rode:"
echo "   php artisan migrate"
echo "   php artisan db:seed"