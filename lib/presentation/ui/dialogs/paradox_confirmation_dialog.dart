import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

class ParadoxConfirmationDialog extends StatefulWidget {
  final VoidCallback onConfirm;

  const ParadoxConfirmationDialog({super.key, required this.onConfirm});

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => ParadoxConfirmationDialog(onConfirm: onConfirm),
    );
  }

  @override
  State<ParadoxConfirmationDialog> createState() =>
      _ParadoxConfirmationDialogState();
}

class _ParadoxConfirmationDialogState extends State<ParadoxConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  Timer? _hapticTimer;
  bool _isCollapsing = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat(reverse: true);

    // Initial warning impact
    HapticFeedback.heavyImpact();

    // Continuous subtle vibration during the warning state
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted && !_isCollapsing) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _hapticTimer?.cancel();
    super.dispose();
  }

  void _triggerCollapse() async {
    setState(() => _isCollapsing = true);
    _hapticTimer?.cancel();

    // Intense shake buildup
    _shakeController.duration = const Duration(milliseconds: 50);
    _shakeController.repeat(reverse: true);

    for (int i = 0; i < 5; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (mounted) {
      widget.onConfirm();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final math = sin(_shakeController.value * pi * 2);
          final offset = _isCollapsing ? math * 12 : math * 2;

          return Transform.translate(
            offset: Offset(offset, 0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: _isCollapsing
                      ? Colors.white
                      : TimeFactoryColors.hotMagenta,
                  width: _isCollapsing ? 4 : 2,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isCollapsing
                        ? Colors.white.withOpacity(0.8)
                        : TimeFactoryColors.hotMagenta.withOpacity(0.4),
                    blurRadius: _isCollapsing ? 40 : 20,
                    spreadRadius: _isCollapsing ? 10 : 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: _isCollapsing
                        ? Colors.white
                        : TimeFactoryColors.hotMagenta,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'WARNING: TIMELINE COLLAPSE',
                    textAlign: TextAlign.center,
                    style: TimeFactoryTextStyles.header.copyWith(
                      color: _isCollapsing
                          ? Colors.white
                          : TimeFactoryColors.hotMagenta,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Initiating a Paradox will destroy your current timeline.\\nAll Era progress, active workers, and stations will be lost.\\n\\nYou will retain Time Shards, Artifacts, and Paradox Points.',
                    textAlign: TextAlign.center,
                    style: TimeFactoryTextStyles.body.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_isCollapsing)
                    const CircularProgressIndicator(color: Colors.white)
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'ABORT',
                            style: TimeFactoryTextStyles.body.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _triggerCollapse,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: TimeFactoryColors.hotMagenta,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: TimeFactoryColors.hotMagenta,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Text(
                              'COLLAPSE',
                              style: TimeFactoryTextStyles.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
