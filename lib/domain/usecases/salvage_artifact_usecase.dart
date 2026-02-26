import 'package:time_factory/core/constants/artifact_forge_balance.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';

class SalvageArtifactUseCase {
  int getDustValueForRarity(WorkerRarity rarity) {
    return ArtifactForgeBalance.salvageDustByRarity[rarity] ?? 0;
  }

  int execute(WorkerArtifact artifact) {
    return getDustValueForRarity(artifact.rarity);
  }
}
