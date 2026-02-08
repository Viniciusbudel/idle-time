import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KnifeSwitchLever extends StatefulWidget {
  final VoidCallback onToggle;
  final bool isEnabled;
  final String label;

  const KnifeSwitchLever({
    super.key,
    required this.onToggle,
    this.isEnabled = true,
    this.label = 'ENGAGE',
  });

  @override
  State<KnifeSwitchLever> createState() => _KnifeSwitchLeverState();
}

class _KnifeSwitchLeverState extends State<KnifeSwitchLever>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _angleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Animate from Up (-45 deg) to Down (45 deg)
    _angleAnimation = Tween<double>(begin: -0.5, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reset after a short delay to simulate "engaging" and resetting
        HapticFeedback.heavyImpact();
        widget.onToggle();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _controller.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isEnabled && !_controller.isAnimating) {
      HapticFeedback.lightImpact();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80,
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Base Plate
                Container(
                  width: 40,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C241B),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF5D4037)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                // Contacts (Top and Bottom)
                Positioned(top: 10, child: _ContactPoint()),
                Positioned(bottom: 10, child: _ContactPoint()),

                // The Lever Arm
                AnimatedBuilder(
                  animation: _angleAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _angleAnimation.value,
                      alignment: Alignment.bottomCenter, // Pivot at bottom
                      child: Container(
                        width: 12,
                        height: 60,
                        margin: const EdgeInsets.only(
                          bottom: 20,
                        ), // Adjust pivot point
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFCCCCCC),
                              Color(0xFF999999),
                            ], // Steel
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Handle Grip
                            Container(
                              width: 16,
                              height: 24,
                              decoration: BoxDecoration(
                                color: widget.isEnabled
                                    ? Colors.red[900]
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Courier', // Fallback if custom font not ready
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFBCAAA4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFE0C097), // Brass
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
