<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Site\HomeController;
use App\Http\Controllers\Site\PropertyController;
use App\Http\Controllers\Site\BookingController;
use App\Http\Controllers\Site\AuthController;
use App\Http\Controllers\Client\DashboardController as ClientDashboard;
use App\Http\Controllers\Admin\DashboardController as AdminDashboard;

// Rotas do Site Público
Route::name('site.')->group(function () {
    Route::get('/', [HomeController::class, 'index'])->name('home');
    Route::get('/properties', [PropertyController::class, 'index'])->name('properties.index');
    Route::get('/properties/{id}', [PropertyController::class, 'show'])->name('properties.show');
    Route::get('/search/suggestions', [PropertyController::class, 'suggestions'])->name('search.suggestions');
});

// Rotas de Autenticação
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
    Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
    Route::post('/register', [AuthController::class, 'register']);
    Route::get('/forgot-password', [AuthController::class, 'showForgotPassword'])->name('password.request');
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword'])->name('password.email');
    Route::get('/reset-password/{token}', [AuthController::class, 'showResetPassword'])->name('password.reset');
    Route::post('/reset-password', [AuthController::class, 'resetPassword'])->name('password.update');
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
});

// Rotas protegidas para Clientes
Route::middleware(['auth', App\Http\Middleware\CheckRole::class.':client'])->prefix('client')->name('client.')->group(function () {
    Route::get('/dashboard', [ClientDashboard::class, 'index'])->name('dashboard');
    Route::get('/bookings', [ClientDashboard::class, 'bookings'])->name('bookings');
    Route::get('/profile', [ClientDashboard::class, 'profile'])->name('profile');
    Route::put('/profile', [ClientDashboard::class, 'updateProfile'])->name('profile.update');
});

// Rotas protegidas para Administradores
Route::middleware(['auth', App\Http\Middleware\CheckRole::class.':admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboard::class, 'index'])->name('dashboard');
    Route::get('/properties', [AdminDashboard::class, 'properties'])->name('properties');
    Route::get('/bookings', [AdminDashboard::class, 'bookings'])->name('bookings');
    Route::get('/users', [AdminDashboard::class, 'users'])->name('users');
    Route::get('/settings', [AdminDashboard::class, 'settings'])->name('settings');
});
