import 'dart:async';
import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

/// Loop Reset Timer - Countdown to next prestige/loop reset
class LoopResetTimer extends StatefulWidget {
  final Duration timeRemaining;
  final VoidCallback? onComplete;

  const LoopResetTimer({
    super.key,
    required this.timeRemaining,
    this.onComplete,
  });

  @override
  State<LoopResetTimer> createState() => _LoopResetTimerState();
}

class _LoopResetTimerState extends State<LoopResetTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeRemaining;
    _startTimer();
  }

  @override
  void didUpdateWidget(LoopResetTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.timeRemaining != oldWidget.timeRemaining) {
      _remaining = widget.timeRemaining;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xE60A1520), // 0.9 opacity
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0x4D00FFFF), // Electric Cyan with 0.3 opacity
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock Icon
          const Icon(
            Icons.schedule,
            color: TimeFactoryColors.electricCyan,
            size: 16,
          ),
          const SizedBox(width: 8),

          // Label
          Text(
            'Loop Reset in ',
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: Colors.white70,
            ),
          ),

          // Time
          Text(
            _formatTime(_remaining),
            style: TimeFactoryTextStyles.headerSmall.copyWith(
              fontSize: 13,
              color: TimeFactoryColors.electricCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
