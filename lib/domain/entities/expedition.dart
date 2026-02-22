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
  final String name;
  final Duration duration;
  final int requiredWorkers;
  final ExpeditionRisk defaultRisk;

  const ExpeditionSlot({
    required this.id,
    required this.name,
    required this.duration,
    required this.requiredWorkers,
    this.defaultRisk = ExpeditionRisk.safe,
  });

  static const List<ExpeditionSlot> defaults = [
    ExpeditionSlot(
      id: 'salvage_run',
      name: 'Salvage Run',
      duration: Duration(minutes: 30),
      requiredWorkers: 1,
      defaultRisk: ExpeditionRisk.safe,
    ),
    ExpeditionSlot(
      id: 'rift_probe',
      name: 'Rift Probe',
      duration: Duration(hours: 2),
      requiredWorkers: 2,
      defaultRisk: ExpeditionRisk.risky,
    ),
    ExpeditionSlot(
      id: 'timeline_heist',
      name: 'Timeline Heist',
      duration: Duration(hours: 8),
      requiredWorkers: 3,
      defaultRisk: ExpeditionRisk.volatile,
    ),
  ];
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
