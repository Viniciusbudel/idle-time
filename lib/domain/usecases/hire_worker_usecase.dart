import '../entities/worker.dart';
import '../entities/enums.dart';

class HireWorkerUseCase {
  Worker execute(WorkerEra era) {
    // Delegate to Factory which handles ID, stats, and now Standardized Names
    // Use weighted rarity roll instead of hardcoded Common
    final rarity = WorkerFactory.rollRarity();
    return WorkerFactory.create(era: era, rarity: rarity);
  }
}
