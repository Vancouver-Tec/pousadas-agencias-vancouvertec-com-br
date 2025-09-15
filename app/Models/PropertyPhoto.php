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
