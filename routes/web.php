<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\HomeController;
use App\Http\Controllers\Site\PropertiesController;
use App\Http\Controllers\Site\BookingController;
use App\Http\Controllers\Client\DashboardController as ClientDashboard;
use App\Http\Controllers\Admin\DashboardController as AdminDashboard;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// Rotas do Site Público (alinhadas com layouts)
Route::get('/', [HomeController::class, 'index'])->name('site.home');
Route::get('/properties', [PropertiesController::class, 'index'])->name('site.properties.index');
Route::get('/properties/{id}', [PropertiesController::class, 'show'])->name('site.properties.show');

// API de busca e sugestões
Route::get('/api/search/suggestions', [PropertiesController::class, 'suggestions'])->name('site.search.suggestions');

// Rotas de Booking
Route::get('/booking/{property}', [BookingController::class, 'create'])->name('site.booking.create');
Route::post('/booking', [BookingController::class, 'store'])->name('site.booking.store');

// Rotas de Autenticação (Laravel padrão)
Route::middleware('guest')->group(function () {
    Route::get('/login', [App\Http\Controllers\Auth\LoginController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [App\Http\Controllers\Auth\LoginController::class, 'login']);
    Route::get('/register', [App\Http\Controllers\Auth\RegisterController::class, 'showRegistrationForm'])->name('register');
    Route::post('/register', [App\Http\Controllers\Auth\RegisterController::class, 'register']);
});

Route::post('/logout', [App\Http\Controllers\Auth\LoginController::class, 'logout'])->name('logout');

// Rotas do Painel Cliente (protegidas)
Route::middleware(['auth', 'verified'])->prefix('client')->name('client.')->group(function () {
    Route::get('/dashboard', [ClientDashboard::class, 'index'])->name('dashboard');
    Route::get('/bookings', [ClientDashboard::class, 'bookings'])->name('bookings');
    Route::get('/bookings/{id}', [App\Http\Controllers\Client\BookingController::class, 'show'])->name('bookings.show');
    Route::delete('/bookings/{id}/cancel', [App\Http\Controllers\Client\BookingController::class, 'cancel'])->name('bookings.cancel');
    
    Route::get('/favorites', [App\Http\Controllers\Client\FavoriteController::class, 'index'])->name('favorites.index');
    Route::post('/favorites/toggle', [App\Http\Controllers\Client\FavoriteController::class, 'toggle'])->name('favorites.toggle');
    Route::delete('/favorites/{id}', [App\Http\Controllers\Client\FavoriteController::class, 'destroy'])->name('favorites.destroy');
    
    Route::get('/profile', [App\Http\Controllers\Client\ProfileController::class, 'show'])->name('profile.show');
    Route::get('/profile/edit', [App\Http\Controllers\Client\ProfileController::class, 'edit'])->name('profile.edit');
    Route::put('/profile', [App\Http\Controllers\Client\ProfileController::class, 'update'])->name('profile.update');
    Route::get('/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'password'])->name('profile.password');
    Route::put('/profile/password', [App\Http\Controllers\Client\ProfileController::class, 'updatePassword'])->name('profile.password.update');
});

// Rotas do Painel Admin (protegidas)
Route::middleware(['auth', 'admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboard::class, 'index'])->name('dashboard');
    Route::get('/properties', [AdminDashboard::class, 'properties'])->name('properties');
    Route::get('/bookings', [AdminDashboard::class, 'bookings'])->name('bookings');
    Route::get('/users', [AdminDashboard::class, 'users'])->name('users');
    Route::get('/settings', [AdminDashboard::class, 'settings'])->name('settings');
});

// Rotas para alternar idioma
Route::get('/lang/{locale}', function ($locale) {
    if (in_array($locale, ['pt', 'en', 'es'])) {
        session(['locale' => $locale]);
    }
    return redirect()->back();
})->name('lang.switch');

// Rotas de busca e sugestões
Route::get('/search/suggestions', [App\Http\Controllers\Site\PropertiesController::class, 'suggestions'])->name('site.search.suggestions');
