import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/ui/app_icons.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/pages/expeditions_screen.dart';

class MockGameStateNotifier extends GameStateNotifier {
  MockGameStateNotifier(GameState initialState) : super() {
    state = initialState;
  }

  @override
  Future<void> loadFromStorage() async {
    // Disable storage during widget tests.
  }
}

void main() {
  Future<void> pumpExpeditionsScreen(
    WidgetTester tester, {
    required GameState state,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameStateProvider.overrideWith((ref) => MockGameStateNotifier(state)),
        ],
        child: const MaterialApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ExpeditionsScreen()),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders cyberpunk expedition identity copy and layout chip', (
    WidgetTester tester,
  ) async {
    final GameState state = GameState.initial().copyWith(
      unlockedEras: const {'victorian', 'cyberpunk_80s'},
      currentEraId: 'cyberpunk_80s',
    );

    await pumpExpeditionsScreen(tester, state: state);

    expect(find.text('Neon Ghost Run'), findsOneWidget);
    expect(
      find.text('Stolen payloads in the neon nights of 1984.'),
      findsOneWidget,
    );
    expect(find.text('CYBERPUNK 80S NEON GRID'), findsOneWidget);
  });

  testWidgets('shows Hire Now and Auto Assemble Crew when slot is expanded', (
    WidgetTester tester,
  ) async {
    final GameState state = GameState.initial().copyWith(
      workers: const {},
      stations: const {},
      unlockedEras: const {'victorian'},
      currentEraId: 'victorian',
    );

    await pumpExpeditionsScreen(tester, state: state);

    final Finder collapsedChevron = find.byWidgetPredicate(
      (Widget widget) =>
          widget is AppIcon &&
          identical(widget.icon, AppHugeIcons.chevron_right),
    );
    expect(collapsedChevron, findsOneWidget);

    final Finder expandButton = find.ancestor(
      of: collapsedChevron,
      matching: find.byType(InkWell),
    );
    await tester.tap(expandButton.first);
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.text('Auto Assemble Crew'), findsOneWidget);
    expect(find.text('Hire Now'), findsOneWidget);
  });

  testWidgets('worker picker shows deployed chamber workers as candidates', (
    WidgetTester tester,
  ) async {
    final GameState state = GameState.initial().copyWith(
      unlockedEras: const {'victorian'},
      currentEraId: 'victorian',
    );

    await pumpExpeditionsScreen(tester, state: state);

    final Finder collapsedChevron = find.byWidgetPredicate(
      (Widget widget) =>
          widget is AppIcon &&
          identical(widget.icon, AppHugeIcons.chevron_right),
    );
    if (collapsedChevron.evaluate().isNotEmpty) {
      final Finder expandButton = find.ancestor(
        of: collapsedChevron,
        matching: find.byType(InkWell),
      );
      await tester.tap(expandButton.first);
      await tester.pump(const Duration(milliseconds: 220));
    }

    final Finder addWorkerIcon = find.byWidgetPredicate(
      (Widget widget) =>
          widget is AppIcon && identical(widget.icon, AppHugeIcons.add),
    );
    final Finder addSocketButton = find.ancestor(
      of: addWorkerIcon.first,
      matching: find.byType(InkWell),
    );
    await tester.tap(addSocketButton.first);
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.textContaining('CHAMBER'), findsWidgets);
  });
}
