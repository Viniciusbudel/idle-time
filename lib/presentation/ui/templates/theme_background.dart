import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';

class ThemeBackground extends ConsumerWidget {
  final Widget child;
  final bool forceStatic;
  final bool reducedMotion;

  const ThemeBackground({
    super.key,
    required this.child,
    this.forceStatic = false,
    this.reducedMotion = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    Widget buildStaticBackground(String assetPath) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            isAntiAlias: false,
          ),
          Container(color: Colors.black.withOpacity(0.15)),
          child,
        ],
      );
    }

    if (!forceStatic && theme.id == 'victorian') {
      return buildStaticBackground(GameAssets.eraVictorian);
    }

    if (!forceStatic && theme.id == 'roaring_20s') {
      return buildStaticBackground(GameAssets.eraRoaring20s);
    }

    if (!forceStatic && theme.id == 'atomic_age') {
      return buildStaticBackground(GameAssets.eraAtomicAge);
    }

    if (!forceStatic && theme.id == 'cyberpunk_80s') {
      return buildStaticBackground(GameAssets.eraCyberpunk80s);
    }

    if (!forceStatic && theme.id == 'post_singularity') {
      return buildStaticBackground(GameAssets.eraSingularityWhitelabel);
    }

    // Default fallback
    return Container(child: child);
  }
}
