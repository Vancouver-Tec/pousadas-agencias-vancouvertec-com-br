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
