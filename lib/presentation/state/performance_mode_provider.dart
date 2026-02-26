import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PerformanceMode { auto, high, low }

extension PerformanceModeLabel on PerformanceMode {
  String get label {
    return switch (this) {
      PerformanceMode.auto => 'Auto',
      PerformanceMode.high => 'High',
      PerformanceMode.low => 'Low',
    };
  }
}

final performanceModeProvider =
    StateNotifierProvider<PerformanceModeNotifier, PerformanceMode>((ref) {
      return PerformanceModeNotifier();
    });

class PerformanceModeNotifier extends StateNotifier<PerformanceMode> {
  static const _prefsKey = 'performance_mode';

  PerformanceModeNotifier() : super(PerformanceMode.auto) {
    _load();
  }

  Future<void> setMode(PerformanceMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefsKey);
    if (value == null || value.isEmpty) return;

    final loaded = PerformanceMode.values.where((m) => m.name == value);
    if (loaded.isEmpty) return;
    state = loaded.first;
  }
}

