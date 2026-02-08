import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/presentation/state/theme_provider.dart';
import 'package:time_factory/presentation/ui/widgets/steampunk_background.dart';

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

    // Default fallback to static image
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(theme.assets.mainBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
