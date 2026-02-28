import 'package:flutter/material.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/core/theme/era_theme.dart';

extension WorkerEraColor on WorkerEra {
  EraTheme get theme {
    switch (this) {
      case WorkerEra.victorian:
        return EraTheme.victorian;
      case WorkerEra.roaring20s:
        return EraTheme.roaring20s;
      case WorkerEra.atomicAge:
        return EraTheme.atomicAge;
      case WorkerEra.cyberpunk80s:
        return EraTheme.cyberpunk80s;
      case WorkerEra.neoTokyo:
        return EraTheme.neoTokyo;
      case WorkerEra.postSingularity:
        return EraTheme.postSingularity;
      case WorkerEra.ancientRome:
        return EraTheme.ancientRome;
      case WorkerEra.farFuture:
        return EraTheme.farFuture;
    }
  }

  Color get color => theme.primaryColor;
}

extension WorkerRarityColor on WorkerRarity {
  Color get color {
    switch (this) {
      case WorkerRarity.common:
        return const Color(0xFF8D9CB8);
      case WorkerRarity.rare:
        return const Color(0xFF1AA3B8);
      case WorkerRarity.epic:
        return const Color(0xFF5B4BDB);
      case WorkerRarity.legendary:
        return const Color(0xFFF2A93B);
      case WorkerRarity.paradox:
        return const Color(0xFFD64545);
    }
  }
}
