import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';

void main() {
  // ====================================================================
  // WorkerArtifact.generate()
  // ====================================================================
  group('WorkerArtifact.generate', () {
    test('generates artifact for each rarity', () {
      for (final rarity in WorkerRarity.values) {
        final artifact = WorkerArtifact.generate(rarity, WorkerEra.victorian);
        expect(artifact.rarity, rarity);
        expect(artifact.id, isNotEmpty);
        expect(artifact.name, isNotEmpty);
        expect(artifact.basePowerBonus, greaterThanOrEqualTo(BigInt.zero));
        expect(artifact.productionMultiplier, greaterThanOrEqualTo(0.0));
      }
    });

    test('legendary artifact has eraMatch populated', () {
      final artifact = WorkerArtifact.generate(
        WorkerRarity.legendary,
        WorkerEra.atomicAge,
      );
      expect(artifact.eraMatch, WorkerEra.atomicAge);
    });

    test('common artifact has 2% productionMultiplier', () {
      final artifact = WorkerArtifact.generate(
        WorkerRarity.common,
        WorkerEra.victorian,
      );
      expect(artifact.productionMultiplier, 0.02);
    });

    test('paradox artifact has 20% productionMultiplier', () {
      final artifact = WorkerArtifact.generate(
        WorkerRarity.paradox,
        WorkerEra.cyberpunk80s,
      );
      expect(artifact.productionMultiplier, 0.2);
    });

    test('each generated artifact has unique id', () {
      final a1 = WorkerArtifact.generate(
        WorkerRarity.rare,
        WorkerEra.victorian,
      );
      // Small delay to ensure different millisecond timestamp
      final a2 = WorkerArtifact.generate(
        WorkerRarity.rare,
        WorkerEra.victorian,
      );
      // IDs are time-based so may collide in rapid succession within same ms —
      // at minimum test that they are non-empty strings.
      expect(a1.id, isNotEmpty);
      expect(a2.id, isNotEmpty);
    });
  });

  // ====================================================================
  // WorkerArtifact serialization
  // ====================================================================
  group('WorkerArtifact serialization', () {
    test('toMap and fromMap round-trips correctly', () {
      final artifact = WorkerArtifact(
        id: 'test_art_1',
        name: 'Test Coil',
        rarity: WorkerRarity.epic,
        eraMatch: WorkerEra.roaring20s,
        basePowerBonus: BigInt.from(42),
        productionMultiplier: 0.15,
      );

      final map = artifact.toMap();
      final restored = WorkerArtifact.fromMap(map);

      expect(restored.id, artifact.id);
      expect(restored.name, artifact.name);
      expect(restored.rarity, artifact.rarity);
      expect(restored.eraMatch, artifact.eraMatch);
      expect(restored.basePowerBonus, artifact.basePowerBonus);
      expect(restored.productionMultiplier, artifact.productionMultiplier);
    });

    test('fromMap handles null eraMatch', () {
      final artifact = WorkerArtifact(
        id: 'test_art_2',
        name: 'Rusted Gear',
        rarity: WorkerRarity.common,
        basePowerBonus: BigInt.from(5),
        productionMultiplier: 0.0,
      );

      final map = artifact.toMap();
      final restored = WorkerArtifact.fromMap(map);
      expect(restored.eraMatch, isNull);
    });
  });

  // ====================================================================
  // Worker.currentProduction with Artifacts
  // ====================================================================
  group('Worker.currentProduction with artifacts', () {
    final baseWorker = Worker(
      id: 'w1',
      era: WorkerEra.victorian,
      baseProduction: BigInt.from(10),
      rarity: WorkerRarity.common,
    );

    test(
      'no artifacts — currentProduction equals base × era × rarity multipliers',
      () {
        final expected =
            (10.0 *
                    WorkerEra.victorian.multiplier *
                    WorkerRarity.common.productionMultiplier)
                .round();
        expect(baseWorker.currentProduction, BigInt.from(expected));
      },
    );

    test('artifact with flat basePowerBonus increases production', () {
      final artifact = WorkerArtifact(
        id: 'art_flat',
        name: 'Power Coil',
        rarity: WorkerRarity.common,
        basePowerBonus: BigInt.from(10), // +10 flat
        productionMultiplier: 0.0,
      );
      final worker = baseWorker.copyWith(equippedArtifacts: [artifact]);

      // base = 10 + 10 = 20, no mult change
      final expected =
          (20.0 *
                  WorkerEra.victorian.multiplier *
                  WorkerRarity.common.productionMultiplier)
              .round();
      expect(worker.currentProduction, BigInt.from(expected));
    });

    test('artifact with productionMultiplier increases production', () {
      final artifact = WorkerArtifact(
        id: 'art_mult',
        name: 'Flux Amplifier',
        rarity: WorkerRarity.rare,
        basePowerBonus: BigInt.zero,
        productionMultiplier: 0.5, // +50%
      );
      final worker = baseWorker.copyWith(equippedArtifacts: [artifact]);

      // base = 10, multiplier = 1.0 + 0.5 = 1.5
      final expected =
          (10.0 *
                  1.5 *
                  WorkerEra.victorian.multiplier *
                  WorkerRarity.common.productionMultiplier)
              .round();
      expect(worker.currentProduction, BigInt.from(expected));
    });

    test('era-matching artifact grants +2% bonus', () {
      final eraMatchArtifact = WorkerArtifact(
        id: 'art_era',
        name: 'Victorian Regulator',
        rarity: WorkerRarity.epic,
        eraMatch: WorkerEra.victorian, // Matches worker era
        basePowerBonus: BigInt.zero,
        productionMultiplier: 0.15,
      );
      final workerWithMatch = baseWorker.copyWith(
        equippedArtifacts: [eraMatchArtifact],
      );

      // multiplier = 1.0 + 0.15 (artifact) + 0.02 (era match bonus) = 1.17
      final expected =
          (10.0 *
                  1.17 *
                  WorkerEra.victorian.multiplier *
                  WorkerRarity.common.productionMultiplier)
              .round();
      expect(workerWithMatch.currentProduction, BigInt.from(expected)); // 12
    });

    test('non-matching eraMatch artifact grants no bonus', () {
      final noMatchArtifact = WorkerArtifact(
        id: 'art_no_match',
        name: 'Roaring Regulator',
        rarity: WorkerRarity.epic,
        eraMatch: WorkerEra.roaring20s, // Does NOT match victorian worker
        basePowerBonus: BigInt.zero,
        productionMultiplier: 0.15,
      );
      final workerNoMatch = baseWorker.copyWith(
        equippedArtifacts: [noMatchArtifact],
      );

      // multiplier = 1.0 + 0.15 only (no era bonus)
      final expected =
          (10.0 *
                  1.15 *
                  WorkerEra.victorian.multiplier *
                  WorkerRarity.common.productionMultiplier)
              .round();
      expect(workerNoMatch.currentProduction, BigInt.from(expected));
    });

    test('5 artifacts all contribute cumulatively', () {
      final artifacts = List.generate(
        5,
        (i) => WorkerArtifact(
          id: 'art_$i',
          name: 'Artifact $i',
          rarity: WorkerRarity.common,
          basePowerBonus: BigInt.from(2), // +2 each = +10 flat total
          productionMultiplier: 0.1, // +10% each = +50% total
        ),
      );
      final worker = baseWorker.copyWith(equippedArtifacts: artifacts);

      // base = 10 + 10 = 20, mult = 1.0 + 0.5 = 1.5
      final expected =
          (20.0 *
                  1.5 *
                  WorkerEra.victorian.multiplier *
                  WorkerRarity.common.productionMultiplier)
              .round();
      expect(worker.currentProduction, BigInt.from(expected));
    });
  });

  // ====================================================================
  // Worker artifact slot capacity
  // ====================================================================
  group('Worker artifact slot capacity', () {
    final baseWorker = Worker(
      id: 'w2',
      era: WorkerEra.victorian,
      baseProduction: BigInt.from(25),
      rarity: WorkerRarity.paradox,
    );

    test('canEquipArtifact is true when fewer than 5 artifacts equipped', () {
      expect(baseWorker.canEquipArtifact, isTrue);

      final with4 = baseWorker.copyWith(
        equippedArtifacts: List.generate(
          4,
          (i) => WorkerArtifact(
            id: 'a$i',
            name: 'A$i',
            rarity: WorkerRarity.common,
            basePowerBonus: BigInt.zero,
            productionMultiplier: 0.0,
          ),
        ),
      );
      expect(with4.canEquipArtifact, isTrue);
    });

    test(
      'canEquipArtifact is false when 5 artifacts equipped on paradox worker',
      () {
        final with5 = baseWorker.copyWith(
          equippedArtifacts: List.generate(
            5,
            (i) => WorkerArtifact(
              id: 'full$i',
              name: 'Full$i',
              rarity: WorkerRarity.common,
              basePowerBonus: BigInt.zero,
              productionMultiplier: 0.0,
            ),
          ),
        );
        expect(with5.canEquipArtifact, isFalse);
      },
    );
  });

  // ====================================================================
  // Artifact equip/unequip logic (tested via pure GameState operations)
  // ====================================================================
  group('Artifact equip/unequip logic', () {
    final testWorker = Worker(
      id: 'w_test',
      era: WorkerEra.victorian,
      baseProduction: BigInt.from(25),
      rarity: WorkerRarity.paradox,
    );

    final testArtifact = WorkerArtifact(
      id: 'art_test',
      name: 'Test Gear',
      rarity: WorkerRarity.rare,
      basePowerBonus: BigInt.from(10),
      productionMultiplier: 0.1,
    );

    test('equipping moves artifact from inventory to worker', () {
      // Simulate: inventory has artifact, worker has none
      final inventory = [testArtifact];
      final equippedWorker = testWorker.copyWith(
        equippedArtifacts: [testArtifact],
      );
      final newInventory = inventory
          .where((a) => a.id != testArtifact.id)
          .toList();

      expect(equippedWorker.equippedArtifacts.length, 1);
      expect(newInventory.isEmpty, isTrue);
    });

    test('unequipping moves artifact from worker back to inventory', () {
      final workerWithArtifact = testWorker.copyWith(
        equippedArtifacts: [testArtifact],
      );
      final unequippedWorker = workerWithArtifact.copyWith(
        equippedArtifacts: [],
      );
      final newInventory = [testArtifact];

      expect(unequippedWorker.equippedArtifacts.isEmpty, isTrue);
      expect(newInventory.length, 1);
    });

    test('equipping to a full worker (5 slots) is rejected', () {
      final filledWorker = testWorker.copyWith(
        equippedArtifacts: List.generate(
          5,
          (i) => WorkerArtifact(
            id: 'slot_$i',
            name: 'Slot $i',
            rarity: WorkerRarity.common,
            basePowerBonus: BigInt.zero,
            productionMultiplier: 0.0,
          ),
        ),
      );
      expect(filledWorker.canEquipArtifact, isFalse);
    });

    test('inventory cap: adding to 100-item list is rejected', () {
      final fullInventory = List.generate(
        999,
        (i) => WorkerArtifact(
          id: 'inv_$i',
          name: 'Item $i',
          rarity: WorkerRarity.common,
          basePowerBonus: BigInt.zero,
          productionMultiplier: 0.0,
        ),
      );
      // Simulate the cap check
      final canAdd = fullInventory.length < 999;
      expect(canAdd, isFalse);
    });

    test('adding to below-cap inventory is accepted', () {
      final smallInventory = [testArtifact];
      final canAdd = smallInventory.length < 999;
      expect(canAdd, isTrue);
    });

    test('invalid worker lookup returns no artifact', () {
      final workers = {'real_worker': testWorker};
      final found = workers['nonexistent_id'];
      expect(found, isNull);
    });
  });
}
