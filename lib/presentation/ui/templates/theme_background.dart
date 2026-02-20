import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/templates/steampunk_background.dart';

class ThemeBackground extends ConsumerWidget {
  final Widget child;
  final bool forceStatic;

  const ThemeBackground({
    super.key,
    required this.child,
    this.forceStatic = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    // If we have specific animated backgrounds, switch here
    if (!forceStatic && theme.id == 'victorian') {
      return SteampunkBackground(child: child);
    }

    if (!forceStatic && theme.id == 'roaring_20s') {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/roarings-20s-bg.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            isAntiAlias: false,
          ),
          Container(color: Colors.black.withValues(alpha: 0.15)),
          child,
        ],
      );
    }

    if (!forceStatic && theme.id == 'atomic_age') {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/atomic/atomic-age-background.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
            isAntiAlias: false,
          ),
          Container(color: Colors.black.withValues(alpha: 0.15)),
          child,
        ],
      );
    }

    // Default fallback
    return Container(child: child);
  }
}
