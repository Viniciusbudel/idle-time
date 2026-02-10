import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/domain/entities/worker_name_registry.dart';

void main() {
  group('WorkerNameRegistry', () {
    test('WorkerFactory assigns standard name for Victorian Common', () {
      final worker = WorkerFactory.create(
        era: WorkerEra.victorian,
        rarity: WorkerRarity.common,
      );
      expect(worker.name, 'Soot Sweeper');
    });

    test('WorkerFactory assigns standard name for Victorian Rare', () {
      final worker = WorkerFactory.create(
        era: WorkerEra.victorian,
        rarity: WorkerRarity.rare,
      );
      expect(worker.name, 'Steam Fitter');
    });

    test('WorkerFactory assigns standard name for NeoTokyo Legendary', () {
      final worker = WorkerFactory.create(
        era: WorkerEra.neoTokyo,
        rarity: WorkerRarity.legendary,
      );
      expect(worker.name, 'System Lord');
    });

    test('All Ers/Rarities have a name in registry', () {
      for (final era in WorkerEra.values) {
        for (final rarity in WorkerRarity.values) {
          final name = WorkerNameRegistry.getName(era, rarity);
          expect(name, isNotEmpty);
          expect(
            name,
            isNot('Temporal Worker'),
            reason: '$era $rarity missing name',
          );
        }
      }
    });
  });
}
