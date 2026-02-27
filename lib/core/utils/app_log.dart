import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Centralized debug-only logging helper for the app.
class AppLog {
  const AppLog._();

  static void debug(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'time_factory',
  }) {
    if (!kDebugMode) return;
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
