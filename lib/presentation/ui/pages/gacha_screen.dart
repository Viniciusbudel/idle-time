import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/domain/entities/worker.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:flame/game.dart';
import 'package:time_factory/presentation/anim/portal_game.dart';
import 'package:time_factory/core/utils/number_formatter.dart';

import 'package:time_factory/presentation/ui/atoms/void_hiring_overlay.dart';
import 'package:time_factory/presentation/ui/dialogs/worker_result_dialog.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';

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
  bool _showSummonEffect = false;
  late final PortalGame _portalGame; // Cached game instance

  @override
  void initState() {
    super.initState();
    // Initialize the game once. Use a fixed color or Theme's primary if available here.
    // Since we need Theme colors which might change (unlikely for now),
    // we can grab the NeonTheme directly as it's forced in build anyway.
    _portalGame = PortalGame(primaryColor: const NeonTheme().colors.primary);
  }

  @override
  Widget build(BuildContext context) {
    final timeShards = ref.watch(timeShardsProvider);
    // Force Neon Theme
    final theme = const NeonTheme();
    final colors = theme.colors;

    return Stack(
      children: [
        // 1. Background / Main Content
        Container(
          color:
              Colors.transparent, // Background is handled by scaffold usually
          child: Column(
            children: [
              // Spacer for Header Overlay
              const SizedBox(height: 65),

              // Main Content Area (Portal centered)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Enhanced Portal
                      _buildPortal(colors),

                      const SizedBox(height: AppSpacing.sm),

                      // Status Text
                      Text(
                        'TEMPORAL RIFT ACTIVE',
                        style: theme.typography.bodyMedium.copyWith(
                          color: colors.primary.withOpacity( 0.7),
                          letterSpacing: 3.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Summon workers from across time',
                        style: theme.typography.bodySmall.copyWith(
                          color: colors.textSecondary.withOpacity( 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Summon Buttons Row
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(child: _buildCellSummonButton(ref, theme)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildShardSummonButton(timeShards, theme)),
                  ],
                ),
              ),

              const SizedBox(height: 150), // Bottom padding
            ],
          ),
        ),

        // 2. Header Overlay (Compact)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Minimal Title - Empty to keep spacing if needed or just remove
                const SizedBox(),

                // Shard Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity( 0.5),
                    border: Border.all(
                      color: colors.primary.withOpacity( 0.3),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.diamond, color: colors.primary, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$timeShards',
                        style: theme.typography.bodyMedium.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Summon Effect Overlay
        if (_showSummonEffect)
          VoidHiringOverlay(
            rarity: _lastSummonedWorker?.rarity ?? WorkerRarity.common,
            onComplete: _onSummonAnimationComplete,
          ),
      ],
    );
  }

  Widget _buildPortal(dynamic colors) {
    return Container(
      width: 280.0, // Larger portal
      height: 280.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Subtle outer glow
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity( 0.1),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Flame Portal Game
          Positioned.fill(
            child: ClipOval(child: GameWidget(game: _portalGame)),
          ),
        ],
      ),
    );
  }

  Widget _buildCellSummonButton(WidgetRef ref, dynamic theme) {
    final gameState = ref.watch(gameStateProvider);
    final colors = theme.colors;
    final typography = theme.typography;

    final currentEraId = gameState.currentEraId;
    final hires = gameState.eraHires[currentEraId] ?? 0;

    // Unlimited hires, cost scales exponentially
    final currentEra = WorkerEra.values.firstWhere((e) => e.id == currentEraId);

    // Calculate cost using the notifier helper
    // We need to access the notifier to calculate cost without modifying state
    // But calculate method is in notifier class. We can access it via ref.read or just replicate logic for UI?
    // Better to expose cost in state or a provider.
    // For now, let's replicate logic or cast notifier.
    // Actually, good practice is to have a selector or provider for "next cost".
    // Let's use the notifier method directly if possible or replicate simple math:
    // Cost = base * 1.05^hires
    final cost = ref
        .read(gameStateProvider.notifier)
        .getNextWorkerCost(currentEra);

    final canAfford = gameState.chronoEnergy >= cost;
    final canHire = canAfford && !_isSummoning;

    return GestureDetector(
      key: TutorialKeys.summonButton,
      onTap: canHire ? () => _performCellSummon(currentEra) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: canHire
              ? colors.accent.withOpacity( 0.2)
              : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(theme.dimens.cornerRadius),
          border: Border.all(color: canHire ? colors.accent : Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              'HIRE STAFF',
              style: typography.buttonText.copyWith(
                color: canHire ? colors.accent : Colors.grey,
                fontSize: 14.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${NumberFormatter.formatCE(cost)} CE',
              style: typography.bodyMedium.copyWith(
                color: canHire ? colors.textPrimary : Colors.grey,
                fontSize: 10.0,
              ),
            ),
            Text(
              // Show just the count without max limit
              'Total Hired: $hires',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShardSummonButton(int timeShards, dynamic theme) {
    final colors = theme.colors;
    final typography = theme.typography;
    final cost = 10;
    final canSummon = timeShards >= cost && !_isSummoning;

    return GestureDetector(
      onTap: canSummon ? _performSummon : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: canSummon
              ? LinearGradient(
                  colors: [colors.primary, colors.chaosButtonStart],
                )
              : null,
          color: canSummon ? null : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(theme.dimens.cornerRadius),
          border: Border.all(
            color: canSummon ? colors.glassBorder : Colors.white10,
          ),
          boxShadow: canSummon
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity( 0.5),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                  ),
                ]
              : null,
        ),
        child: Column(
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
                size: 20,
              ),
            const SizedBox(height: 4),
            Text(
              _isSummoning ? 'SUMMONING...' : 'RIFT SUMMON',
              style: typography.buttonText.copyWith(
                color: canSummon ? colors.textPrimary : Colors.grey,
                fontSize: 12.0,
              ),
            ),
            Text(
              '$cost SHARDS',
              style: typography.bodyMedium.copyWith(
                color: canSummon ? colors.textSecondary : Colors.grey,
                fontSize: 10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performCellSummon(WorkerEra era) async {
    // Check cost again (UI should prevent, but good practice)
    final cost = ref.read(gameStateProvider.notifier).getNextWorkerCost(era);
    final gameState = ref.read(gameStateProvider);

    if (gameState.chronoEnergy < cost) return;

    setState(() => _isSummoning = true);
    HapticFeedback.mediumImpact();

    // hireWorker now returns Worker? directly
    final worker = ref.read(gameStateProvider.notifier).hireWorker(era);

    if (worker != null) {
      _triggerSummonEffect(worker);
    } else {
      setState(() => _isSummoning = false);
    }
  }

  Future<void> _performSummon() async {
    setState(() => _isSummoning = true); // Lock UI
    HapticFeedback.heavyImpact();

    // Perform logic
    final worker = ref.read(gameStateProvider.notifier).summonWorker(cost: 10);

    if (worker != null) {
      _triggerSummonEffect(worker);
    } else {
      setState(() => _isSummoning = false);
    }
  }

  // Helper to manage the sequence: Animation -> Dialog
  void _triggerSummonEffect(Worker worker) {
    setState(() {
      _lastSummonedWorker = worker;
      _showSummonEffect = true;
    });
  }

  void _onSummonAnimationComplete() {
    setState(() {
      _showSummonEffect = false;
      _isSummoning = false; // Unlock UI
    });

    _showResultDialog(_lastSummonedWorker!);
  }

  void _showResultDialog(Worker worker) {
    showDialog(
      context: context,
      builder: (context) => WorkerResultDialog(
        worker: worker,
        title: 'HIRE SUCCESSFUL!',
        buttonLabel: 'WELCOME',
      ),
    );
  }
}
