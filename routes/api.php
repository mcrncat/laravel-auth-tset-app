<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\AuthenticatedSessionController;

Route::options('{any}', fn () => response()->noContent())
    ->where('any', '.*');

Route::post('/register', [UserController::class, 'store']);
Route::post('/login', [AuthenticatedSessionController::class, 'store']);

// 認証必須のルートをグループ化
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [UserController::class, 'me']);
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);
});
