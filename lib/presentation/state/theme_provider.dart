import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/theme/game_theme.dart';
import 'package:time_factory/core/theme/steampunk_theme.dart';
import 'package:time_factory/core/theme/roaring_twenties_theme.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Provider for the current active theme
final themeProvider = StateNotifierProvider<ThemeNotifier, GameTheme>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<GameTheme> {
  final Ref ref;

  ThemeNotifier(this.ref) : super(SteampunkTheme()) {
    _listenToEraChanges();
  }

  void _listenToEraChanges() {
    ref.listen(gameStateProvider.select((s) => s.currentEraId), (
      previous,
      next,
    ) {
      if (previous != next) {
        state = _getThemeForEra(next);
      }
    });
  }

  GameTheme _getThemeForEra(String eraId) {
    switch (eraId) {
      case 'victorian':
        return SteampunkTheme();
      case 'roaring_20s':
        return RoaringTwentiesTheme();
      // Future themes will be added here
      // case 'cyberpunk': return CyberpunkTheme();
      default:
        return SteampunkTheme();
    }
  }
}
