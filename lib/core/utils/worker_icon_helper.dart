import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/enums.dart';

/// Helper utility for resolving worker icon paths
class WorkerIconHelper {
  WorkerIconHelper._();

  /// Get the icon path for a worker based on era and rarity.
  ///
  /// Victorian icons use a lightweight PNG fallback for performance.
  /// Other eras use per-rarity icon assets, e.g. `20s-icon-rare.png`.
  static String getIconPath(WorkerEra era, WorkerRarity rarity) {
    // Performance fast-path:
    // Victorian SVGs are expensive to parse on low-end devices and when many
    // worker widgets/components are on-screen, so use a lightweight raster icon.
    final rarityStr = rarity == WorkerRarity.common ? 'commum' : rarity.id;
    final prefix = _eraPrefix(era);
    final ext = _eraExtension(era);
    return 'assets/images/icons/$prefix-icon-$rarityStr.$ext';
  }

  /// Whether this era's icons are SVG (true) or raster PNG (false).
  static bool isSvg(WorkerEra era) => _eraExtension(era) == 'svg';

  /// Returns a path normalized for Flame loaders.
  ///
  /// Flame's `Sprite.load` uses the global images prefix (`assets/images/` by
  /// default), so raster paths must be relative to that prefix (e.g.
  /// `icons/foo.png`). For `Svg.load`, paths should be relative to `assets/`.
  static String getFlameLoadPath(WorkerEra era, WorkerRarity rarity) {
    final path = getIconPath(era, rarity);
    final normalized = isSvg(era)
        ? path.replaceFirst('assets/', '')
        : path.replaceFirst('assets/images/', '');
    return normalized.startsWith('/') ? normalized.substring(1) : normalized;
  }

  /// Build the correct widget (SvgPicture or Image) for a worker icon.
  static Widget buildIcon(
    WorkerEra era,
    WorkerRarity rarity, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    ColorFilter? colorFilter,
  }) {
    final path = getIconPath(era, rarity);
    if (isSvg(era)) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
      );
    }
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      filterQuality: FilterQuality.low,
    );
  }

  static String _eraPrefix(WorkerEra era) {
    switch (era) {
      case WorkerEra.roaring20s:
        return '20s';
      case WorkerEra.atomicAge:
        return 'atomic';
      case WorkerEra.cyberpunk80s:
        return 'cyberpunk';
      case WorkerEra.postSingularity:
        return 'singularity';
      default:
        return era.id;
    }
  }

  static String _eraExtension(WorkerEra era) {
    switch (era) {
      default:
        return 'png';
    }
  }
}
