import '../entities/worker.dart';
import '../entities/enums.dart';

class HireWorkerUseCase {
  Worker execute(WorkerEra era, {WorkerRarity? forceRarity}) {
    // Delegate to Factory which handles ID, stats, and now Standardized Names
    // Use weighted rarity roll unless forced
    final rarity = forceRarity ?? WorkerFactory.rollRarity();
    return WorkerFactory.create(era: era, rarity: rarity);
  }
}
