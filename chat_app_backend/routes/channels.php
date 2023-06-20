<?php

use Illuminate\Support\Facades\Broadcast;

/*
|--------------------------------------------------------------------------
| Broadcast Channels
|--------------------------------------------------------------------------
|
| Here you may register all of the event broadcasting channels that your
| application supports. The given channel authorization callbacks are
| used to check if an authenticated user can listen to the channel.
|
*/

Broadcast::channel('chat', function ($user) {
    return $user;
});

Broadcast::channel('chat.{receiverId}', function ($user, $receiverId) {
    return $user->id === (int) $receiverId;
});

Broadcast::channel('chat.{receiverId}.{senderId}', function ($user, $receiverId, $senderId) {
    return $user->id === (int) $receiverId || $user->id === (int) $senderId;
});

Broadcast::channel('online', function ($user) {
    return $user;
});

Broadcast::channel('typing.{receiverId}', function ($user, $receiverId) {
    return $user->id === (int) $receiverId;
});


Broadcast::channel('App.Models.User.{id}', function ($user, $id) {
    return (int) $user->id === (int) $id;
});
