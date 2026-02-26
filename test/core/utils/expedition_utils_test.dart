import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/utils/expedition_utils.dart';
import 'package:time_factory/domain/entities/expedition.dart';

void main() {
  test('expeditionRiskColor maps safe to cyan', () {
    expect(
      expeditionRiskColor(ExpeditionRisk.safe),
      TimeFactoryColors.electricCyan,
    );
  });

  test('expeditionRiskColor maps risky to yellow', () {
    expect(
      expeditionRiskColor(ExpeditionRisk.risky),
      TimeFactoryColors.voltageYellow,
    );
  });

  test('expeditionRiskColor maps volatile to magenta', () {
    expect(
      expeditionRiskColor(ExpeditionRisk.volatile),
      TimeFactoryColors.hotMagenta,
    );
  });
}
