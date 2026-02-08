import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timer that ticks every second to update game systems
class SystemTimer {
  final Ref ref;
  Timer? _timer;

  SystemTimer(this.ref);

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Logic handled in provider
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
