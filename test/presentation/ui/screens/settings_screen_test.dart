import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/performance_mode_provider.dart';
import 'package:time_factory/presentation/ui/pages/settings_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen shows performance mode selector', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Performance Mode'), findsOneWidget);
    expect(find.byType(DropdownButton<PerformanceMode>), findsOneWidget);
    expect(find.text('Auto'), findsWidgets);
  });

  testWidgets('SettingsScreen updates dropdown selection', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButton<PerformanceMode>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();

    expect(find.text('Low'), findsWidgets);
  });
}
