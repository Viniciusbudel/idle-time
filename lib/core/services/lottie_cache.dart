import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/game_assets.dart';

/// Singleton cache for decoded Lottie compositions.
///
/// Decodes each asset ONCE and stores the resolved [LottieComposition].
/// Call [preloadAll] at app startup so the game never stutters on first use.
class ReactorLottieCache {
  ReactorLottieCache._();

  static final Map<String, LottieComposition> _cache = {};

  /// Returns a cached composition or `null` if not yet loaded.
  static LottieComposition? get(String asset) => _cache[asset];

  /// Loads and caches a composition. Returns immediately if already cached.
  static Future<LottieComposition> load(String asset) async {
    final cached = _cache[asset];
    if (cached != null) return cached;

    LottieComposition composition;

    if (asset.endsWith('.json.gz')) {
      final bytes = await rootBundle.load(asset);
      final result = await LottieComposition.decodeGZip(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      if (result == null) {
        throw StateError('Failed to decode Lottie composition: $asset');
      }
      composition = result;
    } else {
      composition = await AssetLottie(asset).load();
    }

    _cache[asset] = composition;
    return composition;
  }

  /// Preload all known reactor assets during app startup.
  /// Call this while the loading screen is visible to avoid any stutter later.
  static Future<void> preloadAll() async {
    await Future.wait([
      load(GameAssets.lottieReactor),
      // Add future era reactors here:
      // load(GameAssets.lottieSteamPunkReactor),
    ]);
  }

  /// Clears the cache (e.g. on memory pressure).
  static void clear() => _cache.clear();
}
