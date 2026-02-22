import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/enums.dart';

/// Helper utility for resolving worker icon paths
class WorkerIconHelper {
  WorkerIconHelper._();
  static const String _victorianFallbackIcon =
      'assets/images/workers/victorian_common_worker.png';

  /// Get the icon path for a worker based on era and rarity.
  ///
  /// Victorian icons use a lightweight PNG fallback for performance.
  /// Other eras use per-rarity icon assets, e.g. `20s-icon-rare.png`.
  static String getIconPath(WorkerEra era, WorkerRarity rarity) {
    // Performance fast-path:
    // Victorian SVGs are expensive to parse on low-end devices and when many
    // worker widgets/components are on-screen, so use a lightweight raster icon.
    // if (era == WorkerEra.victorian) {
    //   return _victorianFallbackIcon;
    // }

    final rarityStr = rarity == WorkerRarity.common ? 'commum' : rarity.id;
    final prefix = _eraPrefix(era);
    final ext = _eraExtension(era);
    return 'assets/images/icons/$prefix-icon-$rarityStr.$ext';
  }

  /// Whether this era's icons are SVG (true) or raster PNG (false).
  static bool isSvg(WorkerEra era) => _eraExtension(era) == 'svg';

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
