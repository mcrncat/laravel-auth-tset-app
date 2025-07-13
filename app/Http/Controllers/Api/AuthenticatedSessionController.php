<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthenticatedSessionController extends Controller
{
    /**
     * ログイン処理
     */

public function store(Request $request)
{
    $request->validate([
        'email' => ['required', 'email'],
        'password' => ['required'],
    ]);

    $user = User::where('email', $request->email)->first();

    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json([
            'message' => '認証に失敗しました',
        ], 401);
    }

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'access_token' => $token,
        'token_type' => 'Bearer',
        'user' => $user,
    ]);
}



    /**
     * ログアウト処理
     */
    public function destroy(Request $request)
{
    $user = $request->user();

    if ($user) {
        $user->currentAccessToken()->delete();
        return response()->json(['message' => 'ログアウトしました。']);
    }

    return response()->json(['message' => 'ユーザーが認証されていません。'], 401);
}

}
