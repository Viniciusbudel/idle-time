import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/offline_earnings.dart';

class SaveService {
  static const String _saveKey = 'time_factory_save_v1';

  /// Initialize service
  Future<void> init() async {
    // SharedPreferences doesn't need explicit init, but we keep this for API compatibility
  }

  /// Save game state to local storage
  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert to JSON
    final jsonString = jsonEncode(state.toMap());

    // Obfuscate with Base64
    final bytes = utf8.encode(jsonString);
    final base64String = base64.encode(bytes);

    await prefs.setString(_saveKey, base64String);
  }

  /// Alias for save
  Future<void> saveGame(GameState state) => save(state);

  /// Load game state from local storage
  Future<GameState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final base64String = prefs.getString(_saveKey);

    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      final bytes = base64.decode(base64String);
      final jsonString = utf8.decode(bytes);
      final Map<String, dynamic> map = jsonDecode(jsonString);

      return GameState.fromMap(map);
    } catch (e) {
      print('Error loading game: $e');
      return null;
    }
  }

  /// Alias for load
  Future<GameState?> loadGame() => load();

  /// Calculate offline earnings based on time passed
  OfflineEarnings? calculateOfflineEarnings(GameState state) {
    if (state.lastTickTime == null) return null;

    final now = DateTime.now();
    final difference = now.difference(state.lastTickTime!);

    // Minimum 1 minute for offline earnings
    if (difference.inMinutes < 1) return null;

    // Cap at 24 hours
    final actualDuration = difference.inHours > 24
        ? const Duration(hours: 24)
        : difference;

    final productionPerSecond = state.productionPerSecond;
    final offlineEfficiency = state.offlineEfficiency;

    final totalEarned =
        productionPerSecond *
        BigInt.from(actualDuration.inSeconds) *
        BigInt.from((offlineEfficiency * 100).toInt()) ~/
        BigInt.from(100);

    return OfflineEarnings(
      ceEarned: totalEarned,
      offlineDuration: actualDuration,
      efficiency: offlineEfficiency,
    );
  }

  /// Clear saved data
  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
}
