import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/main.dart';
import 'package:time_factory/presentation/ui/screens/factory_screen.dart';

void main() {
  testWidgets('Time Factory app starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TimeFactoryApp()));

    // Verify the app launches (the factory screen should be visible)
    expect(find.byType(FactoryScreen), findsOneWidget);
  });
}
