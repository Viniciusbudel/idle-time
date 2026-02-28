import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:time_factory/core/constants/colors.dart';
import 'package:time_factory/core/constants/text_styles.dart';
import 'package:time_factory/core/theme/neon_theme.dart';
import 'package:time_factory/l10n/app_localizations.dart';
import 'package:time_factory/presentation/state/game_state_provider.dart';
import 'package:time_factory/presentation/state/performance_mode_provider.dart';
import 'package:time_factory/presentation/ui/pages/achievements_screen.dart';
import 'package:time_factory/presentation/ui/atoms/game_action_button.dart';
import 'package:time_factory/core/ui/app_icons.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = const NeonTheme();
    final colors = theme.colors;
    final currentLocale = Localizations.localeOf(context).languageCode;
    final performanceMode = ref.watch(performanceModeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: AppIcon(AppHugeIcons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TimeFactoryTextStyles.header.copyWith(
            color: colors.primary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // General Section
          _buildSectionHeader(
            AppLocalizations.of(context)!.settingsGeneral,
            colors.primary,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            AppHugeIcons.language,
            AppLocalizations.of(context)!.settingsLanguage,
            currentLocale.toUpperCase(),
            colors,
          ),
          _buildPerformanceModeTile(ref, performanceMode, colors),

          // Achievements
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementsScreen()),
              );
            },
            child: _buildSettingCard(
              icon: AppHugeIcons.emoji_events,
              title: AppLocalizations.of(context)!.achievements,
              colors: colors,
              iconColor: TimeFactoryColors.voltageYellow,
              trailing: const AppIcon(
                AppHugeIcons.chevron_right,
                color: Colors.white38,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Data Section
          _buildSectionHeader(
            AppLocalizations.of(context)!.settingsData,
            TimeFactoryColors.hotMagenta,
          ),
          const SizedBox(height: 12),
          _buildResetTile(context, ref, colors),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader(
            AppLocalizations.of(context)!.settingsAbout,
            colors.accent,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(
            AppHugeIcons.info_outline,
            AppLocalizations.of(context)!.settingsVersion,
            '0.1.0',
            colors,
          ),
          _buildInfoTile(
            AppHugeIcons.code,
            AppLocalizations.of(context)!.settingsDeveloper,
            'Budel co',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            color: color,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildResetTile(BuildContext context, WidgetRef ref, dynamic colors) {
    return _buildSettingCard(
      icon: AppHugeIcons.warning_amber_rounded,
      title: AppLocalizations.of(context)!.settingsResetProgress,
      colors: colors,
      iconColor: TimeFactoryColors.hotMagenta,
      trailing: GestureDetector(
        onTap: () => _showResetConfirmation(context, ref),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            AppLocalizations.of(context)!.settingsReset,
            style: TimeFactoryTextStyles.bodyMono.copyWith(
              fontSize: 11,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    AppIconData icon,
    String title,
    String value,
    dynamic colors,
  ) {
    return _buildSettingCard(
      icon: icon,
      title: title,
      colors: colors,
      trailing: Text(
        value,
        style: TimeFactoryTextStyles.bodyMono.copyWith(
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildPerformanceModeTile(
    WidgetRef ref,
    PerformanceMode mode,
    dynamic colors,
  ) {
    return _buildSettingCard(
      icon: AppHugeIcons.speed,
      title: 'Performance Mode',
      colors: colors,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<PerformanceMode>(
          value: mode,
          dropdownColor: const Color(0xFF0A0E17),
          style: TimeFactoryTextStyles.bodyMono.copyWith(
            fontSize: 12,
            color: Colors.white70,
          ),
          onChanged: (value) {
            if (value == null) return;
            ref.read(performanceModeProvider.notifier).setMode(value);
          },
          items: PerformanceMode.values
              .map(
                (value) => DropdownMenuItem<PerformanceMode>(
                  value: value,
                  child: Text(value.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required AppIconData icon,
    required String title,
    required dynamic colors,
    required Widget trailing,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          AppIcon(
            icon,
            size: 20,
            color: iconColor ?? colors.primary.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TimeFactoryTextStyles.bodyMono.copyWith(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF03070C),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.red, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const AppIcon(
                    AppHugeIcons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                        context,
                      )!.settingsResetConfirmTitle.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.settingsResetConfirmBody,
                style: TimeFactoryTextStyles.body.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GameActionButton(
                      onTap: () => Navigator.of(ctx).pop(),
                      label: AppLocalizations.of(context)!.cancel.toUpperCase(),
                      color: Colors.white54,
                      icon: AppHugeIcons.close,
                      height: 48,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GameActionButton(
                      onTap: () {
                        ref.read(gameStateProvider.notifier).reset();
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      label: AppLocalizations.of(
                        context,
                      )!.settingsReset.toUpperCase(),
                      color: Colors.red,
                      icon: AppHugeIcons.warning_amber_rounded,
                      height: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
