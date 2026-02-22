// ignore_for_file: constant_identifier_names

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

typedef AppIconData = List<List<dynamic>>;

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.shadows,
    this.strokeWidth,
    this.semanticLabel,
  });

  final AppIconData? icon;
  final double? size;
  final Color? color;
  final List<Shadow>? shadows;
  final double? strokeWidth;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? IconTheme.of(context).size ?? 24.0;
    final resolvedColor = color ?? IconTheme.of(context).color;
    final fallback = SizedBox.square(dimension: resolvedSize);

    if (icon == null) return fallback;

    final iconWidget = HugeIcon(
      icon: icon!,
      size: resolvedSize,
      color: resolvedColor,
      strokeWidth: strokeWidth,
    );

    Widget widget = iconWidget;
    final iconShadows = shadows;
    if (iconShadows != null && iconShadows.isNotEmpty) {
      widget = Stack(
        clipBehavior: Clip.none,
        children: [
          for (final shadow in iconShadows)
            Transform.translate(
              offset: shadow.offset,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: shadow.blurRadius / 2,
                  sigmaY: shadow.blurRadius / 2,
                ),
                child: HugeIcon(
                  icon: icon!,
                  size: resolvedSize,
                  color: shadow.color,
                  strokeWidth: strokeWidth,
                ),
              ),
            ),
          iconWidget,
        ],
      );
    }

    if (semanticLabel == null || semanticLabel!.isEmpty) return widget;

    return Semantics(label: semanticLabel, child: widget);
  }
}

class AppHugeIcons {
  const AppHugeIcons._();

  static const AppIconData access_time = HugeIcons.strokeRoundedClock01;
  static const AppIconData add = HugeIcons.strokeRoundedAdd01;
  static const AppIconData all_inclusive = HugeIcons.strokeRoundedInfinity01;
  static const AppIconData api = HugeIcons.strokeRoundedApi;
  static const AppIconData architecture = HugeIcons.strokeRoundedBuilding06;
  static const AppIconData arrow_back = HugeIcons.strokeRoundedArrowLeft01;
  static const AppIconData arrow_forward = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData arrow_right_alt =
      HugeIcons.strokeRoundedArrowRight03;
  static const AppIconData auto_awesome = HugeIcons.strokeRoundedSparkles;
  static const AppIconData auto_awesome_motion = HugeIcons.strokeRoundedStars;
  static const AppIconData auto_fix_high = HugeIcons.strokeRoundedMagicWand01;
  static const AppIconData blur_circular = HugeIcons.strokeRoundedBlur;
  static const AppIconData blur_on = HugeIcons.strokeRoundedBlur;
  static const AppIconData bolt = HugeIcons.strokeRoundedFlash;
  static const AppIconData check = HugeIcons.strokeRoundedCheckmarkCircle01;
  static const AppIconData check_circle =
      HugeIcons.strokeRoundedCheckmarkCircle01;
  static const AppIconData chevron_right = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData close = HugeIcons.strokeRoundedCancel01;
  static const AppIconData code = HugeIcons.strokeRoundedCode;
  static const AppIconData cyclone = HugeIcons.strokeRoundedFastWind;
  static const AppIconData dangerous = HugeIcons.strokeRoundedDanger;
  static const AppIconData diamond = HugeIcons.strokeRoundedDiamond01;
  static const AppIconData diamond_outlined = HugeIcons.strokeRoundedDiamond;
  static const AppIconData diversity_3 = HugeIcons.strokeRoundedUserGroup;
  static const AppIconData domain = HugeIcons.strokeRoundedBuilding05;
  static const AppIconData electric_bolt = HugeIcons.strokeRoundedFlash;
  static const AppIconData emoji_events = HugeIcons.strokeRoundedAward01;
  static const AppIconData energy_savings_leaf = HugeIcons.strokeRoundedLeaf01;
  static const AppIconData engineering = HugeIcons.strokeRoundedGears;
  static const AppIconData error_outline = HugeIcons.strokeRoundedAlertCircle;
  static const AppIconData factory = HugeIcons.strokeRoundedFactory01;
  static const AppIconData factory_outlined = HugeIcons.strokeRoundedFactory;
  static const AppIconData fast_forward_rounded =
      HugeIcons.strokeRoundedForward02;
  static const AppIconData flash_on = HugeIcons.strokeRoundedFlash;
  static const AppIconData grid_view = HugeIcons.strokeRoundedGridView;
  static const AppIconData group = HugeIcons.strokeRoundedUserGroup;
  static const AppIconData group_off = HugeIcons.strokeRoundedUserRemove01;
  static const AppIconData groups = HugeIcons.strokeRoundedUserMultiple;
  static const AppIconData history_edu = HugeIcons.strokeRoundedBookOpen01;
  static const AppIconData hourglass_bottom = HugeIcons.strokeRoundedHourglass;
  static const AppIconData hourglass_top = HugeIcons.strokeRoundedHourglass;
  static const AppIconData hub = HugeIcons.strokeRoundedApi;
  static const AppIconData info_outline =
      HugeIcons.strokeRoundedInformationCircle;
  static const AppIconData inventory_2_outlined =
      HugeIcons.strokeRoundedPackage;
  static const AppIconData keyboard_arrow_down =
      HugeIcons.strokeRoundedArrowDown01;
  static const AppIconData language = HugeIcons.strokeRoundedLanguageCircle;
  static const AppIconData lock_clock = HugeIcons.strokeRoundedLock;
  static const AppIconData lock_outline = HugeIcons.strokeRoundedLock;
  static const AppIconData logout = HugeIcons.strokeRoundedLogout01;
  static const AppIconData loop = HugeIcons.strokeRoundedRepeat;
  static const AppIconData memory = HugeIcons.strokeRoundedChip;
  static const AppIconData merge = HugeIcons.strokeRoundedGitMerge;
  static const AppIconData merge_type = HugeIcons.strokeRoundedGitMerge;
  static const AppIconData military_tech = HugeIcons.strokeRoundedMedal01;
  static const AppIconData monetization_on_outlined =
      HugeIcons.strokeRoundedCoinsDollar;
  static const AppIconData music_note = HugeIcons.strokeRoundedMusicNote01;
  static const AppIconData person = HugeIcons.strokeRoundedUser;
  static const AppIconData person_add = HugeIcons.strokeRoundedUserAdd01;
  static const AppIconData person_off = HugeIcons.strokeRoundedUserRemove01;
  static const AppIconData precision_manufacturing =
      HugeIcons.strokeRoundedRobotic;
  static const AppIconData precision_manufacturing_rounded =
      HugeIcons.strokeRoundedRobotic;
  static const AppIconData psychology = HugeIcons.strokeRoundedBrain;
  static const AppIconData public = HugeIcons.strokeRoundedGlobe;
  static const AppIconData remove_red_eye = HugeIcons.strokeRoundedEye;
  static const AppIconData repeat = HugeIcons.strokeRoundedRepeat;
  static const AppIconData rocket_launch = HugeIcons.strokeRoundedRocket01;
  static const AppIconData satellite_alt_outlined =
      HugeIcons.strokeRoundedSatellite;
  static const AppIconData schedule = HugeIcons.strokeRoundedClock02;
  static const AppIconData science = HugeIcons.strokeRoundedMicroscope;
  static const AppIconData search = HugeIcons.strokeRoundedSearch01;
  static const AppIconData settings = HugeIcons.strokeRoundedSettings01;
  static const AppIconData settings_input_component =
      HugeIcons.strokeRoundedCpuSettings;
  static const AppIconData shield = HugeIcons.strokeRoundedShield01;
  static const AppIconData shopping_bag_outlined =
      HugeIcons.strokeRoundedShoppingBag01;
  static const AppIconData speed = HugeIcons.strokeRoundedDashboardSpeed01;
  static const AppIconData star = HugeIcons.strokeRoundedStar;
  static const AppIconData star_half = HugeIcons.strokeRoundedStarHalf;
  static const AppIconData stars = HugeIcons.strokeRoundedStars;
  static const AppIconData timer_off_outlined = HugeIcons.strokeRoundedTimer02;
  static const AppIconData toll = HugeIcons.strokeRoundedCoins01;
  static const AppIconData touch_app_outlined = HugeIcons.strokeRoundedTouch01;
  static const AppIconData trending_up = HugeIcons.strokeRoundedChartUp;
  static const AppIconData upgrade = HugeIcons.strokeRoundedArrowUpDouble;
  static const AppIconData warning = HugeIcons.strokeRoundedAlert02;
  static const AppIconData warning_amber = HugeIcons.strokeRoundedAlert02;
  static const AppIconData warning_amber_rounded =
      HugeIcons.strokeRoundedAlert02;
}
