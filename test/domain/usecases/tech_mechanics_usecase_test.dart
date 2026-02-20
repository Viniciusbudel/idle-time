import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/usecases/production_loop_usecase.dart';

void main() {
  late ProductionLoopUseCase useCase;
  late GameState initialState;

  setUp(() {
    useCase = ProductionLoopUseCase();
    initialState = GameState.initial().copyWith(chronoEnergy: BigInt.zero);
  });

  test('Additional production (Auto-Click) should be added to total CE', () {
    final result = useCase.execute(
      currentState: initialState,
      dt: 1.0,
      productionRate: BigInt.from(100),
      techMultiplier: 1.0,
      currentFractionalAccumulator: 0.0,
      additionalProduction: BigInt.from(50), // Auto-click bonus
    );

    // Expected: 100 (production) + 50 (auto) = 150
    expect(result.ceAdded, equals(BigInt.from(150)));
  });

  test(
    'Fractional accumulator should handle additional production correctly',
    () {
      // 0.5 sec * 100 = 50
      // + 50 additional
      // Total = 100
      final result = useCase.execute(
        currentState: initialState,
        dt: 0.5,
        productionRate: BigInt.from(100),
        techMultiplier: 1.0,
        currentFractionalAccumulator: 0.0,
        additionalProduction: BigInt.from(50),
      );

      expect(result.ceAdded, equals(BigInt.from(100)));
      expect(result.fractionalRemainder, equals(0.0));
    },
  );
}

// Extension to allow setting productionPerSecond for testing (mocking it)
// Since it's a getter on GameState, we can't set it directly in copyWith easily 
// unless we mock the workers/stations. 
// However, the usecase takes productionRate as a param, so we test the usecase directly.
