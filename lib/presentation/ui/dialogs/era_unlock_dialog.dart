import 'package:flutter/material.dart';

import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class EraUnlockDialog extends StatelessWidget {
  final EraTheme eraTheme;
  final VoidCallback onTravel;

  const EraUnlockDialog({
    super.key,
    required this.eraTheme,
    required this.onTravel,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background image
    String imagePath;
    switch (eraTheme.id) {
      case 'victorian':
        imagePath = GameAssets.eraVictorian;
        break;
      case 'roaring_20s':
        imagePath = GameAssets.eraRoaring20s;
        break;
      case 'atomic_age':
        imagePath = GameAssets.eraAtomicAge;
        break;
      case 'cyberpunk_80s':
        imagePath = GameAssets.eraCyberpunk80s;
        break;
      case 'neo_tokyo':
        imagePath = GameAssets.eraNeoTokyo;
        break;
      case 'post_singularity':
        imagePath = GameAssets.eraSingularityWhitelabel;
        break;
      case 'ancient_rome':
        imagePath = GameAssets.eraAncientRome;
        break;
      case 'far_future':
        imagePath = GameAssets.eraFarFuture;
        break;
      default:
        imagePath = GameAssets.eraNeoTokyo;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF03070C),
          border: Border.all(color: eraTheme.primaryColor),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: eraTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Image
            Stack(
              alignment: Alignment.center,
              children: [
                // Image with gradient overlay
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.3),
                        BlendMode.darken,
                      ),
                      onError:
                          (
                            _,
                            __,
                          ) {}, // Fallback handled by parent decoration usually, or just empty
                    ),
                  ),
                ),
                // Gradient fade
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF03070C)],
                      ),
                    ),
                  ),
                ),
                // Text
                Positioned(
                  bottom: AppSpacing.md,
                  child: Text(
                    'TIMELINE UNLOCKED',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      shadows: [
                        const Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text(
                    eraTheme.displayName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      color: eraTheme.primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'A new era is available for exploration. Travel now to access new technologies and resources.',
                    textAlign: TextAlign.center,
                    style: TimeFactoryTextStyles.body.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  GameActionButton(
                    onTap: () {
                      onTravel();
                      Navigator.of(context).pop();
                    },
                    label: 'TRAVEL TO ERA',
                    icon: AppHugeIcons.arrow_forward,
                    color: eraTheme.primaryColor,
                    height: 48,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'LATER',
                      style: TimeFactoryTextStyles.button.copyWith(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
