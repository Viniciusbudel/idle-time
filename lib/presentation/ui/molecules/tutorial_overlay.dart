import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/constants/tutorial_keys.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/ui/molecules/glass_card.dart';

/// Tutorial overlay that highlights target widgets with a hole-punch effect.
///
/// Uses [ConsumerStatefulWidget] + [addPostFrameCallback] to read
/// GlobalKey positions AFTER layout, avoiding "RenderBox not laid out" errors.
class TutorialOverlay extends ConsumerStatefulWidget {
  final int currentTab;

  const TutorialOverlay({super.key, required this.currentTab});

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _scheduleTargetLookup();
  }

  @override
  void didUpdateWidget(covariant TutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-lookup when tab changes or widget rebuilds
    _targetRect = null;
    _scheduleTargetLookup();
  }

  void _scheduleTargetLookup() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final step = ref.read(gameStateProvider).tutorialStep;
      final key = _getTargetKey(step);
      if (key == null) {
        if (_targetRect != null) setState(() => _targetRect = null);
        return;
      }

      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) {
        // Target not ready yet, try again next frame
        _scheduleTargetLookup();
        return;
      }

      final pos = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      final newRect = Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

      if (_targetRect != newRect) {
        setState(() => _targetRect = newRect);
      }
    });
  }

  GlobalKey? _getTargetKey(int step) {
    switch (step) {
      case 1: // Hire
        return widget.currentTab == 2
            ? TutorialKeys.summonButton
            : TutorialKeys.gachaTab;
      case 2: // Assign
        return widget.currentTab == 0
            ? TutorialKeys.chamberSlot
            : TutorialKeys.chambersTab;
      case 3: // Collect
        // On Factory tab: no highlight, let user interact freely
        return widget.currentTab == 1 ? null : TutorialKeys.factoryTab;
      default:
        return null;
    }
  }

  /// Step 3 on Factory tab: dialogue only, no overlay blocking.
  bool _isDialogueOnlyStep(int step) {
    return step == 3 && widget.currentTab == 1;
  }

  @override
  Widget build(BuildContext context) {
    final tutorialStep = ref.watch(
      gameStateProvider.select((s) => s.tutorialStep),
    );

    // Tutorial complete
    if (tutorialStep >= 5) return const SizedBox.shrink();

    // Re-schedule lookup when step changes
    ref.listen(gameStateProvider.select((s) => s.tutorialStep), (_, __) {
      _targetRect = null;
      _scheduleTargetLookup();
    });

    final isDialogueOnly = _isDialogueOnlyStep(tutorialStep);

    return Stack(
      children: [
        if (!isDialogueOnly) ...[
          // 1. Background overlay with hole punch (visual only, no hit testing)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _HolePunchPainter(holeRect: _targetRect),
              ),
            ),
          ),

          // 2. Hit-test barrier: block taps everywhere EXCEPT the hole
          if (_targetRect != null)
            ..._buildTapBarriers(_targetRect!)
          else
            // Welcome/Goal step: tap anywhere to advance
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (tutorialStep == 0) {
                    ref.read(gameStateProvider.notifier).advanceTutorial();
                  } else if (tutorialStep == 4) {
                    ref.read(gameStateProvider.notifier).completeTutorial();
                  }
                },
              ),
            ),
        ],

        // 3. Neon border around the hole (decorative, ignores taps)
        if (_targetRect != null)
          Positioned(
            top: _targetRect!.top,
            left: _targetRect!.left,
            width: _targetRect!.width,
            height: _targetRect!.height,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: TimeFactoryColors.electricCyan,
                    width: 2,
                  ),
                  boxShadow: TimeFactoryColors.neonGlow(
                    TimeFactoryColors.electricCyan,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

        // 4. Dialogue Box (top for steps on correct tab, bottom otherwise)
        Positioned(
          top: (tutorialStep == 1 || tutorialStep == 2 || tutorialStep == 3)
              ? 100
              : null,
          bottom: (tutorialStep == 1 || tutorialStep == 2 || tutorialStep == 3)
              ? null
              : 120,
          left: 16,
          right: 16,
          child: IgnorePointer(child: _buildDialogue(context, tutorialStep)),
        ),
      ],
    );
  }

  /// Build 4 transparent GestureDetectors that block taps outside the hole.
  /// The hole area itself has NO barrier, so taps pass through to content below.
  List<Widget> _buildTapBarriers(Rect hole) {
    return [
      // Top barrier
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: hole.top,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}),
      ),
      // Bottom barrier
      Positioned(
        top: hole.bottom,
        left: 0,
        right: 0,
        bottom: 0,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}),
      ),
      // Left barrier
      Positioned(
        top: hole.top,
        left: 0,
        width: hole.left,
        height: hole.height,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}),
      ),
      // Right barrier
      Positioned(
        top: hole.top,
        left: hole.right,
        right: 0,
        height: hole.height,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {}),
      ),
    ];
  }

  Widget _buildDialogue(BuildContext context, int step) {
    final l10n = AppLocalizations.of(context)!;
    String title = '';
    String body = '';

    switch (step) {
      case 0:
        title = l10n.tutorialWelcomeTitle;
        body = l10n.tutorialWelcomeBody;
        break;
      case 1:
        title = l10n.tutorialHireTitle;
        body = l10n.tutorialHireBody;
        break;
      case 2:
        title = l10n.tutorialAssignTitle;
        body = l10n.tutorialAssignBody;
        break;
      case 3:
        title = l10n.tutorialProduceTitle;
        body = l10n.tutorialProduceBody;
        break;
      case 4:
        title = l10n.tutorialGoalTitle;
        body = l10n.tutorialGoalBody;
        break;
    }

    return GlassCard(
      borderColor: TimeFactoryColors.electricCyan,
      borderGlow: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TimeFactoryTextStyles.header.copyWith(
                color: TimeFactoryColors.electricCyan,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(body, style: TimeFactoryTextStyles.body),
            if (step == 0 || step == 4) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'TAP TO CONTINUE >>',
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    color: TimeFactoryColors.electricCyan.withValues(
                      alpha: 0.7,
                    ),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// CustomPainter that draws a semi-transparent overlay with a clear hole.
/// This is ONLY for visuals — hit testing is handled separately.
class _HolePunchPainter extends CustomPainter {
  final Rect? holeRect;

  _HolePunchPainter({this.holeRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity( 0.85);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (holeRect == null) {
      // No hole — solid overlay
      canvas.drawRect(fullRect, paint);
      return;
    }

    // Draw overlay with hole
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(holeRect!, const Radius.circular(4)));
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HolePunchPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect;
  }
}
