import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/usecases/salvage_artifact_usecase.dart';

void main() {
  group('SalvageArtifactUseCase', () {
    test('returns expected dust values for each rarity', () {
      final useCase = SalvageArtifactUseCase();

      expect(useCase.getDustValueForRarity(WorkerRarity.common), 5);
      expect(useCase.getDustValueForRarity(WorkerRarity.rare), 15);
      expect(useCase.getDustValueForRarity(WorkerRarity.epic), 40);
      expect(useCase.getDustValueForRarity(WorkerRarity.legendary), 120);
      expect(useCase.getDustValueForRarity(WorkerRarity.paradox), 300);
    });

    test('execute uses artifact rarity to compute dust', () {
      final useCase = SalvageArtifactUseCase();
      final artifact = WorkerArtifact(
        id: 'art_1',
        name: 'Paradox Lens',
        rarity: WorkerRarity.paradox,
        basePowerBonus: BigInt.from(10),
        productionMultiplier: 0.2,
      );

      final dust = useCase.execute(artifact);
      expect(dust, 300);
    });
  });
}
