// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Time Factory';

  @override
  String get loadingTimeline => 'Loading Timeline...';

  @override
  String get chambers => 'CHAMBERS';

  @override
  String get factory => 'FACTORY';

  @override
  String get summon => 'SUMMON';

  @override
  String get tech => 'TECH';

  @override
  String get prestige => 'PRESTIGE';

  @override
  String get currentOutput => 'CURRENT OUTPUT';

  @override
  String get perSecond => '/ SEC';

  @override
  String get sysOnline => 'SYS :: ONLINE';

  @override
  String get efficiency => 'EFF';

  @override
  String get stability => 'STABILITY';

  @override
  String get systemUpgrade => 'SYSTEM UPGRADE';

  @override
  String get initUpgrade => 'INIT UPGRADE';

  @override
  String get initializeExpansion => 'Initialize expansion protocol?';

  @override
  String get lvl => 'LVL';

  @override
  String get manageUnits => 'MANAGE UNITS';

  @override
  String get workerManagement => 'WORKER MANAGEMENT';

  @override
  String get mergeInstructions =>
      'Merge 3 workers of the same rarity to create 1 of higher rarity.';

  @override
  String get legacyUnitsDetected => 'LEGACY UNITS DETECTED';

  @override
  String get legacyUnitsDescription =>
      'Refit these workers to current era tech for significantly increased production.';

  @override
  String get refit => 'REFIT';

  @override
  String available(int count) {
    return '$count Available';
  }

  @override
  String get needMoreToMerge => 'Need 3 of same era to merge';

  @override
  String get merge => 'MERGE';

  @override
  String get mergeSuccessful => 'MERGE SUCCESSFUL!';

  @override
  String unit(String rarity) {
    return '$rarity Unit';
  }

  @override
  String get production => 'PROD';

  @override
  String get excellent => 'EXCELLENT';

  @override
  String get techAugmentation => 'TECH AUGMENTATION';

  @override
  String get systemUpgradesAvailable => 'SYSTEM UPGRADES AVAILABLE';

  @override
  String get eraLocked => 'ERA LOCKED';

  @override
  String get researchIncomplete => 'RESEARCH INCOMPLETE';

  @override
  String advanceTo(String era) {
    return 'ADVANCE TO $era';
  }

  @override
  String get cost => 'COST';

  @override
  String get common => 'Common';

  @override
  String get rare => 'Rare';

  @override
  String get epic => 'Epic';

  @override
  String get legendary => 'Legendary';

  @override
  String get paradox => 'Paradox';

  @override
  String get victorian => 'Steampunk Era';

  @override
  String get roaring20s => 'Roaring 20s';

  @override
  String get atomicAge => 'Atomic Age';

  @override
  String get cyberpunk80s => 'Cyberpunk 80s';

  @override
  String get neoTokyo => 'Neo-Tokyo';

  @override
  String get postSingularity => 'Post-Singularity';

  @override
  String get ancientRome => 'Ancient Rome';

  @override
  String get farFuture => 'Far Future';

  @override
  String get chronoEnergy => 'Chrono-Energy';

  @override
  String get timeShards => 'Time Shards';

  @override
  String get paradoxPoints => 'Paradox Points';

  @override
  String get base => 'Base';

  @override
  String get techBonus => 'Tech Bonus';

  @override
  String get ceSec => 'CE/SEC';

  @override
  String get shards => 'SHARDS';

  @override
  String get mergeFailed => 'Merge failed';

  @override
  String get workerProtocols => 'WORKER PROTOCOLS';

  @override
  String get online => 'ONLINE';

  @override
  String get basicLoopName => 'Basic Loop Chamber';

  @override
  String get dualHelixName => 'Dual Helix Chamber';

  @override
  String get nuclearReactorName => 'Nuclear Fusion Reactor';

  @override
  String get paradoxAmplifierName => 'Paradox Amplifier';

  @override
  String get timeDistortionName => 'Time Distortion Field';

  @override
  String get dataNodeName => 'Data Node';

  @override
  String get synthLabName => 'Synth Lab';

  @override
  String get neonCoreName => 'Neon Core';

  @override
  String get riftGeneratorName => 'Rift Generator';

  @override
  String get chronoMasteryName => 'Chrono Mastery';

  @override
  String get chronoMasteryDescription => '+10% CE production per point';

  @override
  String get riftStabilityName => 'Rift Stability';

  @override
  String get riftStabilityDescription => '-5% paradox accumulation per point';

  @override
  String get eraInsightName => 'Era Insight';

  @override
  String get eraInsightDescription => '+1 starting era unlocked per point';

  @override
  String get offlineBonusName => 'Temporal Memory';

  @override
  String get offlineBonusDescription => '+10% offline efficiency per point';

  @override
  String get timekeepersFavorName => 'Timekeeper\'s Favor';

  @override
  String get timekeepersFavorDescription => 'Raids easier, better rewards';

  @override
  String get timelineCollapse => 'TIMELINE COLLAPSE';

  @override
  String get prestigeDescription =>
      'Reset your timeline to gain Prestige Points (PP).\nPP increases production by 10% per point.';

  @override
  String get estimatedReward => 'ESTIMATED REWARD';

  @override
  String get initiateCollapse => 'INITIATE COLLAPSE';

  @override
  String get prestigeRequirement =>
      'Require more lifetime earnings to collapse.';

  @override
  String get activeWorkforce => 'ACTIVE WORKFORCE';

  @override
  String get totalDailyYield => 'TOTAL DAILY YIELD';

  @override
  String get operationalChambers => 'OPERATIONAL CHAMBERS';

  @override
  String get systemStatus => 'SYSTEM STATUS';

  @override
  String get allSystemsOptimal => 'ALL SYSTEMS OPTIMAL';

  @override
  String get noActiveChambers => 'No active chambers detected.';

  @override
  String get deployWorkersToStart => 'Deploy workers to start production.';

  @override
  String get active => 'ACTIVE';

  @override
  String get hireNewUnit => 'HIRE NEW UNIT';

  @override
  String get noUnitsDetected => 'NO UNITS DETECTED';

  @override
  String get commandCenter => 'COMMAND CENTER';

  @override
  String get activeUnits => 'ACTIVE UNITS';

  @override
  String get eraUnlocked => 'ERA UNLOCKED';

  @override
  String get initializePrimaryChamber =>
      'Initialize the Primary Chamber to begin production.';

  @override
  String get initializeSystem => 'INITIALIZE SYSTEM';

  @override
  String get insufficientCE => 'Insufficient CE for upgrade!';

  @override
  String get factoryFloorFull => 'Factory Floor Full (Max 5 Chambers)!';

  @override
  String needCEToConstruct(Object cost) {
    return 'Need $cost CE to construct!';
  }

  @override
  String get statusLabel => 'STATUS:';

  @override
  String get optimal => 'OPTIMAL';

  @override
  String get stable => 'STABLE';

  @override
  String get critical => 'CRITICAL';

  @override
  String get idle => 'IDLE';

  @override
  String get repair => 'REPAIR';

  @override
  String get assign => 'ASSIGN';

  @override
  String get upgrade => 'UPGRADE';

  @override
  String advanceToEra(Object era) {
    return 'ADVANCE TO $era';
  }

  @override
  String get timelineMaximized => 'TIMELINE MAXIMIZED';

  @override
  String get advanceTimeline => 'ADVANCE TIMELINE';

  @override
  String get techIncomplete => 'TECH INCOMPLETE';

  @override
  String get requirement => 'REQUIREMENT';

  @override
  String get assignWorker => 'ASSIGN WORKER';

  @override
  String selectUnitFor(Object station) {
    return 'Select a unit for $station';
  }

  @override
  String get noIdleWorkers => 'NO IDLE WORKERS';

  @override
  String get hireMoreToAssign => 'Hire more units to assign';

  @override
  String get welcomeBack => 'WELCOME BACK';

  @override
  String awayFor(Object duration) {
    return 'You were away for $duration';
  }

  @override
  String get ceCollected => 'CHRONO-ENERGY COLLECTED';

  @override
  String offlineEfficiency(Object percent) {
    return '$percent% offline efficiency';
  }

  @override
  String get collect => 'COLLECT';

  @override
  String get timelineUnlocked => 'TIMELINE UNLOCKED';

  @override
  String get newEraAvailable =>
      'A new era is available for exploration. Travel now to access new technologies and resources.';

  @override
  String get travelToEra => 'TRAVEL TO ERA';

  @override
  String get later => 'LATER';

  @override
  String get recallWorker => 'RECALL WORKER';

  @override
  String get noStationsAvailable => 'NO STATIONS AVAILABLE';

  @override
  String get buildStationsToStart => 'Build stations in the Factory tab';

  @override
  String get upgradeStation => 'UPGRADE STATION';

  @override
  String get productionBonus => 'Production Bonus';

  @override
  String get cancel => 'CANCEL';

  @override
  String get confirm => 'CONFIRM';

  @override
  String nextEffect(Object label, Object percent) {
    return 'NEXT: +$percent% $label';
  }

  @override
  String get automationEffect => 'AUTO-COLLECTION';

  @override
  String get efficiencyEffect => 'CORE PRODUCTION';

  @override
  String get timeWarpEffect => 'TEMPORAL SPEED';

  @override
  String get costReductionEffect => 'UPGRADE DISCOUNT';

  @override
  String get offlineEffect => 'OFFLINE EARNINGS';

  @override
  String get clickPowerEffect => 'MANUAL POWER';

  @override
  String get eraUnlockEffect => 'ERA CLEARANCE';

  @override
  String get manhattanEffect => 'ATOMIC MULTIPLIER';

  @override
  String get statusDeployed => 'DEPLOYED';

  @override
  String get statusIdle => 'IDLE';

  @override
  String get deploy => 'DEPLOY';

  @override
  String get full => 'FULL';

  @override
  String get settings => 'SETTINGS';

  @override
  String get settingsGeneral => 'GENERAL';

  @override
  String get settingsData => 'DATA';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsResetProgress => 'Reset Progress';

  @override
  String get settingsReset => 'RESET';

  @override
  String get settingsResetConfirmTitle => 'RESET ALL DATA?';

  @override
  String get settingsResetConfirmBody =>
      'This will permanently erase all progress, workers, and resources. This action cannot be undone.';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsDeveloper => 'Developer';

  @override
  String get tutorialWelcomeTitle => 'WELCOME, CHRONO-ENGINEER';

  @override
  String get tutorialWelcomeBody =>
      'The timeline is unstable. We need to establish a production loop. Tap anywhere to initialize the protocol.';

  @override
  String get tutorialHireTitle => 'RECRUIT WORKFORCE';

  @override
  String get tutorialHireBody =>
      'Productivity is zero. You need workers from across history. Access the TIME RIFT to summon unit.';

  @override
  String get tutorialAssignTitle => 'DATA: IDLE UNIT';

  @override
  String get tutorialAssignBody =>
      'We have a worker, but they are doing nothing. Drag them to a Chamber to start generating Chrono-Energy.';

  @override
  String get tutorialProduceTitle => 'SYSTEM: ONLINE';

  @override
  String get tutorialProduceBody =>
      'Production is stable. Tap the REACTOR to manually accelerate time and collect energy.';

  @override
  String get tutorialGoalTitle => 'OBJECTIVE: COLLAPSE';

  @override
  String get tutorialGoalBody =>
      'Great work. Your goal is to reach 1 MILLION CE to trigger a PRESTIGE EVENT and collapse the timeline. Good luck.';

  @override
  String get achievements => 'ACHIEVEMENTS';

  @override
  String get ack => 'ACK';

  @override
  String get activeTitle => 'Active';

  @override
  String get all => 'ALL';

  @override
  String artifactRollChance(int percent) {
    return 'Artifact roll chance: $percent%';
  }

  @override
  String get auto => 'Auto';

  @override
  String availableMissions(int count) {
    return 'Available Missions ($count)';
  }

  @override
  String get awesome => 'AWESOME';

  @override
  String get chronoEnergyUpper => 'CHRONO ENERGY';

  @override
  String get claim => 'CLAIM';

  @override
  String get claimAll => 'CLAIM ALL';

  @override
  String claimedRewardsCount(int count) {
    return 'Claimed $count reward(s)';
  }

  @override
  String get completed => 'COMPLETED';

  @override
  String confirmSelectedWorkers(int selected, int required) {
    return 'Confirm ($selected/$required)';
  }

  @override
  String get confirmUpgrade => 'CONFIRM UPGRADE';

  @override
  String get craft => 'CRAFT';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '${minutes}m ${seconds}s';
  }

  @override
  String durationSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String expeditionCompletedTitle(String slot, String ce, int shards) {
    return '$slot | +$ce CE | +$shards TS';
  }

  @override
  String expeditionFailureLoss(int workers, int artifacts) {
    return 'Lost $workers worker(s) and $artifacts artifact(s)';
  }

  @override
  String get expeditionReward => 'EXPEDITION REWARD';

  @override
  String expeditionRiskBadge(
    String risk,
    String ceMultiplier,
    int shards,
    int artifactChance,
  ) {
    return '$risk  x$ceMultiplier  +${shards}TS  $artifactChance%';
  }

  @override
  String expeditionStarted(String slot, String risk, int workers) {
    return '$slot started ($risk) with $workers worker(s)';
  }

  @override
  String get expeditionStatus => 'EXPEDITION STATUS';

  @override
  String expeditionWorkersAssigned(
    int workers,
    String ceMultiplier,
    int shards,
    int artifactChance,
  ) {
    return '$workers worker(s) assigned | reward profile: x$ceMultiplier CE, +$shards TS, $artifactChance% artifact';
  }

  @override
  String expeditionWorkersReady(int required, int available) {
    return 'Need $required idle worker(s) | $available ready';
  }

  @override
  String expeditionWorkersReadyInsufficient(int required, int available) {
    return 'Need $required idle worker(s) | only $available ready';
  }

  @override
  String get failureReportAcknowledged => 'Failure report acknowledged';

  @override
  String get hireSuccessful => 'HIRE SUCCESSFUL!';

  @override
  String get holdPressInspectTapEquip => 'Hold-press to inspect ? Tap to equip';

  @override
  String get idleTitle => 'Idle';

  @override
  String get initiateExpedition => 'INITIATE EXPEDITION';

  @override
  String labelValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String get manage => 'MANAGE';

  @override
  String get missionControl => 'Mission Control';

  @override
  String get missions => 'MISSIONS';

  @override
  String nextCompletion(String slot, String duration) {
    return 'Next completion: $slot in $duration';
  }

  @override
  String get noActiveExpeditions => 'No active expeditions';

  @override
  String noArtifactsByFilter(String filter) {
    return 'No $filter artifacts in inventory.';
  }

  @override
  String get noChambersYet => 'No chambers yet';

  @override
  String get noRewardsWaiting => 'No rewards waiting';

  @override
  String noWorkersByRarity(String rarity) {
    return 'No $rarity workers';
  }

  @override
  String get paradoxPointsAbbrev => 'PP';

  @override
  String get readyTitle => 'Ready';

  @override
  String resourceYieldLabel(String ce) {
    return 'RESOURCE YIELD: $ce CE';
  }

  @override
  String get resourceYieldUnavailable => 'RESOURCE YIELD: --';

  @override
  String get salvage => 'SALVAGE';

  @override
  String salvagedArtifactDust(int dust) {
    return 'Salvaged artifact: +$dust Dust';
  }

  @override
  String get searchArtifacts => 'SEARCH ARTIFACTS...';

  @override
  String selectWorkers(int required) {
    return 'Select $required worker(s)';
  }

  @override
  String selectedWorkers(int selected, int required) {
    return 'Selected $selected/$required';
  }

  @override
  String get tapWorkerIconsHint =>
      'Tap worker icons above to assign or swap the crew.';

  @override
  String get timeShardsAbbrev => 'TS';

  @override
  String get timeShardsUpper => 'TIME SHARDS';

  @override
  String get unableClaimExpedition => 'Unable to claim expedition result.';

  @override
  String get unableStartExpedition =>
      'Unable to start expedition with selected workers.';

  @override
  String get unassign => 'UNASSIGN';

  @override
  String get welcome => 'WELCOME';

  @override
  String allArtifactSlotsFilled(int slots) {
    return 'ALL $slots SLOTS FILLED - Unequip an artifact first.';
  }

  @override
  String get craftFailedDustOrInventory =>
      'Craft failed (dust or inventory limit).';

  @override
  String upgradeMaxed(String title) {
    return '$title maxed';
  }

  @override
  String upgradeCostsPp(String title, int cost) {
    return '$title costs $cost PP';
  }

  @override
  String get locked => 'LOCKED';

  @override
  String prestigesCount(int count) {
    return 'Prestiges: $count';
  }

  @override
  String activeExpeditions(int count) {
    return 'Active Expeditions ($count)';
  }

  @override
  String queuedRewards(String ce, int shards) {
    return 'Queued rewards: +$ce CE | +$shards TS';
  }

  @override
  String successProbabilityLabel(int percent) {
    return 'SUCCESS PROBABILITY: $percent%';
  }

  @override
  String expeditionFailedTitle(String slot) {
    return '$slot | FAILED';
  }

  @override
  String get max => 'MAX';

  @override
  String get retrofitProtocol => 'RETROFIT PROTOCOL';

  @override
  String get upgradeLegacyUnitPrompt =>
      'Upgrade legacy unit to current temporal standards?';

  @override
  String get current => 'CURRENT';

  @override
  String get upgraded => 'UPGRADED';

  @override
  String get techTreeChronalStabilizer => 'Chronal Stabilizer';

  @override
  String get techTreeChronalStabilizerDescription =>
      'Reduces paradox buildup by 15%';

  @override
  String get techTreeQuantumDrill => 'Quantum Drill';

  @override
  String get techTreeQuantumDrillDescription =>
      'Increases mining efficiency by 25%';

  @override
  String get techTreeNeuralNetwork => 'Neural Network';

  @override
  String get techTreeNeuralNetworkDescription =>
      'Workers automate tasks 10% faster';

  @override
  String techTreeCostCe(String amount) {
    return '$amount CE';
  }

  @override
  String techCost(String value) {
    return 'COST: $value';
  }

  @override
  String techCostCe(String value) {
    return 'COST: $value CE';
  }
}
