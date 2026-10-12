import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tube_flow/core/background/background_work.dart';
import 'package:tube_flow/features/youtube/domain/entities/auth_state.dart';
import 'package:tube_flow/features/youtube/domain/entities/youtube_channel.dart';
import 'package:tube_flow/features/youtube/domain/repositories/youtube_auth_repository.dart';

class _Auth implements YoutubeAuthRepository {
  final _c = StreamController<AuthState>.broadcast();
  @override
  AuthState currentState = const AuthInitial();

  void emit(AuthState s) {
    currentState = s;
    _c.add(s);
  }

  @override
  Stream<AuthState> watchAuthState() => _c.stream;
  @override
  Future<void> connect() async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<String> getValidAccessToken() async => 't';
}

const _connected =
    AuthConnected(YoutubeChannel(channelId: 'c', title: 'T'));

void main() {
  test('waits for the async restore instead of reporting "not connected"', () async {
    final auth = _Auth();
    final result = awaitAuthRestored(auth);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    auth.emit(_connected);
    expect(await result, isA<AuthConnected>());
  });

  test('returns immediately when already restored', () async {
    final auth = _Auth()..currentState = _connected;
    expect(await awaitAuthRestored(auth), isA<AuthConnected>());
  });

  test('a restore that finds no account resolves to disconnected', () async {
    final auth = _Auth();
    final result = awaitAuthRestored(auth);
    auth.emit(const AuthDisconnected());
    expect(await result, isA<AuthDisconnected>());
  });

  test('gives up after the timeout', () async {
    final auth = _Auth();
    final s = await awaitAuthRestored(auth, timeout: const Duration(milliseconds: 30));
    expect(s, isA<AuthInitial>());
  });
}
