<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\HomeController;
use App\Http\Controllers\Site\PropertyController;
use App\Http\Controllers\Site\BookingController;
use App\Http\Controllers\Site\AuthController;
use App\Http\Controllers\Client\DashboardController as ClientDashboard;
use App\Http\Controllers\Admin\DashboardController as AdminDashboard;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Rotas do Site Público
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/search', [PropertyController::class, 'search'])->name('properties.search');
Route::get('/property/{id}', [PropertyController::class, 'show'])->name('property.show');
Route::get('/booking/{property}', [BookingController::class, 'create'])->name('booking.create');

// Rotas de Autenticação
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
Route::post('/register', [AuthController::class, 'register']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Rotas do Painel Cliente (protegidas)
Route::middleware(['auth', 'client'])->prefix('client')->group(function () {
    Route::get('/dashboard', [ClientDashboard::class, 'index'])->name('client.dashboard');
    Route::get('/bookings', [ClientDashboard::class, 'bookings'])->name('client.bookings');
    Route::get('/profile', [ClientDashboard::class, 'profile'])->name('client.profile');
    Route::put('/profile', [ClientDashboard::class, 'updateProfile'])->name('client.profile.update');
});

// Rotas do Painel Admin (protegidas)
Route::middleware(['auth', 'admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboard::class, 'index'])->name('admin.dashboard');
    Route::get('/properties', [AdminDashboard::class, 'properties'])->name('admin.properties');
    Route::get('/bookings', [AdminDashboard::class, 'bookings'])->name('admin.bookings');
    Route::get('/users', [AdminDashboard::class, 'users'])->name('admin.users');
    Route::get('/settings', [AdminDashboard::class, 'settings'])->name('admin.settings');
});

// Rotas para alternar idioma
Route::get('/lang/{locale}', function ($locale) {
    if (in_array($locale, ['pt', 'en', 'es'])) {
        session(['locale' => $locale]);
    }
    return redirect()->back();
})->name('lang.switch');

// Rotas de Favoritos
Route::get('/client/favorites', [App\Http\Controllers\Client\FavoriteController::class, 'index'])->name('client.favorites.index');
Route::post('/client/favorites/toggle', [App\Http\Controllers\Client\FavoriteController::class, 'toggle'])->name('client.favorites.toggle');
Route::delete('/client/favorites/{id}', [App\Http\Controllers\Client\FavoriteController::class, 'destroy'])->name('client.favorites.destroy');

// Rotas de Perfil
Route::get('/client/profile', [App\Http\Controllers\Client\ProfileController::class, 'show'])->name('client.profile.show');
Route::get('/client/profile/edit', [App\Http\Controllers\Client\ProfileController::class, 'edit'])->name('client.profile.edit');
Route::put('/client/profile', [App\Http\Controllers\Client\ProfileController::class, 'update'])->name('client.profile.update');
Route::get('/client/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'password'])->name('client.profile.password');
Route::put('/client/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'updatePassword'])->name('client.profile.password.update');

// Rota adicional para detalhes de reserva
Route::get('/client/bookings/{id}', [App\Http\Controllers\Client\BookingController::class, 'show'])->name('client.bookings.show');
Route::delete('/client/bookings/{id}/cancel', [App\Http\Controllers\Client\BookingController::class, 'cancel'])->name('client.bookings.cancel');

// Rotas de busca
Route::get('/properties', [Site\PropertyController::class, 'index'])->name('site.properties.index');
Route::get('/properties/{id}', [Site\PropertyController::class, 'show'])->name('site.properties.show');
Route::get('/search/suggestions', [Site\PropertyController::class, 'searchSuggestions'])->name('site.search.suggestions');
