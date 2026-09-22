import 'youtube_channel.dart';

/// Sealed union describing the current state of the YouTube connection.
sealed class AuthState {
  const AuthState();
}

/// Nothing has loaded yet (app just started, cache not read).
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// An operation (initial connect, or startup verification) is in flight.
class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthConnected extends AuthState {
  const AuthConnected(this.channel);

  final YoutubeChannel channel;
}

class AuthDisconnected extends AuthState {
  const AuthDisconnected();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
