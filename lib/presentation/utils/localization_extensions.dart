import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/l10n/app_localizations.dart';

extension WorkerEraLocalization on WorkerEra {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case WorkerEra.victorian:
        return l10n.victorian;
      case WorkerEra.roaring20s:
        return l10n.roaring20s;
      case WorkerEra.atomicAge:
        return l10n.atomicAge;
      case WorkerEra.cyberpunk80s:
        return l10n.cyberpunk80s;
      case WorkerEra.neoTokyo:
        return l10n.neoTokyo;
      case WorkerEra.postSingularity:
        return l10n.postSingularity;
      case WorkerEra.ancientRome:
        return l10n.ancientRome;
      case WorkerEra.farFuture:
        return l10n.farFuture;
    }
  }

  Color get color {
    switch (this) {
      case WorkerEra.victorian:
        return const Color(0xFFD4AF37);
      case WorkerEra.roaring20s:
        return const Color(0xFFFFD700);
      case WorkerEra.atomicAge:
        return const Color(0xFF00FF00);
      case WorkerEra.cyberpunk80s:
        return const Color(0xFFFF00FF);
      case WorkerEra.neoTokyo:
        return const Color(0xFF00FFFF);
      case WorkerEra.postSingularity:
        return const Color(0xFF9F70FD);
      case WorkerEra.ancientRome:
        return const Color(0xFFC04000);
      case WorkerEra.farFuture:
        return const Color(0xFFE0E0E0);
    }
  }
}

extension WorkerRarityLocalization on WorkerRarity {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case WorkerRarity.common:
        return l10n.common;
      case WorkerRarity.rare:
        return l10n.rare;
      case WorkerRarity.epic:
        return l10n.epic;
      case WorkerRarity.legendary:
        return l10n.legendary;
      case WorkerRarity.paradox:
        return l10n.paradox;
    }
  }

  Color get color {
    switch (this) {
      case WorkerRarity.common:
        return Colors.white70;
      case WorkerRarity.rare:
        return TimeFactoryColors.electricCyan;
      case WorkerRarity.epic:
        return TimeFactoryColors.hotMagenta;
      case WorkerRarity.legendary:
        return TimeFactoryColors.voltageYellow;
      case WorkerRarity.paradox:
        return TimeFactoryColors.acidGreen;
    }
  }
}

extension ResourceTypeLocalization on ResourceType {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case ResourceType.chronoEnergy:
        return l10n.chronoEnergy;
      case ResourceType.timeShards:
        return l10n.timeShards;
      case ResourceType.paradoxPoints:
        return l10n.paradoxPoints;
    }
  }
}

extension StationTypeLocalization on StationType {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case StationType.basicLoop:
        return l10n.basicLoopName;
      case StationType.dualHelix:
        return l10n.dualHelixName;
      case StationType.nuclearReactor:
        return l10n.nuclearReactorName;
      case StationType.paradoxAmplifier:
        return l10n.paradoxAmplifierName;
      case StationType.timeDistortion:
        return l10n.timeDistortionName;
      case StationType.riftGenerator:
        return l10n.riftGeneratorName;
    }
  }
}

extension PrestigeUpgradeLocalization on PrestigeUpgrade {
  String localizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PrestigeUpgrade.chronoMastery:
        return l10n.chronoMasteryName;
      case PrestigeUpgrade.riftStability:
        return l10n.riftStabilityName;
      case PrestigeUpgrade.eraInsight:
        return l10n.eraInsightName;
      case PrestigeUpgrade.offlineBonus:
        return l10n.offlineBonusName;
      case PrestigeUpgrade.timekeepersFavor:
        return l10n.timekeepersFavorName;
    }
  }

  String localizedDescription(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case PrestigeUpgrade.chronoMastery:
        return l10n.chronoMasteryDescription;
      case PrestigeUpgrade.riftStability:
        return l10n.riftStabilityDescription;
      case PrestigeUpgrade.eraInsight:
        return l10n.eraInsightDescription;
      case PrestigeUpgrade.offlineBonus:
        return l10n.offlineBonusDescription;
      case PrestigeUpgrade.timekeepersFavor:
        return l10n.timekeepersFavorDescription;
    }
  }
}
