<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\SignupRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    //signup
    public function signup(SignupRequest $request)
    {
        $data = $request->validated();
        $user = User::create([
            'name' => $data['name'],
            'phone_number' => $data['phone_number'],
            'password' => bcrypt($data['password'])

        ]);

        $token = $user->createToken('chat_app')->plainTextToken;

        return response([
            'user' => $user,
            'token' => $token
        ]);
    }
    //login
    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        if (!Auth::attempt($data)) {
            return response(['message' => 'The credentials provided do not match']);
        }
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $token = $user->createToken('chat_token')->plainTextToken;

        return response(compact('user', 'token'));
    }

    //logout
    public function logout(Request $request)
    {
        $user = $request->user();
        /** @var \App\Models\User $user */

        $user->currentAccessToken()->delete();
        return response(['message' => 'Successfully logged out'], 204);
    }
}
