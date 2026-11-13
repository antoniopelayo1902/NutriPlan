import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import 'app_text.dart';

/// Icon vocabulary of the app. Screens never reference icon fonts directly.
enum AppIconName {
  calendar,
  today,
  swap,
  activity,
  progress,
  close,
  check,
  chevronRight,
  chevronLeft,
  arrowRight,
  info,
  add,
  remove,
  edit,
  delete,
  camera,
  image,
  qr,
  logout,
}

enum AppIconSize { sm, md }

IconData _iconData(AppIconName n) {
  switch (n) {
    case AppIconName.calendar:
      return Icons.calendar_month_outlined;
    case AppIconName.today:
      return Icons.wb_sunny_outlined;
    case AppIconName.swap:
      return Icons.swap_horiz_rounded;
    case AppIconName.activity:
      return Icons.directions_run_rounded;
    case AppIconName.progress:
      return Icons.show_chart_rounded;
    case AppIconName.close:
      return Icons.close_rounded;
    case AppIconName.check:
      return Icons.check_rounded;
    case AppIconName.chevronRight:
      return Icons.chevron_right_rounded;
    case AppIconName.chevronLeft:
      return Icons.chevron_left_rounded;
    case AppIconName.arrowRight:
      return Icons.arrow_forward_rounded;
    case AppIconName.info:
      return Icons.info_outline_rounded;
    case AppIconName.add:
      return Icons.add_rounded;
    case AppIconName.remove:
      return Icons.remove_rounded;
    case AppIconName.edit:
      return Icons.edit_outlined;
    case AppIconName.delete:
      return Icons.delete_outline_rounded;
    case AppIconName.camera:
      return Icons.photo_camera_outlined;
    case AppIconName.image:
      return Icons.photo_library_outlined;
    case AppIconName.qr:
      return Icons.qr_code_2_rounded;
    case AppIconName.logout:
      return Icons.logout_rounded;
  }
}

class AppIcon extends StatelessWidget {
  const AppIcon(
    this.name, {
    super.key,
    this.size = AppIconSize.md,
    this.tone = TextTone.primary,
  });

  final AppIconName name;
  final AppIconSize size;
  final TextTone tone;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return ExcludeSemantics(
      child: Icon(
        _iconData(name),
        size: size == AppIconSize.sm ? t.size.iconSm : t.size.iconMd,
        color: textColorFor(t, tone),
      ),
    );
  }
}
