import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/presentation/anim/void_hiring_game.dart';

class VoidHiringOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final WorkerRarity rarity;

  const VoidHiringOverlay({
    super.key,
    required this.onComplete,
    required this.rarity,
  });

  @override
  State<VoidHiringOverlay> createState() => _VoidHiringOverlayState();
}

class _VoidHiringOverlayState extends State<VoidHiringOverlay> {
  late VoidHiringGame _game;

  @override
  void initState() {
    super.initState();
    _game = VoidHiringGame(
      onComplete: widget.onComplete,
      rarity: widget.rarity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: GameWidget(game: _game));
  }
}
