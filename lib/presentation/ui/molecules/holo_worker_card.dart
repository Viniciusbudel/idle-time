import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/utils/worker_icon_helper.dart';
import 'package:time_factory/domain/entities/enums.dart';
import 'package:time_factory/presentation/ui/atoms/cyber_button.dart';
import 'package:time_factory/l10n/app_localizations.dart';

/// A worker card matching the HTML reference design.
/// Layout: Avatar Box | Info Column (ID, Role, Status, Efficiency) | Action Button
class HoloWorkerCard extends StatelessWidget {
  final String unitId;
  final String role;
  final double efficiency;
  final String status; // "OPTIMAL", "STABLE", "CRITICAL", "IDLE"
  final VoidCallback? onUpgrade;
  final String? actionLabel; // "UPGRADE", "REPAIR", "ASSIGN"
  final Color? accentColor; // Override accent, otherwise derived from status
  final WorkerRarity rarity; // Added to determine avatar image

  const HoloWorkerCard({
    super.key,
    required this.unitId,
    required this.role,
    required this.efficiency,
    required this.status,
    required this.rarity,
    this.onUpgrade,
    this.actionLabel,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status color
    final Color statusColor = accentColor ?? _getStatusColor(status);
    final String buttonLabel = actionLabel ?? _getActionLabel(context, status);

    return ClipPath(
      clipper: _HoloCardClipper(),
      child: Container(
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withValues(alpha: 0.4),
              statusColor.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipPath(
          clipper: _HoloCardClipper(),
          child: Container(
            color: const Color(0xFF0A1520), // Dark background
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // LEFT: Holographic Avatar Box
                _buildAvatarBox(statusColor),

                const SizedBox(width: 12),

                // CENTER: Info Column
                Expanded(child: _buildInfoColumn(context, statusColor)),

                const SizedBox(width: 8),

                // RIGHT: Action Button & Efficiency Badge
                _buildActionColumn(context, statusColor, buttonLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarBox(Color statusColor) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          // Base image
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SvgPicture.asset(
              WorkerIconHelper.getIconPath(WorkerEra.victorian, rarity),
              colorFilter: ColorFilter.mode(
                statusColor.withValues(alpha: 0.8),
                BlendMode.srcIn,
              ),
            ),
          ),

          // Scanline overlay effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    statusColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Status indicator dot
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: statusColor, blurRadius: 4, spreadRadius: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, Color statusColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unit ID + Role Row
        Row(
          children: [
            Text(
              unitId,
              style: TimeFactoryTextStyles.headerSmall.copyWith(
                fontSize: 13,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              role.toUpperCase(),
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 10,
                color: statusColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Status text
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.statusLabel,
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 9,
                color: Colors.grey,
              ),
            ),
            Text(
              _getLocalizedStatus(context, status).toUpperCase(),
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 9,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        // Efficiency bar
        _buildEfficiencyBar(context, statusColor),
      ],
    );
  }

  Widget _buildEfficiencyBar(BuildContext context, Color statusColor) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white10, width: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: FractionallySizedBox(
                widthFactor: efficiency.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: statusColor,
                    boxShadow: [BoxShadow(color: statusColor, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(efficiency * 100).toInt()}%',
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            fontSize: 10,
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionColumn(
    BuildContext context,
    Color statusColor,
    String buttonLabel,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Efficiency badge (small)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.2),
            border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            AppLocalizations.of(context)!.efficiency,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 8,
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Action button
        CyberButton(
          label: buttonLabel,
          onTap: onUpgrade,
          primaryColor: statusColor,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPTIMAL':
        return TimeFactoryColors.electricCyan;
      case 'STABLE':
        return TimeFactoryColors.acidGreen;
      case 'CRITICAL':
        return TimeFactoryColors.hotMagenta;
      case 'IDLE':
        return TimeFactoryColors.voltageYellow;
      default:
        return TimeFactoryColors.electricCyan;
    }
  }

  String _getActionLabel(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return AppLocalizations.of(context)!.repair;
      case 'IDLE':
        return AppLocalizations.of(context)!.assign;
      default:
        return AppLocalizations.of(context)!.upgrade;
    }
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'OPTIMAL':
        return AppLocalizations.of(context)!.optimal;
      case 'STABLE':
        return AppLocalizations.of(context)!.stable;
      case 'CRITICAL':
        return AppLocalizations.of(context)!.critical;
      case 'IDLE':
        return AppLocalizations.of(context)!.idle;
      default:
        return status;
    }
  }
}

class _HoloCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const bevel = 10.0;
    // Beveled corners (top-left and bottom-right)
    path.moveTo(bevel, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - bevel);
    path.lineTo(size.width - bevel, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, bevel);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
