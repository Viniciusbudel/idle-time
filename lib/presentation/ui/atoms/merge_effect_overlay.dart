import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/presentation/anim/merge_effect_game.dart';

class MergeEffectOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final Color primaryColor;

  const MergeEffectOverlay({
    super.key,
    required this.onComplete,
    this.primaryColor = Colors.white,
  });

  @override
  State<MergeEffectOverlay> createState() => _MergeEffectOverlayState();
}

class _MergeEffectOverlayState extends State<MergeEffectOverlay> {
  late MergeEffectGame _game;

  @override
  void initState() {
    super.initState();
    _game = MergeEffectGame(
      onComplete: widget.onComplete,
      primaryColor: widget.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
