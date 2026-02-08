import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/presentation/ui/widgets/glass_card.dart';

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
        imagePath = GameAssets.eraPostSingularity;
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
      child: GlassCard(
        borderColor: eraTheme.primaryColor,
        borderGlow: true,
        padding: EdgeInsets.zero,
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
                      top: Radius.circular(12),
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
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          TimeFactoryColors.surfaceGlass,
                        ],
                      ),
                    ),
                  ),
                ),
                // Text
                Positioned(
                  bottom: AppSpacing.md,
                  child: Text(
                    'TIMELINE UNLOCKED',
                    style: TimeFactoryTextStyles.headerSmall.copyWith(
                      color: Colors.white,
                      letterSpacing: 4,
                      shadows: [const Shadow(color: Colors.black, blurRadius: 4)],
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
                    eraTheme.displayName,
                    textAlign: TextAlign.center,
                    style: TimeFactoryTextStyles.headerLarge.copyWith(
                      color: eraTheme.primaryColor,
                      fontSize: 28,
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

                  // Travel Button
                  GestureDetector(
                    onTap: () {
                      onTravel();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: eraTheme.primaryColor.withValues(alpha: 0.2),
                        border: Border.all(color: eraTheme.primaryColor),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: eraTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'TRAVEL TO ERA',
                          style: TimeFactoryTextStyles.button.copyWith(
                            color: eraTheme.primaryColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
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
