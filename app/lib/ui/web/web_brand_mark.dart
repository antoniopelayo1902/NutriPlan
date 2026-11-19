import 'package:flutter/material.dart';

import '../../core/i18n/strings_es_mx.dart';
import '../../theme/tokens.dart';
import '../../theme/tokens_web.dart';
import '../../theme/tokens_context.dart';
import '../components/primitives/app_stack.dart';
import '../components/primitives/app_text.dart';

/// Leaf in a soft disc plus the app name; shared by sidebar and login.
class WebBrandMark extends StatelessWidget {
  const WebBrandMark({super.key, this.inverse = false});

  /// True on a dark (primary) surface.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppStack(
      direction: Axis.horizontal,
      gap: t.space.s3,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: inverse ? t.colors.accent : t.colors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: t.size.brandMark,
            height: t.size.brandMark,
            child: Icon(
              Icons.eco_rounded,
              size: t.size.iconMd,
              color: inverse ? t.colors.primaryInk : t.colors.textAccent,
            ),
          ),
        ),
        AppText(
          S.appName,
          variant: TextVariant.titleMd,
          tone: inverse ? TextTone.inverse : TextTone.primary,
        ),
      ],
    );
  }
}
