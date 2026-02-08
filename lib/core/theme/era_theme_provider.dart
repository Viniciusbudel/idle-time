import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:time_factory/core/theme/era_theme.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';

/// Manages the active visual theme of the game
/// Global provider for the current era theme
final eraThemeProvider = Provider<EraTheme>((ref) {
  final currentEraId = ref.watch(
    gameStateProvider.select((s) => s.currentEraId),
  );

  switch (currentEraId) {
    case 'victorian':
      return EraTheme.victorian;
    case 'roaring_20s':
      return EraTheme.roaring20s;
    case 'atomic_age':
      return EraTheme.atomicAge;
    case 'cyberpunk_80s':
      return EraTheme.cyberpunk80s;
    case 'neo_tokyo':
      return EraTheme.neoTokyo;
    case 'post_singularity':
      return EraTheme.postSingularity;
    case 'ancient_rome':
      return EraTheme.ancientRome;
    case 'far_future':
      return EraTheme.farFuture;
    default:
      return EraTheme.victorian;
  }
});
