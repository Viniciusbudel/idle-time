import '../../domain/entities/game_state.dart';

class EmbraceChaosUseCase {
  GameState execute(GameState state) {
    if (state.paradoxLevel < 0.8) return state; // Must be high enough

    return state.copyWith(
      paradoxEventActive: true,
      paradoxEventEndTime: DateTime.now().add(const Duration(seconds: 20)),
      paradoxLevel: (state.paradoxLevel * 0.7).clamp(
        0.0,
        1.0,
      ), // Reduce instability
    );
  }
}
