import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/theme/era_theme_provider.dart';
import 'package:time_factory/presentation/ui/templates/era_background_animator.dart';

/// Renders the background based on the current EraTheme
///
/// Since we don't have generated images for every era yet, this widget
/// uses procedural generation (gradients, shapes) as fallback/placeholder
/// to set the mood correctly.
class EraBackground extends ConsumerWidget {
  final bool animate;

  const EraBackground({super.key, this.animate = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(eraThemeProvider);

    String backgroundImage;
    switch (theme.id) {
      case 'victorian':
        backgroundImage = GameAssets.eraVictorian;
        break;
      case 'roaring_20s':
        backgroundImage = GameAssets.eraRoaring20s;
        break;
      case 'atomic_age':
        backgroundImage = GameAssets.eraAtomicAge;
        break;
      case 'cyberpunk_80s':
        backgroundImage = GameAssets.eraCyberpunk80s;
        break;
      case 'neo_tokyo':
        backgroundImage = GameAssets.eraNeoTokyo;
        break;
      case 'post_singularity':
        backgroundImage = GameAssets.eraPostSingularity;
        break;
      case 'ancient_rome':
        backgroundImage = GameAssets.eraAncientRome;
        break;
      case 'far_future':
        backgroundImage = GameAssets.eraFarFuture;
        break;
      default:
        backgroundImage = GameAssets.eraNeoTokyo;
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Container(
        key: ValueKey<String>(theme.id),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
            // Fallback to color if image fails (or hasn't been generated yet)
            onError: (exception, stackTrace) {},
          ),
        ),
        child: Stack(
          children: [
            // 1. Era-specific Animations (Only if animate is true)
            if (animate)
              Positioned.fill(
                child: EraBackgroundAnimator(
                  animationType: theme.animationType,
                  primaryColor: theme.primaryColor,
                  secondaryColor: theme.secondaryColor,
                ),
              ),

            // 2. Overlay to ensure text readability (vignette/dimming)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    theme.backgroundColor.withOpacity(0.6),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),

            // 3. Scanlines or Grain (Texture Overlay)
            Opacity(
              opacity: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      theme.useScanlines
                          ? 'assets/images/effects/scanlines.png'
                          : 'assets/images/effects/noise.png',
                    ),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.cover,
                    onError: (e, s) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
