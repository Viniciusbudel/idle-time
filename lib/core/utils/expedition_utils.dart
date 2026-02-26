import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/domain/entities/expedition.dart';

/// Shared utility for expedition-related UI helpers.
///
/// Eliminates duplicate `_riskColor` / `_accentColor` methods that were
/// previously copy-pasted across multiple widgets.
Color expeditionRiskColor(ExpeditionRisk risk) {
  switch (risk) {
    case ExpeditionRisk.safe:
      return TimeFactoryColors.electricCyan;
    case ExpeditionRisk.risky:
      return TimeFactoryColors.voltageYellow;
    case ExpeditionRisk.volatile:
      return TimeFactoryColors.hotMagenta;
  }
}
