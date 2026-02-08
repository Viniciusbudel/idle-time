class OfflineEarnings {
  final BigInt ceEarned;
  final Duration offlineDuration;
  final double efficiency;

  const OfflineEarnings({
    required this.ceEarned,
    required this.offlineDuration,
    this.efficiency = 1.0,
  });

  String get formattedDuration {
    if (offlineDuration.inHours > 0) {
      return '${offlineDuration.inHours}h ${offlineDuration.inMinutes % 60}m';
    } else {
      return '${offlineDuration.inMinutes}m ${offlineDuration.inSeconds % 60}s';
    }
  }
}
