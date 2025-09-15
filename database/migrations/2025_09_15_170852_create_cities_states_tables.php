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
