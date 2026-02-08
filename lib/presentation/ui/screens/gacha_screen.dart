import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Gacha Screen - Temporal Rift Summoning Interface
class GachaScreen extends ConsumerStatefulWidget {
  const GachaScreen({super.key});

  @override
  ConsumerState<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends ConsumerState<GachaScreen>
    with SingleTickerProviderStateMixin {
  Worker? _lastSummonedWorker;
  bool _isSummoning = false;
  late AnimationController _portalController;

  @override
  void initState() {
    super.initState();
    _portalController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _portalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeShards = ref.watch(timeShardsProvider);
    // Force Neon Theme
    final theme = NeonTheme();
    final colors = theme.colors;
    // final typography = theme.typography; // Not used in this scoped block but available

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          // Header
          _buildHeader(theme, timeShards),

          const SizedBox(height: AppSpacing.md),

          // Main Content Area (Portal + Results)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main Portal Area
                _buildPortal(colors),

                const SizedBox(height: AppSpacing.lg),

                // Result Area
                if (_lastSummonedWorker != null)
                  _buildResultCard(_lastSummonedWorker!, theme)
                else
                  // Placeholder to keep layout stable or strict "Ready to Summon" text
                  Text(
                    'TEMPORAL RIFT STABLE',
                    style: theme.typography.bodyMedium.copyWith(
                      color: colors.textSecondary.withValues(alpha: 0.5),
                      letterSpacing: 2.0,
                    ),
                  ),
              ],
            ),
          ),

          // Summon Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildSummonButton(timeShards, theme),
          ),

          const SizedBox(height: 160), // For CommandDock
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic theme, int timeShards) {
    final colors = theme.colors;
    final typography = theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Icon
          Icon(Icons.nights_stay, color: colors.accent, size: 20.0),
          const SizedBox(width: 12.0),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TEMPORAL',
                style: typography.titleLarge.copyWith(height: 1.0),
              ),
              Text('RIFT', style: typography.titleLarge.copyWith(height: 1.0)),
            ],
          ),

          const Spacer(),

          // Shards Counter (styled like TechScreen version/status but functional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.diamond_outlined,
                  color: colors.primary, // Using primary/magenta for Shards
                  size: 14.0,
                ),
                const SizedBox(width: 4.0),
                Text(
                  '$timeShards',
                  style: typography.bodyMedium.copyWith(
                    fontSize: 14.0,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortal(dynamic colors) {
    return AnimatedBuilder(
      animation: _portalController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _portalController.value * 2 * 3.14159,
          child: Container(
            width: 200.0,
            height: 200.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors.primary, // e.g. Magenta/Purple
                  colors.primary.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.3, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 30.0,
                  spreadRadius: 5.0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.all_inclusive,
                size: 80.0,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(Worker worker, dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;
    final rarityColor = _getRarityColor(worker.rarity, colors);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        border: Border.all(color: rarityColor, width: 2.0),
        borderRadius: BorderRadius.circular(theme.dimens.cornerRadius),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.3),
            blurRadius: 20.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rarity Icon
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rarityColor.withValues(alpha: 0.2),
              border: Border.all(color: rarityColor),
            ),
            child: Icon(Icons.person, color: rarityColor, size: 28.0),
          ),
          const SizedBox(width: 16.0),
          // Worker Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.displayName.toUpperCase(),
                  style: typography.titleLarge.copyWith(
                    color: rarityColor,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '${worker.rarity.displayName} • ${worker.era.displayName}',
                  style: typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummonButton(int timeShards, dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;
    final canSummon = timeShards >= 10 && !_isSummoning;

    return GestureDetector(
      onTap: canSummon ? _performSummon : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        decoration: BoxDecoration(
          gradient: canSummon
              ? LinearGradient(
                  colors: [
                    colors.primary, // Magenta
                    colors.chaosButtonStart, // or similar
                  ],
                )
              : null,
          color: canSummon ? null : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(theme.dimens.cornerRadius),
          border: kIsWeb
              ? null
              : Border.all(color: colors.glassBorder), // Optional border
          boxShadow: canSummon
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.5),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isSummoning)
              SizedBox(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: colors.textPrimary,
                ),
              )
            else
              Icon(
                Icons.auto_awesome,
                color: canSummon ? colors.textPrimary : Colors.grey,
              ),
            const SizedBox(width: 12),
            Text(
              _isSummoning ? 'OPENING RIFT...' : 'SUMMON (10 SHARDS)',
              style: typography.buttonText.copyWith(
                color: canSummon ? colors.textPrimary : Colors.grey,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSummon() async {
    setState(() => _isSummoning = true);

    // Brief animation delay
    await Future.delayed(const Duration(milliseconds: 800));

    final worker = ref.read(gameStateProvider.notifier).summonWorker(cost: 10);

    setState(() {
      _isSummoning = false;
      _lastSummonedWorker = worker;
    });
  }

  Color _getRarityColor(WorkerRarity rarity, dynamic colors) {
    switch (rarity) {
      case WorkerRarity.common:
        return Colors.grey;
      case WorkerRarity.rare:
        return Colors.blue;
      case WorkerRarity.epic:
        return colors.primary; // Magenta
      case WorkerRarity.legendary:
        return colors.accent; // Gold/Yellow
      case WorkerRarity.paradox:
        return colors.error; // Red/Crimson
    }
  }
}

// Helper for kIsWeb if not imported
const bool kIsWeb = identical(0, 0.0);
