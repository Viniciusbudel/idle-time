import 'package:flutter/material.dart';
import 'package:time_factory/core/constants/text_styles.dart';

/// System Monitor Text - Bottom corner system info display
class SystemMonitorText extends StatelessWidget {
  final String version;
  final double gridIntegrity;
  final String serverName;

  const SystemMonitorText({
    super.key,
    this.version = 'V.4.02',
    this.gridIntegrity = 0.98,
    this.serverName = 'NEO_TOKYO_SERVER_01',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLine('SYS.MONITOR.$version'),
        _buildLine('GRID_integrity: ${(gridIntegrity * 100).toInt()}%'),
        _buildLine(serverName),
      ],
    );
  }

  Widget _buildLine(String text) {
    return Text(
      text,
      style: TimeFactoryTextStyles.bodyMono.copyWith(
        fontSize: 9,
        color: Colors.white24,
        letterSpacing: 0.5,
      ),
    );
  }
}
