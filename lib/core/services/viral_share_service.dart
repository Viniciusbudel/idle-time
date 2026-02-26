import 'package:share_plus/share_plus.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/worker.dart';

class ViralShareService {
  Future<bool> shareWorkerPull({
    required Worker worker,
    required GameState gameState,
  }) async {
    final message = _buildWorkerPullMessage(
      worker: worker,
      gameState: gameState,
    );

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'Time Factory Pull: ${worker.rarity.displayName}',
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  String _buildWorkerPullMessage({
    required Worker worker,
    required GameState gameState,
  }) {
    final rarity = worker.rarity.displayName.toUpperCase();
    final era = worker.era.displayName;
    final production = worker.currentProduction;
    final unlockedEras = gameState.unlockedEras.length;
    final totalPulled = gameState.totalWorkersPulled;

    return 'Just pulled a $rarity $era worker in Time Factory: ${worker.displayName} '
        '($production CE/s). '
        'Progress: $unlockedEras eras unlocked, $totalPulled total hires. '
        'Can you beat this timeline?';
  }
}
