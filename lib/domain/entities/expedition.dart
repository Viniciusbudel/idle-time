class ExpeditionReward {
  final BigInt chronoEnergy;
  final int timeShards;
  final double artifactDropChance;

  const ExpeditionReward({
    required this.chronoEnergy,
    required this.timeShards,
    required this.artifactDropChance,
  });

  static final ExpeditionReward zero = ExpeditionReward(
    chronoEnergy: BigInt.zero,
    timeShards: 0,
    artifactDropChance: 0.0,
  );

  ExpeditionReward copyWith({
    BigInt? chronoEnergy,
    int? timeShards,
    double? artifactDropChance,
  }) {
    return ExpeditionReward(
      chronoEnergy: chronoEnergy ?? this.chronoEnergy,
      timeShards: timeShards ?? this.timeShards,
      artifactDropChance: artifactDropChance ?? this.artifactDropChance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chronoEnergy': chronoEnergy.toString(),
      'timeShards': timeShards,
      'artifactDropChance': artifactDropChance,
    };
  }

  factory ExpeditionReward.fromMap(Map<String, dynamic> map) {
    return ExpeditionReward(
      chronoEnergy: BigInt.parse((map['chronoEnergy'] ?? '0').toString()),
      timeShards: map['timeShards'] as int? ?? 0,
      artifactDropChance: (map['artifactDropChance'] as num?)?.toDouble() ?? 0,
    );
  }
}

enum ExpeditionRisk {
  safe('safe', 1.0, 1, 0.05),
  risky('risky', 1.6, 2, 0.12),
  volatile('volatile', 2.4, 4, 0.22);

  final String id;
  final double ceMultiplier;
  final int shardReward;
  final double artifactDropChance;

  const ExpeditionRisk(
    this.id,
    this.ceMultiplier,
    this.shardReward,
    this.artifactDropChance,
  );

  static ExpeditionRisk fromId(String id) {
    return ExpeditionRisk.values.firstWhere(
      (risk) => risk.id == id,
      orElse: () => ExpeditionRisk.safe,
    );
  }
}

class ExpeditionSlot {
  final String id;
  final String eraId;
  final String unlockEraId;
  final int unlockEraIndex;
  final String name;
  final String headline;
  final String layoutPreset;
  final Duration duration;
  final int requiredWorkers;
  final ExpeditionRisk defaultRisk;

  const ExpeditionSlot({
    required this.id,
    required this.eraId,
    required this.unlockEraId,
    required this.unlockEraIndex,
    required this.name,
    required this.headline,
    required this.layoutPreset,
    required this.duration,
    required this.requiredWorkers,
    this.defaultRisk = ExpeditionRisk.safe,
  });

  /// One expedition slot per era in the configured era progression order.
  static const List<ExpeditionSlot> catalog = [
    ExpeditionSlot(
      id: 'salvage_run',
      eraId: 'victorian',
      unlockEraId: 'victorian',
      unlockEraIndex: 0,
      name: 'Whitechapel Ember',
      headline: 'Soot, valves, and secrets beneath London.',
      layoutPreset: 'victorian_copper',
      duration: Duration(minutes: 30),
      requiredWorkers: 1,
      defaultRisk: ExpeditionRisk.safe,
    ),
    ExpeditionSlot(
      id: 'rift_probe',
      eraId: 'roaring_20s',
      unlockEraId: 'roaring_20s',
      unlockEraIndex: 1,
      name: 'Speakeasy Gold Run',
      headline: 'Temporal smuggling between jazz and art deco.',
      layoutPreset: 'roaring_20s_deco',
      duration: Duration(hours: 2),
      requiredWorkers: 2,
      defaultRisk: ExpeditionRisk.risky,
    ),
    ExpeditionSlot(
      id: 'timeline_heist',
      eraId: 'atomic_age',
      unlockEraId: 'atomic_age',
      unlockEraIndex: 2,
      name: 'Isotope-51 Convoy',
      headline: 'Retro-futurist tests in a radioactive suburb.',
      layoutPreset: 'atomic_age_chrome',
      duration: Duration(hours: 8),
      requiredWorkers: 3,
      defaultRisk: ExpeditionRisk.volatile,
    ),
    ExpeditionSlot(
      id: 'neon_ghost_run',
      eraId: 'cyberpunk_80s',
      unlockEraId: 'cyberpunk_80s',
      unlockEraIndex: 3,
      name: 'Neon Ghost Run',
      headline: 'Stolen payloads in the neon nights of 1984.',
      layoutPreset: 'cyberpunk_80s_neon_grid',
      duration: Duration(hours: 10),
      requiredWorkers: 3,
      defaultRisk: ExpeditionRisk.volatile,
    ),
    ExpeditionSlot(
      id: 'shibuya_2247_drop',
      eraId: 'neo_tokyo',
      unlockEraId: 'neo_tokyo',
      unlockEraIndex: 4,
      name: 'Shibuya-2247 Drop',
      headline: 'Extract data before district collapse.',
      layoutPreset: 'neo_tokyo_glass',
      duration: Duration(hours: 12),
      requiredWorkers: 4,
      defaultRisk: ExpeditionRisk.volatile,
    ),
    ExpeditionSlot(
      id: 'void_cloud_harvest',
      eraId: 'post_singularity',
      unlockEraId: 'post_singularity',
      unlockEraIndex: 5,
      name: 'Void-Cloud Harvest',
      headline: 'Autonomous entities contest quantum memory.',
      layoutPreset: 'post_singularity_ether',
      duration: Duration(hours: 16),
      requiredWorkers: 4,
      defaultRisk: ExpeditionRisk.volatile,
    ),
    ExpeditionSlot(
      id: 'forum_aquila',
      eraId: 'ancient_rome',
      unlockEraId: 'ancient_rome',
      unlockEraIndex: 6,
      name: 'Forum Aquila',
      headline: 'Recover chrono-imperial relics beneath the Senate.',
      layoutPreset: 'ancient_rome_marble',
      duration: Duration(hours: 14),
      requiredWorkers: 4,
      defaultRisk: ExpeditionRisk.risky,
    ),
    ExpeditionSlot(
      id: 'rift_9_cartography',
      eraId: 'far_future',
      unlockEraId: 'far_future',
      unlockEraIndex: 7,
      name: 'Rift-9 Cartography',
      headline: 'Map cosmic fractures beyond known space.',
      layoutPreset: 'far_future_holo',
      duration: Duration(hours: 24),
      requiredWorkers: 5,
      defaultRisk: ExpeditionRisk.volatile,
    ),
  ];

  // Backward compatibility with existing call sites.
  static const List<ExpeditionSlot> defaults = catalog;

  static ExpeditionSlot? byId(String slotId) {
    for (final slot in catalog) {
      if (slot.id == slotId) {
        return slot;
      }
    }
    return null;
  }
}

class Expedition {
  final String id;
  final String slotId;
  final ExpeditionRisk risk;
  final List<String> workerIds;
  final DateTime startTime;
  final DateTime endTime;
  final double successProbability;
  final bool resolved;
  final bool? wasSuccessful;
  final ExpeditionReward? resolvedReward;
  final List<String> lostWorkerIds;
  final int lostArtifactCount;

  const Expedition({
    required this.id,
    required this.slotId,
    required this.risk,
    required this.workerIds,
    required this.startTime,
    required this.endTime,
    this.successProbability = 0.75,
    this.resolved = false,
    this.wasSuccessful,
    this.resolvedReward,
    this.lostWorkerIds = const [],
    this.lostArtifactCount = 0,
  });

  Expedition copyWith({
    String? id,
    String? slotId,
    ExpeditionRisk? risk,
    List<String>? workerIds,
    DateTime? startTime,
    DateTime? endTime,
    double? successProbability,
    bool? resolved,
    bool? wasSuccessful,
    ExpeditionReward? resolvedReward,
    List<String>? lostWorkerIds,
    int? lostArtifactCount,
  }) {
    return Expedition(
      id: id ?? this.id,
      slotId: slotId ?? this.slotId,
      risk: risk ?? this.risk,
      workerIds: workerIds ?? this.workerIds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      successProbability: successProbability ?? this.successProbability,
      resolved: resolved ?? this.resolved,
      wasSuccessful: wasSuccessful ?? this.wasSuccessful,
      resolvedReward: resolvedReward ?? this.resolvedReward,
      lostWorkerIds: lostWorkerIds ?? this.lostWorkerIds,
      lostArtifactCount: lostArtifactCount ?? this.lostArtifactCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'slotId': slotId,
      'risk': risk.id,
      'workerIds': workerIds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'successProbability': successProbability,
      'resolved': resolved,
      'wasSuccessful': wasSuccessful,
      'resolvedReward': resolvedReward?.toMap(),
      'lostWorkerIds': lostWorkerIds,
      'lostArtifactCount': lostArtifactCount,
    };
  }

  factory Expedition.fromMap(Map<String, dynamic> map) {
    final risk = ExpeditionRisk.fromId((map['risk'] ?? 'safe').toString());
    return Expedition(
      id: map['id'] as String,
      slotId: map['slotId'] as String,
      risk: risk,
      workerIds: List<String>.from(
        map['workerIds'] as List<dynamic>? ?? const [],
      ),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      successProbability:
          (map['successProbability'] as num?)?.toDouble() ??
          _legacyFallbackChance(risk),
      resolved: map['resolved'] as bool? ?? false,
      wasSuccessful: map['wasSuccessful'] as bool?,
      resolvedReward: map['resolvedReward'] != null
          ? ExpeditionReward.fromMap(
              map['resolvedReward'] as Map<String, dynamic>,
            )
          : null,
      lostWorkerIds: List<String>.from(
        map['lostWorkerIds'] as List<dynamic>? ?? const [],
      ),
      lostArtifactCount: map['lostArtifactCount'] as int? ?? 0,
    );
  }

  static double _legacyFallbackChance(ExpeditionRisk risk) {
    switch (risk) {
      case ExpeditionRisk.safe:
        return 0.85;
      case ExpeditionRisk.risky:
        return 0.72;
      case ExpeditionRisk.volatile:
        return 0.58;
    }
  }
}
