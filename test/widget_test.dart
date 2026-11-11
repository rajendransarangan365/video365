import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video365/main.dart';

void main() {
  testWidgets('Video365 App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Video365App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Video365'), findsWidgets);
    expect(find.textContaining('Recent Projects'), findsOneWidget);
  });
}
