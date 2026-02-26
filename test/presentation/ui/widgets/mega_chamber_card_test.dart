import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/ui/organisms/mega_chamber_card.dart';

void main() {
  testWidgets('MegaChamberCard displays critical stats', (
    WidgetTester tester,
  ) async {
    // Setup
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final station = const Station(
      id: 'test_station',
      type: StationType.basicLoop,
      gridX: 0,
      gridY: 0,
      level: 1,
    );

    final production = BigInt.from(12345);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: MegaChamberCard(
              station: station,
              assignedWorkers: const [],
              production: production,
            ),
          ),
        ),
      ),
    );

    // Allow animations to settle
    await tester.pump(const Duration(seconds: 1));
    final l10n = AppLocalizations.of(
      tester.element(find.byType(MegaChamberCard)),
    )!;

    // Verify Output Display (Hero Stat)
    expect(find.text(l10n.currentOutput), findsOneWidget);
    expect(find.textContaining('12.3'), findsOneWidget);
    expect(find.text(l10n.perSecond), findsOneWidget);

    // Verify System Status
    expect(find.text(l10n.sysOnline), findsOneWidget);

    // Verify Stats HUD
    expect(find.text(l10n.efficiency), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);

    expect(find.text(l10n.stability), findsOneWidget);

    // Verify Worker Header with Capacity
    expect(find.text(l10n.workerProtocols), findsOneWidget);
    // Capacity text includes localized 'ONLINE' suffix
    expect(find.textContaining('0 /'), findsOneWidget);

    // Verify Upgrade Button — widget now shows 'INIT UPGRADE'
    expect(find.text(l10n.initUpgrade), findsOneWidget);
  });
}
