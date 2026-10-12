import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tube_flow/main.dart' as app;

/// On-device smoke test: the real app boots with real plugins (Drift/SQLite,
/// secure storage, WorkManager) and reaches a usable first screen.
/// It does not sign in (that needs a human); see docs/INTEGRATION_TESTING.md.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches and shows TubeFlow', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('TubeFlow'), findsWidgets);
  });
}
