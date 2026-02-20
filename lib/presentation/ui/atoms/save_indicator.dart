import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Shows a subtle "SAVING..." indicator when the game saves
class SaveIndicator extends ConsumerStatefulWidget {
  const SaveIndicator({super.key});

  @override
  ConsumerState<SaveIndicator> createState() => _SaveIndicatorState();
}

class _SaveIndicatorState extends ConsumerState<SaveIndicator> {
  DateTime? _lastSaveTime;
  bool _isVisible = false;
  Timer? _hideTimer;

  @override
  Widget build(BuildContext context) {
    // Watch for save time changes
    ref.listen(gameStateProvider.select((s) => s.lastSaveTime), (prev, next) {
      if (next != null && next != _lastSaveTime) {
        _lastSaveTime = next;
        _showIndicator();
      }
    });

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity( 0.7),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 8,
              height: 8,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'SAVING...',
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 8,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIndicator() {
    if (!mounted) return;

    setState(() => _isVisible = true);

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isVisible = false);
      }
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}
