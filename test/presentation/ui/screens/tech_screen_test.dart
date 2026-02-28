import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/tech_provider.dart';
import 'package:time_factory/presentation/ui/pages/tech_screen.dart';

// Mock Notifier to avoid side effects and allow state injection
class MockGameStateNotifier extends GameStateNotifier {
  MockGameStateNotifier(GameState initialState) : super() {
    state = initialState;
  }

  @override
  Future<void> loadFromStorage() async {
    // Prevent loading from storage
  }
}

void main() {
  testWidgets('TechScreen displays NeonTechCards', (WidgetTester tester) async {
    final tech1 = TechUpgrade(
      id: 'tech_1',
      name: 'Quantum Mining',
      description: 'Increases mining by 50%',
      type: TechType.efficiency,
      baseCost: BigInt.from(100),
      eraId: 'era_1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentEraTechsProvider.overrideWithValue([tech1]),
          gameStateProvider.overrideWith(
            (ref) => MockGameStateNotifier(
              GameState.initial().copyWith(chronoEnergy: BigInt.from(200)),
            ),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TechScreen()),
        ),
      ),
    );

    // Verify Header
    expect(find.text('TECH AUGMENTATION'), findsOneWidget);
    expect(find.text('ERA MASTERY'), findsNothing);

    // Verify tech entry
    expect(find.text('QUANTUM MINING'), findsOneWidget);
    expect(find.text('Increases mining by 50%'), findsOneWidget);

    // Verify Button
    expect(find.text('UPGRADE'), findsOneWidget);

    // Check cost display (formatting might vary, using partial match)
    expect(find.textContaining('100'), findsOneWidget);
  });
}
