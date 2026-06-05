import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_2048/main.dart';

void main() {
  testWidgets('App renders correctly and displays title', (WidgetTester tester) async {
    // Render the app inside a ProviderScope (since it uses Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: CubeGame(),
      ),
    );

    // Verify the game title is present in the header
    expect(find.text('GRAVITY 2048'), findsOneWidget);
  });
}
