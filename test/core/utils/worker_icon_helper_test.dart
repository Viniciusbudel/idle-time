import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  test('cyberpunk era resolves new icon prefix for all rarities', () {
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.common),
      'assets/images/workers/cyberpunk/cyberpunk-icon-commum.png',
    );
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.rare),
      'assets/images/workers/cyberpunk/cyberpunk-icon-rare.png',
    );
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.epic),
      'assets/images/workers/cyberpunk/cyberpunk-icon-epic.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.cyberpunk80s,
        WorkerRarity.legendary,
      ),
      'assets/images/workers/cyberpunk/cyberpunk-icon-legendary.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.cyberpunk80s,
        WorkerRarity.paradox,
      ),
      'assets/images/workers/cyberpunk/cyberpunk-icon-paradox.png',
    );
  });

  test('flame load path removes assets/images prefix for raster icons', () {
    final victorianPath = WorkerIconHelper.getFlameLoadPath(
      WorkerEra.victorian,
      WorkerRarity.epic,
    );
    final cyberpunkPath = WorkerIconHelper.getFlameLoadPath(
      WorkerEra.cyberpunk80s,
      WorkerRarity.rare,
    );

    expect(victorianPath, 'workers/steampunk/victorian-icon-epic.png');
    expect(cyberpunkPath, 'workers/cyberpunk/cyberpunk-icon-rare.png');
    expect(victorianPath.startsWith('/'), isFalse);
    expect(cyberpunkPath.startsWith('/'), isFalse);
  });

  test('singularity era resolves new icon prefix for all rarities', () {
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.postSingularity,
        WorkerRarity.common,
      ),
      'assets/images/workers/singularity/singularity-icon-commum.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.postSingularity,
        WorkerRarity.rare,
      ),
      'assets/images/workers/singularity/singularity-icon-rare.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.postSingularity,
        WorkerRarity.epic,
      ),
      'assets/images/workers/singularity/singularity-icon-epic.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.postSingularity,
        WorkerRarity.legendary,
      ),
      'assets/images/workers/singularity/singularity-icon-legendary.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.postSingularity,
        WorkerRarity.paradox,
      ),
      'assets/images/workers/singularity/singularity-icon-paradox.png',
    );
  });
}
