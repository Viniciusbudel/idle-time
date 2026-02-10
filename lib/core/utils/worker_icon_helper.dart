import '../../domain/entities/enums.dart';

/// Helper utility for resolving worker icon SVG paths
class WorkerIconHelper {
  WorkerIconHelper._();

  /// Get the SVG icon path for a worker based on era and rarity
  ///
  /// Returns path like: 'assets/images/icons/victorian-icon-rare.svg'
  ///
  /// Note: Handles the typo in the common worker filename ('commum' instead of 'common')
  static String getIconPath(WorkerEra era, WorkerRarity rarity) {
    // Handle the typo in the common worker SVG filename
    final rarityStr = rarity == WorkerRarity.common ? 'commum' : rarity.id;
    return 'assets/images/icons/${era.id}-icon-$rarityStr.svg';
  }
}
