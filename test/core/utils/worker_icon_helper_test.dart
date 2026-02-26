import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';

void main() {
  test('cyberpunk era resolves new icon prefix for all rarities', () {
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.common),
      'assets/images/icons/cyberpunk-icon-commum.png',
    );
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.rare),
      'assets/images/icons/cyberpunk-icon-rare.png',
    );
    expect(
      WorkerIconHelper.getIconPath(WorkerEra.cyberpunk80s, WorkerRarity.epic),
      'assets/images/icons/cyberpunk-icon-epic.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.cyberpunk80s,
        WorkerRarity.legendary,
      ),
      'assets/images/icons/cyberpunk-icon-legendary.png',
    );
    expect(
      WorkerIconHelper.getIconPath(
        WorkerEra.cyberpunk80s,
        WorkerRarity.paradox,
      ),
      'assets/images/icons/cyberpunk-icon-paradox.png',
    );
  });
}
