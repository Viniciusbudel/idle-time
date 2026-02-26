import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_factory/presentation/ui/atoms/merge_effect_overlay.dart';

void main() {
  testWidgets(
    'MergeEffectOverlay can be used inside Positioned.fill without parent data conflicts',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(child: MergeEffectOverlay(onComplete: () {})),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
