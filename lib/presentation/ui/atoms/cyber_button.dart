import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';

class CyberButton extends StatelessWidget {
  final String label;
  final String? subLabel;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color primaryColor;
  final Color textColor;
  final bool isLarge;

  const CyberButton({
    super.key,
    required this.label,
    this.subLabel,
    this.icon,
    this.onTap,
    this.primaryColor = TimeFactoryColors.electricCyan,
    this.textColor = Colors.black,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.mediumImpact();
          onTap!();
        }
      },
      child: ClipPath(
        clipper: _CyberButtonClipper(),
        child: Container(
          height: isLarge ? 48 : 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: onTap != null ? primaryColor : Colors.grey[800],
            border: Border.all(
              color: Colors.white.withOpacity( 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 8),
              ],
              Text(
                label.toUpperCase(),
                style: TimeFactoryTextStyles.button.copyWith(
                  color: textColor,
                  fontSize: isLarge ? 14 : 12,
                ),
              ),
              if (subLabel != null) ...[
                Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: textColor.withOpacity( 0.2),
                ),
                Text(
                  subLabel!,
                  style: TimeFactoryTextStyles.bodyMono.copyWith(
                    fontSize: 10,
                    color: textColor.withOpacity( 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CyberButtonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // polygon(0 0, 100% 0, 100% 70%, 90% 100%, 0 100%)
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.7);
    path.lineTo(size.width * 0.9, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
