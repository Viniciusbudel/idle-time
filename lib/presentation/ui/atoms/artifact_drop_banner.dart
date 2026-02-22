import 'package:flutter/material.dart';
import 'package:time_factory/presentation/utils/localization_extensions.dart';
import 'package:time_factory/core/constants/spacing.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/domain/entities/worker_artifact.dart';
import 'package:time_factory/domain/entities/enums.dart';

class ArtifactDropBanner extends StatefulWidget {
  final WorkerArtifact artifact;
  final VoidCallback onDismissed;

  const ArtifactDropBanner({
    super.key,
    required this.artifact,
    required this.onDismissed,
  });

  static void show(BuildContext context, WorkerArtifact artifact) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: ArtifactDropBanner(
            artifact: artifact,
            onDismissed: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  State<ArtifactDropBanner> createState() => _ArtifactDropBannerState();
}

class _ArtifactDropBannerState extends State<ArtifactDropBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = widget.artifact.rarity.color;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1520),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rarityColor.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: rarityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: rarityColor.withOpacity(0.5)),
                ),
                child: Center(
                  child: Icon(
                    _rarityIcon(widget.artifact.rarity),
                    color: rarityColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TEMPORAL ARTIFACT DROPPED!',
                      style: TimeFactoryTextStyles.bodyMono.copyWith(
                        color: rarityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.artifact.name,
                      style: TimeFactoryTextStyles.header.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _rarityIcon(WorkerRarity rarity) {
    switch (rarity) {
      case WorkerRarity.common:
        return Icons.settings;
      case WorkerRarity.rare:
        return Icons.electric_bolt;
      case WorkerRarity.epic:
        return Icons.auto_fix_high;
      case WorkerRarity.legendary:
        return Icons.diamond_outlined;
      case WorkerRarity.paradox:
        return Icons.blur_circular;
    }
  }
}
