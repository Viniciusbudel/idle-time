import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/core/constants/game_assets.dart';
import 'package:time_factory/presentation/game/components/reactor_component.dart';

void main() {
  test('reactor asset maps roaring_20s to 20s reactor', () {
    expect(
      ReactorComponent.assetForEra('roaring_20s'),
      GameAssets.roaring20sReactor,
    );
  });

  test('reactor asset maps atomic_age to atomic reactor', () {
    expect(
      ReactorComponent.assetForEra('atomic_age'),
      GameAssets.atomicReactor,
    );
  });

  test('reactor asset maps cyberpunk_80s to cyberpunk reactor', () {
    expect(
      ReactorComponent.assetForEra('cyberpunk_80s'),
      GameAssets.cyberpunkReactor,
    );
  });

  test('reactor asset maps post_singularity to singularity reactor', () {
    expect(
      ReactorComponent.assetForEra('post_singularity'),
      GameAssets.singularityReactor,
    );
  });

  test('reactor asset falls back to steampunk for unknown/null eras', () {
    expect(
      ReactorComponent.assetForEra('unknown_era'),
      GameAssets.steampunkReactor,
    );
    expect(ReactorComponent.assetForEra(null), GameAssets.steampunkReactor);
  });
}
