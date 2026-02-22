import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/domain/entities/game_state.dart';
import 'package:time_factory/domain/usecases/check_tech_completion_usecase.dart';
import 'package:time_factory/core/constants/tech_data.dart';

void main() {
  group('CheckTechCompletionUseCase', () {
    late CheckTechCompletionUseCase useCase;

    setUp(() {
      useCase = CheckTechCompletionUseCase();
    });

    test('Should return true when all Roaring 20s techs are maxed', () {
      final roaring20sTechs = TechData.initialTechs
          .where((t) => t.eraId == 'roaring_20s')
          .toList();

      final techLevels = <String, int>{};
      for (final tech in roaring20sTechs) {
        techLevels[tech.id] = tech.maxLevel;
      }

      final state = GameState.initial().copyWith(
        currentEraId: 'roaring_20s',
        techLevels: techLevels,
      );

      final result = useCase.execute(state, 'roaring_20s');
      expect(result, isTrue);
    });

    test('Should return false when at least one tech is NOT maxed', () {
      final roaring20sTechs = TechData.initialTechs
          .where((t) => t.eraId == 'roaring_20s')
          .toList();

      final techLevels = <String, int>{};
      for (final tech in roaring20sTechs) {
        techLevels[tech.id] = tech.maxLevel;
      }

      // De-max one tech
      if (roaring20sTechs.isNotEmpty) {
        techLevels[roaring20sTechs.first.id] =
            roaring20sTechs.first.maxLevel - 1;
      }

      final state = GameState.initial().copyWith(
        currentEraId: 'roaring_20s',
        techLevels: techLevels,
      );

      final result = useCase.execute(state, 'roaring_20s');
      expect(result, isFalse);
    });

    test('Should check exactly which techs are in roaring_20s', () {
      final roaring20sTechs = TechData.initialTechs
          .where((t) => t.eraId == 'roaring_20s')
          .toList();

      print(
        'Roaring 20s Techs found: ${roaring20sTechs.map((t) => t.id).toList()}',
      );
      expect(roaring20sTechs.length, greaterThan(0));
    });
  });
}
