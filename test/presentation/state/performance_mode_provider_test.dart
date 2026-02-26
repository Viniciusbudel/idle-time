import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_factory/presentation/state/performance_mode_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('defaults to auto when no preference is saved', () async {
    final notifier = PerformanceModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(notifier.state, PerformanceMode.auto);
  });

  test('loads saved mode from preferences', () async {
    SharedPreferences.setMockInitialValues({'performance_mode': 'high'});
    final notifier = PerformanceModeNotifier();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(notifier.state, PerformanceMode.high);
  });

  test('setMode updates state and persists value', () async {
    final notifier = PerformanceModeNotifier();
    await notifier.setMode(PerformanceMode.low);
    final prefs = await SharedPreferences.getInstance();

    expect(notifier.state, PerformanceMode.low);
    expect(prefs.getString('performance_mode'), 'low');
  });

  test('labels are stable', () {
    expect(PerformanceMode.auto.label, 'Auto');
    expect(PerformanceMode.high.label, 'High');
    expect(PerformanceMode.low.label, 'Low');
  });
}
