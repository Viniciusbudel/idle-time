import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/entities/station.dart';

class UpgradeStationUseCase {
  GameState execute(GameState currentState, String stationId) {
    final station = currentState.stations[stationId];
    if (station == null) return currentState;

    final cost = station.upgradeCost;
    if (currentState.chronoEnergy < cost) return currentState;

    // Deduct cost
    final newCe = currentState.chronoEnergy - cost;

    // Upgrade station
    // Note: Station.upgradeCost logic in entity already handles scaling based on level
    final newStation = station.copyWith(level: station.level + 1);

    final newStations = Map<String, Station>.from(currentState.stations);
    newStations[stationId] = newStation;

    return currentState.copyWith(chronoEnergy: newCe, stations: newStations);
  }
}
