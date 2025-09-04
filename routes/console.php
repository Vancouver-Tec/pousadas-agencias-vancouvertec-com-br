<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

/*
|--------------------------------------------------------------------------
| Console Routes
|--------------------------------------------------------------------------
*/

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();

// Comandos customizados
Artisan::command('app:cleanup-old-bookings', function () {
    $this->info('Limpando reservas antigas...');
    // Lógica para limpar reservas antigas
})->purpose('Limpar reservas antigas')->daily();
