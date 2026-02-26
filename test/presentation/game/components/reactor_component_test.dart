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

  test('reactor asset falls back to steampunk for other eras', () {
    expect(
      ReactorComponent.assetForEra('cyberpunk_80s'),
      GameAssets.steampunkReactor,
    );
    expect(ReactorComponent.assetForEra(null), GameAssets.steampunkReactor);
  });
}
