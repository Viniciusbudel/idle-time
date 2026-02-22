import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Time Factory'**
  String get appTitle;

  /// Message shown during initial loading
  ///
  /// In en, this message translates to:
  /// **'Loading Timeline...'**
  String get loadingTimeline;

  /// No description provided for @chambers.
  ///
  /// In en, this message translates to:
  /// **'CHAMBERS'**
  String get chambers;

  /// No description provided for @factory.
  ///
  /// In en, this message translates to:
  /// **'FACTORY'**
  String get factory;

  /// No description provided for @summon.
  ///
  /// In en, this message translates to:
  /// **'SUMMON'**
  String get summon;

  /// No description provided for @tech.
  ///
  /// In en, this message translates to:
  /// **'TECH'**
  String get tech;

  /// No description provided for @prestige.
  ///
  /// In en, this message translates to:
  /// **'PRESTIGE'**
  String get prestige;

  /// No description provided for @currentOutput.
  ///
  /// In en, this message translates to:
  /// **'CURRENT OUTPUT'**
  String get currentOutput;

  /// No description provided for @perSecond.
  ///
  /// In en, this message translates to:
  /// **'/ SEC'**
  String get perSecond;

  /// No description provided for @sysOnline.
  ///
  /// In en, this message translates to:
  /// **'SYS :: ONLINE'**
  String get sysOnline;

  /// No description provided for @efficiency.
  ///
  /// In en, this message translates to:
  /// **'EFF'**
  String get efficiency;

  /// No description provided for @stability.
  ///
  /// In en, this message translates to:
  /// **'STABILITY'**
  String get stability;

  /// No description provided for @systemUpgrade.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM UPGRADE'**
  String get systemUpgrade;

  /// No description provided for @initUpgrade.
  ///
  /// In en, this message translates to:
  /// **'INIT UPGRADE'**
  String get initUpgrade;

  /// No description provided for @initializeExpansion.
  ///
  /// In en, this message translates to:
  /// **'Initialize expansion protocol?'**
  String get initializeExpansion;

  /// No description provided for @lvl.
  ///
  /// In en, this message translates to:
  /// **'LVL'**
  String get lvl;

  /// No description provided for @manageUnits.
  ///
  /// In en, this message translates to:
  /// **'MANAGE UNITS'**
  String get manageUnits;

  /// No description provided for @workerManagement.
  ///
  /// In en, this message translates to:
  /// **'WORKER MANAGEMENT'**
  String get workerManagement;

  /// No description provided for @mergeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Merge 3 workers of the same rarity to create 1 of higher rarity.'**
  String get mergeInstructions;

  /// No description provided for @legacyUnitsDetected.
  ///
  /// In en, this message translates to:
  /// **'LEGACY UNITS DETECTED'**
  String get legacyUnitsDetected;

  /// No description provided for @legacyUnitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Refit these workers to current era tech for significantly increased production.'**
  String get legacyUnitsDescription;

  /// No description provided for @refit.
  ///
  /// In en, this message translates to:
  /// **'REFIT'**
  String get refit;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'{count} Available'**
  String available(int count);

  /// No description provided for @needMoreToMerge.
  ///
  /// In en, this message translates to:
  /// **'Need 3 of same era to merge'**
  String get needMoreToMerge;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'MERGE'**
  String get merge;

  /// No description provided for @mergeSuccessful.
  ///
  /// In en, this message translates to:
  /// **'MERGE SUCCESSFUL!'**
  String get mergeSuccessful;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'{rarity} Unit'**
  String unit(String rarity);

  /// No description provided for @production.
  ///
  /// In en, this message translates to:
  /// **'PROD'**
  String get production;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'EXCELLENT'**
  String get excellent;

  /// No description provided for @techAugmentation.
  ///
  /// In en, this message translates to:
  /// **'TECH AUGMENTATION'**
  String get techAugmentation;

  /// No description provided for @systemUpgradesAvailable.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM UPGRADES AVAILABLE'**
  String get systemUpgradesAvailable;

  /// No description provided for @eraLocked.
  ///
  /// In en, this message translates to:
  /// **'ERA LOCKED'**
  String get eraLocked;

  /// No description provided for @researchIncomplete.
  ///
  /// In en, this message translates to:
  /// **'RESEARCH INCOMPLETE'**
  String get researchIncomplete;

  /// No description provided for @advanceTo.
  ///
  /// In en, this message translates to:
  /// **'ADVANCE TO {era}'**
  String advanceTo(String era);

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'COST'**
  String get cost;

  /// No description provided for @common.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get common;

  /// No description provided for @rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rare;

  /// No description provided for @epic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get epic;

  /// No description provided for @legendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get legendary;

  /// No description provided for @paradox.
  ///
  /// In en, this message translates to:
  /// **'Paradox'**
  String get paradox;

  /// No description provided for @victorian.
  ///
  /// In en, this message translates to:
  /// **'Victorian Era'**
  String get victorian;

  /// No description provided for @roaring20s.
  ///
  /// In en, this message translates to:
  /// **'Roaring 20s'**
  String get roaring20s;

  /// No description provided for @atomicAge.
  ///
  /// In en, this message translates to:
  /// **'Atomic Age'**
  String get atomicAge;

  /// No description provided for @cyberpunk80s.
  ///
  /// In en, this message translates to:
  /// **'Cyberpunk 80s'**
  String get cyberpunk80s;

  /// No description provided for @neoTokyo.
  ///
  /// In en, this message translates to:
  /// **'Neo-Tokyo'**
  String get neoTokyo;

  /// No description provided for @postSingularity.
  ///
  /// In en, this message translates to:
  /// **'Post-Singularity'**
  String get postSingularity;

  /// No description provided for @ancientRome.
  ///
  /// In en, this message translates to:
  /// **'Ancient Rome'**
  String get ancientRome;

  /// No description provided for @farFuture.
  ///
  /// In en, this message translates to:
  /// **'Far Future'**
  String get farFuture;

  /// No description provided for @chronoEnergy.
  ///
  /// In en, this message translates to:
  /// **'Chrono-Energy'**
  String get chronoEnergy;

  /// No description provided for @timeShards.
  ///
  /// In en, this message translates to:
  /// **'Time Shards'**
  String get timeShards;

  /// No description provided for @paradoxPoints.
  ///
  /// In en, this message translates to:
  /// **'Paradox Points'**
  String get paradoxPoints;

  /// No description provided for @base.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get base;

  /// No description provided for @techBonus.
  ///
  /// In en, this message translates to:
  /// **'Tech Bonus'**
  String get techBonus;

  /// No description provided for @ceSec.
  ///
  /// In en, this message translates to:
  /// **'CE/SEC'**
  String get ceSec;

  /// No description provided for @shards.
  ///
  /// In en, this message translates to:
  /// **'SHARDS'**
  String get shards;

  /// No description provided for @mergeFailed.
  ///
  /// In en, this message translates to:
  /// **'Merge failed'**
  String get mergeFailed;

  /// No description provided for @workerProtocols.
  ///
  /// In en, this message translates to:
  /// **'WORKER PROTOCOLS'**
  String get workerProtocols;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get online;

  /// No description provided for @basicLoopName.
  ///
  /// In en, this message translates to:
  /// **'Basic Loop Chamber'**
  String get basicLoopName;

  /// No description provided for @dualHelixName.
  ///
  /// In en, this message translates to:
  /// **'Dual Helix Chamber'**
  String get dualHelixName;

  /// No description provided for @nuclearReactorName.
  ///
  /// In en, this message translates to:
  /// **'Nuclear Fusion Reactor'**
  String get nuclearReactorName;

  /// No description provided for @paradoxAmplifierName.
  ///
  /// In en, this message translates to:
  /// **'Paradox Amplifier'**
  String get paradoxAmplifierName;

  /// No description provided for @timeDistortionName.
  ///
  /// In en, this message translates to:
  /// **'Time Distortion Field'**
  String get timeDistortionName;

  /// No description provided for @dataNodeName.
  ///
  /// In en, this message translates to:
  /// **'Data Node'**
  String get dataNodeName;

  /// No description provided for @synthLabName.
  ///
  /// In en, this message translates to:
  /// **'Synth Lab'**
  String get synthLabName;

  /// No description provided for @neonCoreName.
  ///
  /// In en, this message translates to:
  /// **'Neon Core'**
  String get neonCoreName;

  /// No description provided for @riftGeneratorName.
  ///
  /// In en, this message translates to:
  /// **'Rift Generator'**
  String get riftGeneratorName;

  /// No description provided for @chronoMasteryName.
  ///
  /// In en, this message translates to:
  /// **'Chrono Mastery'**
  String get chronoMasteryName;

  /// No description provided for @chronoMasteryDescription.
  ///
  /// In en, this message translates to:
  /// **'+10% CE production per point'**
  String get chronoMasteryDescription;

  /// No description provided for @riftStabilityName.
  ///
  /// In en, this message translates to:
  /// **'Rift Stability'**
  String get riftStabilityName;

  /// No description provided for @riftStabilityDescription.
  ///
  /// In en, this message translates to:
  /// **'-5% paradox accumulation per point'**
  String get riftStabilityDescription;

  /// No description provided for @eraInsightName.
  ///
  /// In en, this message translates to:
  /// **'Era Insight'**
  String get eraInsightName;

  /// No description provided for @eraInsightDescription.
  ///
  /// In en, this message translates to:
  /// **'+1 starting era unlocked per point'**
  String get eraInsightDescription;

  /// No description provided for @offlineBonusName.
  ///
  /// In en, this message translates to:
  /// **'Temporal Memory'**
  String get offlineBonusName;

  /// No description provided for @offlineBonusDescription.
  ///
  /// In en, this message translates to:
  /// **'+10% offline efficiency per point'**
  String get offlineBonusDescription;

  /// No description provided for @timekeepersFavorName.
  ///
  /// In en, this message translates to:
  /// **'Timekeeper\'s Favor'**
  String get timekeepersFavorName;

  /// No description provided for @timekeepersFavorDescription.
  ///
  /// In en, this message translates to:
  /// **'Raids easier, better rewards'**
  String get timekeepersFavorDescription;

  /// No description provided for @timelineCollapse.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE COLLAPSE'**
  String get timelineCollapse;

  /// No description provided for @prestigeDescription.
  ///
  /// In en, this message translates to:
  /// **'Reset your timeline to gain Prestige Points (PP).\nPP increases production by 10% per point.'**
  String get prestigeDescription;

  /// No description provided for @estimatedReward.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED REWARD'**
  String get estimatedReward;

  /// No description provided for @initiateCollapse.
  ///
  /// In en, this message translates to:
  /// **'INITIATE COLLAPSE'**
  String get initiateCollapse;

  /// No description provided for @prestigeRequirement.
  ///
  /// In en, this message translates to:
  /// **'Require more lifetime earnings to collapse.'**
  String get prestigeRequirement;

  /// No description provided for @activeWorkforce.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE WORKFORCE'**
  String get activeWorkforce;

  /// No description provided for @totalDailyYield.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DAILY YIELD'**
  String get totalDailyYield;

  /// No description provided for @operationalChambers.
  ///
  /// In en, this message translates to:
  /// **'OPERATIONAL CHAMBERS'**
  String get operationalChambers;

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM STATUS'**
  String get systemStatus;

  /// No description provided for @allSystemsOptimal.
  ///
  /// In en, this message translates to:
  /// **'ALL SYSTEMS OPTIMAL'**
  String get allSystemsOptimal;

  /// No description provided for @noActiveChambers.
  ///
  /// In en, this message translates to:
  /// **'No active chambers detected.'**
  String get noActiveChambers;

  /// No description provided for @deployWorkersToStart.
  ///
  /// In en, this message translates to:
  /// **'Deploy workers to start production.'**
  String get deployWorkersToStart;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @hireNewUnit.
  ///
  /// In en, this message translates to:
  /// **'HIRE NEW UNIT'**
  String get hireNewUnit;

  /// No description provided for @noUnitsDetected.
  ///
  /// In en, this message translates to:
  /// **'NO UNITS DETECTED'**
  String get noUnitsDetected;

  /// No description provided for @commandCenter.
  ///
  /// In en, this message translates to:
  /// **'COMMAND CENTER'**
  String get commandCenter;

  /// No description provided for @activeUnits.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE UNITS'**
  String get activeUnits;

  /// No description provided for @eraUnlocked.
  ///
  /// In en, this message translates to:
  /// **'ERA UNLOCKED'**
  String get eraUnlocked;

  /// No description provided for @initializePrimaryChamber.
  ///
  /// In en, this message translates to:
  /// **'Initialize the Primary Chamber to begin production.'**
  String get initializePrimaryChamber;

  /// No description provided for @initializeSystem.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZE SYSTEM'**
  String get initializeSystem;

  /// No description provided for @insufficientCE.
  ///
  /// In en, this message translates to:
  /// **'Insufficient CE for upgrade!'**
  String get insufficientCE;

  /// No description provided for @factoryFloorFull.
  ///
  /// In en, this message translates to:
  /// **'Factory Floor Full (Max 5 Chambers)!'**
  String get factoryFloorFull;

  /// No description provided for @needCEToConstruct.
  ///
  /// In en, this message translates to:
  /// **'Need {cost} CE to construct!'**
  String needCEToConstruct(Object cost);

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS:'**
  String get statusLabel;

  /// No description provided for @optimal.
  ///
  /// In en, this message translates to:
  /// **'OPTIMAL'**
  String get optimal;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'STABLE'**
  String get stable;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get critical;

  /// No description provided for @idle.
  ///
  /// In en, this message translates to:
  /// **'IDLE'**
  String get idle;

  /// No description provided for @repair.
  ///
  /// In en, this message translates to:
  /// **'REPAIR'**
  String get repair;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'ASSIGN'**
  String get assign;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE'**
  String get upgrade;

  /// No description provided for @advanceToEra.
  ///
  /// In en, this message translates to:
  /// **'ADVANCE TO {era}'**
  String advanceToEra(Object era);

  /// No description provided for @timelineMaximized.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE MAXIMIZED'**
  String get timelineMaximized;

  /// No description provided for @advanceTimeline.
  ///
  /// In en, this message translates to:
  /// **'ADVANCE TIMELINE'**
  String get advanceTimeline;

  /// No description provided for @techIncomplete.
  ///
  /// In en, this message translates to:
  /// **'TECH INCOMPLETE'**
  String get techIncomplete;

  /// No description provided for @requirement.
  ///
  /// In en, this message translates to:
  /// **'REQUIREMENT'**
  String get requirement;

  /// No description provided for @assignWorker.
  ///
  /// In en, this message translates to:
  /// **'ASSIGN WORKER'**
  String get assignWorker;

  /// No description provided for @selectUnitFor.
  ///
  /// In en, this message translates to:
  /// **'Select a unit for {station}'**
  String selectUnitFor(Object station);

  /// No description provided for @noIdleWorkers.
  ///
  /// In en, this message translates to:
  /// **'NO IDLE WORKERS'**
  String get noIdleWorkers;

  /// No description provided for @hireMoreToAssign.
  ///
  /// In en, this message translates to:
  /// **'Hire more units to assign'**
  String get hireMoreToAssign;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'WELCOME BACK'**
  String get welcomeBack;

  /// No description provided for @awayFor.
  ///
  /// In en, this message translates to:
  /// **'You were away for {duration}'**
  String awayFor(Object duration);

  /// No description provided for @ceCollected.
  ///
  /// In en, this message translates to:
  /// **'CHRONO-ENERGY COLLECTED'**
  String get ceCollected;

  /// No description provided for @offlineEfficiency.
  ///
  /// In en, this message translates to:
  /// **'{percent}% offline efficiency'**
  String offlineEfficiency(Object percent);

  /// No description provided for @collect.
  ///
  /// In en, this message translates to:
  /// **'COLLECT'**
  String get collect;

  /// No description provided for @timelineUnlocked.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE UNLOCKED'**
  String get timelineUnlocked;

  /// No description provided for @newEraAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new era is available for exploration. Travel now to access new technologies and resources.'**
  String get newEraAvailable;

  /// No description provided for @travelToEra.
  ///
  /// In en, this message translates to:
  /// **'TRAVEL TO ERA'**
  String get travelToEra;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get later;

  /// No description provided for @recallWorker.
  ///
  /// In en, this message translates to:
  /// **'RECALL WORKER'**
  String get recallWorker;

  /// No description provided for @noStationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'NO STATIONS AVAILABLE'**
  String get noStationsAvailable;

  /// No description provided for @buildStationsToStart.
  ///
  /// In en, this message translates to:
  /// **'Build stations in the Factory tab'**
  String get buildStationsToStart;

  /// No description provided for @upgradeStation.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE STATION'**
  String get upgradeStation;

  /// No description provided for @productionBonus.
  ///
  /// In en, this message translates to:
  /// **'Production Bonus'**
  String get productionBonus;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @nextEffect.
  ///
  /// In en, this message translates to:
  /// **'NEXT: +{percent}% {label}'**
  String nextEffect(Object label, Object percent);

  /// No description provided for @automationEffect.
  ///
  /// In en, this message translates to:
  /// **'AUTO-COLLECTION'**
  String get automationEffect;

  /// No description provided for @efficiencyEffect.
  ///
  /// In en, this message translates to:
  /// **'CORE PRODUCTION'**
  String get efficiencyEffect;

  /// No description provided for @timeWarpEffect.
  ///
  /// In en, this message translates to:
  /// **'TEMPORAL SPEED'**
  String get timeWarpEffect;

  /// No description provided for @costReductionEffect.
  ///
  /// In en, this message translates to:
  /// **'UPGRADE DISCOUNT'**
  String get costReductionEffect;

  /// No description provided for @offlineEffect.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE EARNINGS'**
  String get offlineEffect;

  /// No description provided for @clickPowerEffect.
  ///
  /// In en, this message translates to:
  /// **'MANUAL POWER'**
  String get clickPowerEffect;

  /// No description provided for @eraUnlockEffect.
  ///
  /// In en, this message translates to:
  /// **'ERA CLEARANCE'**
  String get eraUnlockEffect;

  /// No description provided for @manhattanEffect.
  ///
  /// In en, this message translates to:
  /// **'ATOMIC MULTIPLIER'**
  String get manhattanEffect;

  /// No description provided for @statusDeployed.
  ///
  /// In en, this message translates to:
  /// **'DEPLOYED'**
  String get statusDeployed;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'IDLE'**
  String get statusIdle;

  /// No description provided for @deploy.
  ///
  /// In en, this message translates to:
  /// **'DEPLOY'**
  String get deploy;

  /// No description provided for @full.
  ///
  /// In en, this message translates to:
  /// **'FULL'**
  String get full;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get settingsGeneral;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsData;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get settingsAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsResetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingsResetProgress;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get settingsReset;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'RESET ALL DATA?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase all progress, workers, and resources. This action cannot be undone.'**
  String get settingsResetConfirmBody;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get settingsDeveloper;

  /// No description provided for @tutorialWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'WELCOME, CHRONO-ENGINEER'**
  String get tutorialWelcomeTitle;

  /// No description provided for @tutorialWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'The timeline is unstable. We need to establish a production loop. Tap anywhere to initialize the protocol.'**
  String get tutorialWelcomeBody;

  /// No description provided for @tutorialHireTitle.
  ///
  /// In en, this message translates to:
  /// **'RECRUIT WORKFORCE'**
  String get tutorialHireTitle;

  /// No description provided for @tutorialHireBody.
  ///
  /// In en, this message translates to:
  /// **'Productivity is zero. You need workers from across history. Access the TIME RIFT to summon unit.'**
  String get tutorialHireBody;

  /// No description provided for @tutorialAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'DATA: IDLE UNIT'**
  String get tutorialAssignTitle;

  /// No description provided for @tutorialAssignBody.
  ///
  /// In en, this message translates to:
  /// **'We have a worker, but they are doing nothing. Drag them to a Chamber to start generating Chrono-Energy.'**
  String get tutorialAssignBody;

  /// No description provided for @tutorialProduceTitle.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM: ONLINE'**
  String get tutorialProduceTitle;

  /// No description provided for @tutorialProduceBody.
  ///
  /// In en, this message translates to:
  /// **'Production is stable. Tap the REACTOR to manually accelerate time and collect energy.'**
  String get tutorialProduceBody;

  /// No description provided for @tutorialGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'OBJECTIVE: COLLAPSE'**
  String get tutorialGoalTitle;

  /// No description provided for @tutorialGoalBody.
  ///
  /// In en, this message translates to:
  /// **'Great work. Your goal is to reach 1 MILLION CE to trigger a PRESTIGE EVENT and collapse the timeline. Good luck.'**
  String get tutorialGoalBody;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENTS'**
  String get achievements;

  /// No description provided for @ack.
  ///
  /// In en, this message translates to:
  /// **'ACK'**
  String get ack;

  /// No description provided for @activeTitle.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeTitle;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @artifactRollChance.
  ///
  /// In en, this message translates to:
  /// **'Artifact roll chance: {percent}%'**
  String artifactRollChance(int percent);

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @availableMissions.
  ///
  /// In en, this message translates to:
  /// **'Available Missions ({count})'**
  String availableMissions(int count);

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'AWESOME'**
  String get awesome;

  /// No description provided for @chronoEnergyUpper.
  ///
  /// In en, this message translates to:
  /// **'CHRONO ENERGY'**
  String get chronoEnergyUpper;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'CLAIM'**
  String get claim;

  /// No description provided for @claimAll.
  ///
  /// In en, this message translates to:
  /// **'CLAIM ALL'**
  String get claimAll;

  /// No description provided for @claimedRewardsCount.
  ///
  /// In en, this message translates to:
  /// **'Claimed {count} reward(s)'**
  String claimedRewardsCount(int count);

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completed;

  /// No description provided for @confirmSelectedWorkers.
  ///
  /// In en, this message translates to:
  /// **'Confirm ({selected}/{required})'**
  String confirmSelectedWorkers(int selected, int required);

  /// No description provided for @confirmUpgrade.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM UPGRADE'**
  String get confirmUpgrade;

  /// No description provided for @craft.
  ///
  /// In en, this message translates to:
  /// **'CRAFT'**
  String get craft;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @durationMinutesSeconds.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m {seconds}s'**
  String durationMinutesSeconds(int minutes, int seconds);

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String durationSeconds(int seconds);

  /// No description provided for @expeditionCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'{slot} | +{ce} CE | +{shards} TS'**
  String expeditionCompletedTitle(String slot, String ce, int shards);

  /// No description provided for @expeditionFailureLoss.
  ///
  /// In en, this message translates to:
  /// **'Lost {workers} worker(s) and {artifacts} artifact(s)'**
  String expeditionFailureLoss(int workers, int artifacts);

  /// No description provided for @expeditionReward.
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION REWARD'**
  String get expeditionReward;

  /// No description provided for @expeditionRiskBadge.
  ///
  /// In en, this message translates to:
  /// **'{risk}  x{ceMultiplier}  +{shards}TS  {artifactChance}%'**
  String expeditionRiskBadge(
    String risk,
    String ceMultiplier,
    int shards,
    int artifactChance,
  );

  /// No description provided for @expeditionStarted.
  ///
  /// In en, this message translates to:
  /// **'{slot} started ({risk}) with {workers} worker(s)'**
  String expeditionStarted(String slot, String risk, int workers);

  /// No description provided for @expeditionStatus.
  ///
  /// In en, this message translates to:
  /// **'EXPEDITION STATUS'**
  String get expeditionStatus;

  /// No description provided for @expeditionWorkersAssigned.
  ///
  /// In en, this message translates to:
  /// **'{workers} worker(s) assigned | reward profile: x{ceMultiplier} CE, +{shards} TS, {artifactChance}% artifact'**
  String expeditionWorkersAssigned(
    int workers,
    String ceMultiplier,
    int shards,
    int artifactChance,
  );

  /// No description provided for @expeditionWorkersReady.
  ///
  /// In en, this message translates to:
  /// **'Need {required} idle worker(s) | {available} ready'**
  String expeditionWorkersReady(int required, int available);

  /// No description provided for @expeditionWorkersReadyInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Need {required} idle worker(s) | only {available} ready'**
  String expeditionWorkersReadyInsufficient(int required, int available);

  /// No description provided for @failureReportAcknowledged.
  ///
  /// In en, this message translates to:
  /// **'Failure report acknowledged'**
  String get failureReportAcknowledged;

  /// No description provided for @hireSuccessful.
  ///
  /// In en, this message translates to:
  /// **'HIRE SUCCESSFUL!'**
  String get hireSuccessful;

  /// No description provided for @holdPressInspectTapEquip.
  ///
  /// In en, this message translates to:
  /// **'Hold-press to inspect ? Tap to equip'**
  String get holdPressInspectTapEquip;

  /// No description provided for @idleTitle.
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idleTitle;

  /// No description provided for @initiateExpedition.
  ///
  /// In en, this message translates to:
  /// **'INITIATE EXPEDITION'**
  String get initiateExpedition;

  /// No description provided for @labelValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String labelValue(String label, String value);

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'MANAGE'**
  String get manage;

  /// No description provided for @missionControl.
  ///
  /// In en, this message translates to:
  /// **'Mission Control'**
  String get missionControl;

  /// No description provided for @missions.
  ///
  /// In en, this message translates to:
  /// **'MISSIONS'**
  String get missions;

  /// No description provided for @nextCompletion.
  ///
  /// In en, this message translates to:
  /// **'Next completion: {slot} in {duration}'**
  String nextCompletion(String slot, String duration);

  /// No description provided for @noActiveExpeditions.
  ///
  /// In en, this message translates to:
  /// **'No active expeditions'**
  String get noActiveExpeditions;

  /// No description provided for @noArtifactsByFilter.
  ///
  /// In en, this message translates to:
  /// **'No {filter} artifacts in inventory.'**
  String noArtifactsByFilter(String filter);

  /// No description provided for @noChambersYet.
  ///
  /// In en, this message translates to:
  /// **'No chambers yet'**
  String get noChambersYet;

  /// No description provided for @noRewardsWaiting.
  ///
  /// In en, this message translates to:
  /// **'No rewards waiting'**
  String get noRewardsWaiting;

  /// No description provided for @noWorkersByRarity.
  ///
  /// In en, this message translates to:
  /// **'No {rarity} workers'**
  String noWorkersByRarity(String rarity);

  /// No description provided for @paradoxPointsAbbrev.
  ///
  /// In en, this message translates to:
  /// **'PP'**
  String get paradoxPointsAbbrev;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyTitle;

  /// No description provided for @resourceYieldLabel.
  ///
  /// In en, this message translates to:
  /// **'RESOURCE YIELD: {ce} CE'**
  String resourceYieldLabel(String ce);

  /// No description provided for @resourceYieldUnavailable.
  ///
  /// In en, this message translates to:
  /// **'RESOURCE YIELD: --'**
  String get resourceYieldUnavailable;

  /// No description provided for @salvage.
  ///
  /// In en, this message translates to:
  /// **'SALVAGE'**
  String get salvage;

  /// No description provided for @salvagedArtifactDust.
  ///
  /// In en, this message translates to:
  /// **'Salvaged artifact: +{dust} Dust'**
  String salvagedArtifactDust(int dust);

  /// No description provided for @searchArtifacts.
  ///
  /// In en, this message translates to:
  /// **'SEARCH ARTIFACTS...'**
  String get searchArtifacts;

  /// No description provided for @selectWorkers.
  ///
  /// In en, this message translates to:
  /// **'Select {required} worker(s)'**
  String selectWorkers(int required);

  /// No description provided for @selectedWorkers.
  ///
  /// In en, this message translates to:
  /// **'Selected {selected}/{required}'**
  String selectedWorkers(int selected, int required);

  /// No description provided for @tapWorkerIconsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap worker icons above to assign or swap the crew.'**
  String get tapWorkerIconsHint;

  /// No description provided for @timeShardsAbbrev.
  ///
  /// In en, this message translates to:
  /// **'TS'**
  String get timeShardsAbbrev;

  /// No description provided for @timeShardsUpper.
  ///
  /// In en, this message translates to:
  /// **'TIME SHARDS'**
  String get timeShardsUpper;

  /// No description provided for @unableClaimExpedition.
  ///
  /// In en, this message translates to:
  /// **'Unable to claim expedition result.'**
  String get unableClaimExpedition;

  /// No description provided for @unableStartExpedition.
  ///
  /// In en, this message translates to:
  /// **'Unable to start expedition with selected workers.'**
  String get unableStartExpedition;

  /// No description provided for @unassign.
  ///
  /// In en, this message translates to:
  /// **'UNASSIGN'**
  String get unassign;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'WELCOME'**
  String get welcome;

  /// No description provided for @allArtifactSlotsFilled.
  ///
  /// In en, this message translates to:
  /// **'ALL {slots} SLOTS FILLED - Unequip an artifact first.'**
  String allArtifactSlotsFilled(int slots);

  /// No description provided for @craftFailedDustOrInventory.
  ///
  /// In en, this message translates to:
  /// **'Craft failed (dust or inventory limit).'**
  String get craftFailedDustOrInventory;

  /// No description provided for @upgradeMaxed.
  ///
  /// In en, this message translates to:
  /// **'{title} maxed'**
  String upgradeMaxed(String title);

  /// No description provided for @upgradeCostsPp.
  ///
  /// In en, this message translates to:
  /// **'{title} costs {cost} PP'**
  String upgradeCostsPp(String title, int cost);

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'LOCKED'**
  String get locked;

  /// No description provided for @prestigesCount.
  ///
  /// In en, this message translates to:
  /// **'Prestiges: {count}'**
  String prestigesCount(int count);

  /// No description provided for @activeExpeditions.
  ///
  /// In en, this message translates to:
  /// **'Active Expeditions ({count})'**
  String activeExpeditions(int count);

  /// No description provided for @queuedRewards.
  ///
  /// In en, this message translates to:
  /// **'Queued rewards: +{ce} CE | +{shards} TS'**
  String queuedRewards(String ce, int shards);

  /// No description provided for @successProbabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'SUCCESS PROBABILITY: {percent}%'**
  String successProbabilityLabel(int percent);

  /// No description provided for @expeditionFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'{slot} | FAILED'**
  String expeditionFailedTitle(String slot);

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get max;

  /// No description provided for @retrofitProtocol.
  ///
  /// In en, this message translates to:
  /// **'RETROFIT PROTOCOL'**
  String get retrofitProtocol;

  /// No description provided for @upgradeLegacyUnitPrompt.
  ///
  /// In en, this message translates to:
  /// **'Upgrade legacy unit to current temporal standards?'**
  String get upgradeLegacyUnitPrompt;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @upgraded.
  ///
  /// In en, this message translates to:
  /// **'UPGRADED'**
  String get upgraded;

  /// No description provided for @techTreeChronalStabilizer.
  ///
  /// In en, this message translates to:
  /// **'Chronal Stabilizer'**
  String get techTreeChronalStabilizer;

  /// No description provided for @techTreeChronalStabilizerDescription.
  ///
  /// In en, this message translates to:
  /// **'Reduces paradox buildup by 15%'**
  String get techTreeChronalStabilizerDescription;

  /// No description provided for @techTreeQuantumDrill.
  ///
  /// In en, this message translates to:
  /// **'Quantum Drill'**
  String get techTreeQuantumDrill;

  /// No description provided for @techTreeQuantumDrillDescription.
  ///
  /// In en, this message translates to:
  /// **'Increases mining efficiency by 25%'**
  String get techTreeQuantumDrillDescription;

  /// No description provided for @techTreeNeuralNetwork.
  ///
  /// In en, this message translates to:
  /// **'Neural Network'**
  String get techTreeNeuralNetwork;

  /// No description provided for @techTreeNeuralNetworkDescription.
  ///
  /// In en, this message translates to:
  /// **'Workers automate tasks 10% faster'**
  String get techTreeNeuralNetworkDescription;

  /// No description provided for @techTreeCostCe.
  ///
  /// In en, this message translates to:
  /// **'{amount} CE'**
  String techTreeCostCe(String amount);

  /// No description provided for @techCost.
  ///
  /// In en, this message translates to:
  /// **'COST: {value}'**
  String techCost(String value);

  /// No description provided for @techCostCe.
  ///
  /// In en, this message translates to:
  /// **'COST: {value} CE'**
  String techCostCe(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
