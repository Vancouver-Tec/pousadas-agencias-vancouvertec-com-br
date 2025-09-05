<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Admin padrão
        User::factory()->admin()->create([
            'name' => 'Vancouver-Tec Admin',
            'email' => 'admin@vancouvertec.com.br',
        ]);

        // Cliente de teste
        User::factory()->client()->create([
            'name' => 'Cliente Teste',
            'email' => 'cliente@test.com',
        ]);

        // Clientes aleatórios
        User::factory()->client()->count(25)->create();

        // Mais alguns admins
        User::factory()->count(3)->create(['role' => 'admin']);
    }
}
