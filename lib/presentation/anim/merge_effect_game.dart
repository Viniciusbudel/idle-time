import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class MergeEffectGame extends FlameGame {
  final VoidCallback onComplete;
  final Color primaryColor;
  final Random _random = Random();

  MergeEffectGame({required this.onComplete, this.primaryColor = Colors.white});

  @override
  Color backgroundColor() => const Color(0x00000000); // Transparent

  @override
  Future<void> onLoad() async {
    final center = size / 2;

    // Phase 1: Implosion (Particles gathering to center)
    // Create a ring that collapses
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 40,
          lifespan: 0.8,
          generator: (i) {
            final angle = (i / 40) * 2 * pi;
            final dist = 150.0;
            final startPos = center + Vector2(cos(angle), sin(angle)) * dist;

            return AcceleratedParticle(
              position: startPos,
              speed: (center - startPos) * 1.5, // Move towards center
              child: CircleParticle(
                radius: 3.0,
                paint: Paint()..color = primaryColor.withValues(alpha: 0.5),
              ),
            );
          },
        ),
      ),
    );

    // Phase 2: Explosion (After Implosion)
    add(
      TimerComponent(
        period: 0.8, // Wait for implosion
        removeOnFinish: true,
        onTick: () {
          // Main Shockwave
          add(
            ParticleSystemComponent(
              particle: Particle.generate(
                count: 100,
                lifespan: 1.5,
                generator: (i) {
                  final angle = _random.nextDouble() * 2 * pi;
                  final speed = _random.nextDouble() * 400 + 100;
                  final scale = _random.nextDouble() * 0.5 + 0.5;

                  return AcceleratedParticle(
                    position: center,
                    speed: Vector2(cos(angle), sin(angle)) * speed,
                    acceleration: Vector2(0, 100), // Gravity
                    child: ComputedParticle(
                      renderer: (canvas, particle) {
                        final paint = Paint()
                          ..color = primaryColor.withValues(
                            alpha: 1.0 - particle.progress,
                          ); // Fade out
                        canvas.drawCircle(
                          Offset.zero,
                          (4.0 * scale) *
                              (1.0 -
                                  particle.progress * 0.5), // Shrink slightly
                          paint,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );

          // Flash effect
          add(
            ParticleSystemComponent(
              particle: ComputedParticle(
                lifespan: 0.2,
                renderer: (canvas, particle) {
                  canvas.drawRect(
                    Rect.fromLTWH(0, 0, size.x, size.y),
                    Paint()
                      ..color = Colors.white.withValues(
                        alpha: 0.8 * (1 - particle.progress),
                      ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    // Completion Timer
    add(
      TimerComponent(
        period: 2.5,
        removeOnFinish: true,
        onTick: () => onComplete(),
      ),
    );
  }
}
