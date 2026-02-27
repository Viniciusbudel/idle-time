import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_factory/core/utils/app_log.dart';

/// Minimal local event tracker for growth experiments.
class GrowthAnalyticsService {
  static const String _eventsKey = 'growth_event_counts_v1';

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?> params = const {},
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await _loadCounts(prefs);
    counts[eventName] = (counts[eventName] ?? 0) + 1;
    await prefs.setString(_eventsKey, jsonEncode(counts));

    AppLog.debug('[growth] $eventName ${jsonEncode(params)}');
  }

  Future<int> getEventCount(String eventName) async {
    final prefs = await SharedPreferences.getInstance();
    final counts = await _loadCounts(prefs);
    return counts[eventName] ?? 0;
  }

  Future<Map<String, int>> _loadCounts(SharedPreferences prefs) async {
    final raw = prefs.getString(_eventsKey);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {
      return {};
    }
  }
}
