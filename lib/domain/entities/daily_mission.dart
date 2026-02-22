enum MissionType { hireWorkers, mergeWorkers, buyTechUpgrades }

class DailyMission {
  final String id;
  final MissionType type;
  final int target;
  final int progress;
  final bool claimed;
  final BigInt rewardCE;
  final int rewardShards;

  DailyMission({
    required this.id,
    required this.type,
    required this.target,
    this.progress = 0,
    this.claimed = false,
    BigInt? rewardCE,
    this.rewardShards = 0,
  }) : rewardCE = rewardCE ?? BigInt.zero;

  bool get isCompleted => progress >= target;

  DailyMission copyWith({
    String? id,
    MissionType? type,
    int? target,
    int? progress,
    bool? claimed,
    BigInt? rewardCE,
    int? rewardShards,
  }) {
    return DailyMission(
      id: id ?? this.id,
      type: type ?? this.type,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      claimed: claimed ?? this.claimed,
      rewardCE: rewardCE ?? this.rewardCE,
      rewardShards: rewardShards ?? this.rewardShards,
    );
  }

  String get title {
    switch (type) {
      case MissionType.hireWorkers:
        return 'Hire Workers';
      case MissionType.mergeWorkers:
        return 'Merge Workers';
      case MissionType.buyTechUpgrades:
        return 'Buy Tech Upgrades';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'target': target,
      'progress': progress,
      'claimed': claimed,
      'rewardCE': rewardCE.toString(),
      'rewardShards': rewardShards,
    };
  }

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map['id'] as String,
      type: MissionType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => MissionType.hireWorkers,
      ),
      target: map['target'] as int,
      progress: map['progress'] as int? ?? 0,
      claimed: map['claimed'] as bool? ?? false,
      rewardCE: BigInt.parse((map['rewardCE'] ?? '0').toString()),
      rewardShards: map['rewardShards'] as int? ?? 0,
    );
  }
}
