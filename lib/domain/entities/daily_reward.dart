import 'package:time_factory/domain/entities/enums.dart';

enum DailyRewardType { chronoEnergy, timeShard, worker }

class DailyReward {
  final int day;
  final DailyRewardType type;
  final BigInt? amountCE;
  final int? amountShards;
  final WorkerRarity? workerRarity;

  const DailyReward({
    required this.day,
    required this.type,
    this.amountCE,
    this.amountShards,
    this.workerRarity,
  });

  /// Helper to create a resource reward
  factory DailyReward.resource({
    required int day,
    required DailyRewardType type,
    BigInt? ce,
    int? shards,
  }) {
    return DailyReward(
      day: day,
      type: type,
      amountCE: ce,
      amountShards: shards,
    );
  }

  /// Helper to create a worker reward
  factory DailyReward.worker({required int day, required WorkerRarity rarity}) {
    return DailyReward(
      day: day,
      type: DailyRewardType.worker,
      workerRarity: rarity,
    );
  }

  /// Hardcoded rewards chart for 7 days
  static List<DailyReward> get weekRewards => [
    DailyReward.resource(
      day: 1,
      type: DailyRewardType.chronoEnergy,
      ce: BigInt.from(1000),
    ),
    DailyReward.resource(day: 2, type: DailyRewardType.timeShard, shards: 5),
    DailyReward.resource(
      day: 3,
      type: DailyRewardType.chronoEnergy,
      ce: BigInt.from(5000),
    ),
    DailyReward.resource(day: 4, type: DailyRewardType.timeShard, shards: 15),
    DailyReward.resource(
      day: 5,
      type: DailyRewardType.chronoEnergy,
      ce: BigInt.from(25000),
    ),
    DailyReward.resource(day: 6, type: DailyRewardType.timeShard, shards: 30),
    DailyReward.worker(
      day: 7,
      rarity: WorkerRarity.paradox,
    ), // Guaranteed Paradox!
  ];
}
