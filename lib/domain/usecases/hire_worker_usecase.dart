import '../entities/worker.dart';
import '../entities/enums.dart';

class HireWorkerUseCase {
  Worker execute(WorkerEra era) {
    // Delegate to Factory which handles ID, stats, and now Standardized Names
    return WorkerFactory.create(era: era, rarity: WorkerRarity.common);
  }
}
