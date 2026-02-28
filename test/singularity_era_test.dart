import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/constants/game_constants.dart';
import 'package:time_factory/core/constants/tech_data.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/expedition.dart';
import 'package:time_factory/domain/entities/station.dart';
import 'package:time_factory/domain/entities/tech_upgrade.dart';
import 'package:time_factory/domain/entities/worker_name_registry.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';

void main() {
  group('Singularity era constants and progression', () {
    test('post-singularity keeps stable id and updated display name', () {
      expect(WorkerEra.postSingularity.id, 'post_singularity');
      expect(WorkerEra.postSingularity.displayName, 'Singularity');
    });

    test('unlock threshold and progression order are coherent', () {
      expect(
        GameConstants.getEraUnlockCost('post_singularity'),
        BigInt.from(6000000000000000),
      );
      expect(GameConstants.getNextEraId('neo_tokyo'), 'post_singularity');
    });
  });

  group('Singularity chamber (Quantum Spire)', () {
    test('station type metadata matches late-game expectations', () {
      final type = StationType.quantumSpire;
      expect(type.id, 'quantum_spire');
      expect(type.workerSlots, 4);
      expect(type.maxSlotsCap, 8);
      expect(type.era, WorkerEra.postSingularity);
    });

    test('station formulas are wired for quantum spire', () {
      const station = Station(
        id: 's_qs',
        type: StationType.quantumSpire,
        level: 3,
        gridX: 0,
        gridY: 0,
      );

      expect(station.productionBonus, closeTo(11.2, 1e-9));
      expect(station.paradoxRate, closeTo(0.018, 1e-12));
      expect(station.getUpgradeCost(), BigInt.from(175616000));
      expect(
        StationFactory.getPurchaseCost(StationType.quantumSpire, 0),
        BigInt.from(8000000),
      );
      expect(
        StationFactory.getPurchaseCost(StationType.quantumSpire, 1),
        BigInt.from(14400000),
      );
    });
  });

  group('Singularity worker names and icons', () {
    test('worker names are mapped for all singularity rarities', () {
      expect(
        WorkerNameRegistry.getName(
          WorkerEra.postSingularity,
          WorkerRarity.common,
        ),
        'Neural Drifter',
      );
      expect(
        WorkerNameRegistry.getName(
          WorkerEra.postSingularity,
          WorkerRarity.rare,
        ),
        'Synapse Mechanic',
      );
      expect(
        WorkerNameRegistry.getName(
          WorkerEra.postSingularity,
          WorkerRarity.epic,
        ),
        'Cortex Strategist',
      );
      expect(
        WorkerNameRegistry.getName(
          WorkerEra.postSingularity,
          WorkerRarity.legendary,
        ),
        'Post-Human Architect',
      );
      expect(
        WorkerNameRegistry.getName(
          WorkerEra.postSingularity,
          WorkerRarity.paradox,
        ),
        'Event Horizon Mind',
      );
    });

    test('icon helper resolves singularity prefix and flame path', () {
      expect(
        WorkerIconHelper.getIconPath(
          WorkerEra.postSingularity,
          WorkerRarity.rare,
        ),
        'assets/images/icons/singularity-icon-rare.png',
      );
      expect(
        WorkerIconHelper.getFlameLoadPath(
          WorkerEra.postSingularity,
          WorkerRarity.common,
        ),
        'icons/singularity-icon-commum.png',
      );
    });
  });

  group('Singularity tech package', () {
    test('all singularity tech IDs exist in the catalog', () {
      final singularityTechs = TechData.initialTechs
          .where((tech) => tech.eraId == 'post_singularity')
          .toList();
      final ids = singularityTechs.map((tech) => tech.id).toList();

      expect(singularityTechs.length, 6);
      expect(
        ids,
        containsAll(const <String>[
          'neural_mesh',
          'probability_compiler',
          'nanoforge_cells',
          'swarm_autonomy',
          'quantum_hibernation',
          'exo_mind_uplink',
        ]),
      );
    });

    test('singularity formulas apply expected multipliers', () {
      expect(
        TechData.calculateEfficiencyMultiplier({
          'neural_mesh': 1,
          'exo_mind_uplink': 1,
        }),
        closeTo(8.4, 1e-9),
      );
      expect(
        TechData.calculateTimeWarpMultiplier({'probability_compiler': 3}),
        closeTo(1.42, 1e-9),
      );
      expect(
        TechData.calculateOfflineEfficiencyMultiplier({
          'quantum_hibernation': 4,
        }),
        closeTo(1.24, 1e-9),
      );
      expect(
        TechData.calculateAutomationLevel({'swarm_autonomy': 2}),
        closeTo(36.0, 1e-9),
      );
      expect(
        TechData.calculateCostReductionMultiplier({'nanoforge_cells': 4}),
        closeTo(0.8, 1e-9),
      );
      expect(
        TechData.calculateCostReductionMultiplier({
          'bessemer_process': 5,
          'assembly_line': 5,
          'plastic_molding': 5,
          'synth_alloys': 5,
          'nanoforge_cells': 4,
        }),
        closeTo(0.4, 1e-9),
      );
    });

    test('bonus description is correct for singularity techs', () {
      TechUpgrade tech(String id, int level) => TechData.initialTechs
          .firstWhere((upgrade) => upgrade.id == id)
          .copyWith(level: level);

      expect(tech('neural_mesh', 2).bonusDescription, 'Production: +80%');
      expect(
        tech('probability_compiler', 3).bonusDescription,
        'Game Speed: +42%',
      );
      expect(
        tech('swarm_autonomy', 2).bonusDescription,
        'Auto-Clicker: 36.0 /sec',
      );
      expect(
        tech('quantum_hibernation', 4).bonusDescription,
        'Offline Gains: +24%',
      );
      expect(tech('nanoforge_cells', 4).bonusDescription, contains('20%'));
      expect(tech('exo_mind_uplink', 1).bonusDescription, 'Unlock Next Era');
    });
  });

  group('Singularity expedition identity', () {
    test(
      'catalog keeps backward-compatible id and singularity presentation',
      () {
        final slot = ExpeditionSlot.byId('void_cloud_harvest');

        expect(slot, isNotNull);
        expect(slot!.eraId, 'post_singularity');
        expect(slot.unlockEraId, 'post_singularity');
        expect(slot.name, 'Convergence Breach');
        expect(
          slot.headline,
          'Rebuild quantum memory in a distributed consciousness zone.',
        );
        expect(slot.layoutPreset, 'singularity_whitelabel');
        expect(slot.requiredWorkers, 4);
        expect(slot.defaultRisk, ExpeditionRisk.volatile);
      },
    );
  });

  group('Singularity theming assets', () {
    test('theme and white-label background path are stable', () {
      final theme = EraTheme.fromId('post_singularity');

      expect(theme.displayName, 'SINGULARITY (2400)');
      expect(theme.animationType, EraAnimationType.digitalRain);
      expect(
        GameAssets.eraSingularityWhitelabel,
        'assets/images/backgrounds/singularity/singularity-background.png',
      );
    });
  });

  group('Singularity localization mappings', () {
    Future<String> resolveLocalizedText(
      WidgetTester tester,
      Locale locale,
      String Function(BuildContext context) resolver,
    ) async {
      String? value;

      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              value = resolver(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pump();

      return value!;
    }

    testWidgets('post-singularity era name is localized for pt/en', (
      WidgetTester tester,
    ) async {
      final ptValue = await resolveLocalizedText(
        tester,
        const Locale('pt'),
        (context) => WorkerEra.postSingularity.localizedName(context),
      );
      final enValue = await resolveLocalizedText(
        tester,
        const Locale('en'),
        (context) => WorkerEra.postSingularity.localizedName(context),
      );

      expect(ptValue, 'Singularidade');
      expect(enValue, 'Singularity');
    });

    testWidgets('quantum spire station name is localized for pt/en', (
      WidgetTester tester,
    ) async {
      final ptValue = await resolveLocalizedText(
        tester,
        const Locale('pt'),
        (context) => StationType.quantumSpire.localizedName(context),
      );
      final enValue = await resolveLocalizedText(
        tester,
        const Locale('en'),
        (context) => StationType.quantumSpire.localizedName(context),
      );

      expect(ptValue, 'Torre Quantica');
      expect(enValue, 'Quantum Spire');
    });
  });
}
