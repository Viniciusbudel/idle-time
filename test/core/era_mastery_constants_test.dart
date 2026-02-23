import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/era_mastery_constants.dart';

void main() {
  group('EraMasteryConstants', () {
    test('levelFromXp is deterministic at key boundaries', () {
      final level1Cost = EraMasteryConstants.xpRequiredForLevel(1);
      final level2Cost = EraMasteryConstants.xpRequiredForLevel(2);

      expect(EraMasteryConstants.levelFromXp(0), 0);
      expect(EraMasteryConstants.levelFromXp(level1Cost - 1), 0);
      expect(EraMasteryConstants.levelFromXp(level1Cost), 1);
      expect(EraMasteryConstants.levelFromXp(level1Cost + level2Cost - 1), 1);
      expect(EraMasteryConstants.levelFromXp(level1Cost + level2Cost), 2);
    });

    test('xpRequiredForLevel grows with level', () {
      final level1Cost = EraMasteryConstants.xpRequiredForLevel(1);
      final level5Cost = EraMasteryConstants.xpRequiredForLevel(5);
      expect(level5Cost > level1Cost, isTrue);
    });
  });
}
