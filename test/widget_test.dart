import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tube_flow/features/youtube/domain/entities/auth_state.dart';
import 'package:tube_flow/features/youtube/domain/repositories/youtube_auth_repository.dart';
import 'package:tube_flow/features/youtube/presentation/providers/youtube_auth_providers.dart';
import 'package:tube_flow/main.dart';

/// Avoids touching real platform channels (secure storage, Drift/sqlite) in
/// a widget test by faking the one seam every YouTube feature depends on.
class _FakeYoutubeAuthRepository implements YoutubeAuthRepository {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  AuthState currentState = const AuthDisconnected();

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<String> getValidAccessToken() async => 'fake-token';

  @override
  Stream<AuthState> watchAuthState() => _controller.stream;
}

void main() {
  testWidgets('shows the disconnected YouTube connect screen on first launch',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youtubeAuthRepositoryProvider.overrideWithValue(_FakeYoutubeAuthRepository()),
        ],
        child: const TubeFlowApp(),
      ),
    );
    await tester.pump();

    expect(find.text('TubeFlow'), findsOneWidget);
    expect(find.text('Connect YouTube Account'), findsOneWidget);
  });
}
