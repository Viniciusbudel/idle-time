import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/ui/dialogs/expedition_reward_dialog.dart';

void main() {
  testWidgets('ExpeditionRewardDialog renders reward details', (
    WidgetTester tester,
  ) async {
    final reward = ExpeditionReward(
      chronoEnergy: BigInt.from(123),
      timeShards: 7,
      artifactDropChance: 0.12,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ExpeditionRewardDialog(
            slotName: 'Salvage Run',
            risk: ExpeditionRisk.risky,
            reward: reward,
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('SALVAGE RUN'), findsOneWidget);
    expect(find.text('EXPEDITION REWARD'), findsOneWidget);
    expect(find.textContaining('+123'), findsOneWidget);
    expect(find.textContaining('+7'), findsOneWidget);
    expect(find.text('AWESOME'), findsOneWidget);
  });
}
