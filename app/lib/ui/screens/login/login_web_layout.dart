import 'package:flutter/material.dart';

import '../../../core/i18n/strings_web_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_web.dart';
import '../../../theme/tokens_context.dart';
import '../../components/primitives/app_stack.dart';
import '../../components/primitives/app_text.dart';
import '../../web/web_brand_mark.dart';

/// Wide-web login: a calm brand panel on the left, the form on the right.
class LoginWebLayout extends StatelessWidget {
  const LoginWebLayout({super.key, required this.card, required this.actions});

  /// The sign-in card and the secondary actions under it.
  final Widget card;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return Row(
      children: <Widget>[
        Expanded(flex: 5, child: _brandPanel(t)),
        Expanded(
          flex: 4,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(t.space.s7),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: t.size.webLoginCard),
                  child: AppStack(
                    gap: t.space.s5,
                    children: <Widget>[
                      const AppText(
                        SWeb.webLoginWelcome,
                        variant: TextVariant.titleLg,
                      ),
                      card,
                      actions,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _brandPanel(AppTokens t) {
    return ColoredBox(
      color: t.colors.bgInverse,
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -t.size.webDecoCircle / 3,
            bottom: -t.size.webDecoCircle / 3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.accent.withValues(alpha: t.size.decoOpacity),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: t.size.webDecoCircle,
                height: t.size.webDecoCircle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(t.space.s10),
              child: AppStack(
                gap: t.space.s6,
                justify: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                align: CrossAxisAlignment.start,
                children: <Widget>[
                  const WebBrandMark(inverse: true),
                  const AppText(
                    SWeb.webBrandTagline,
                    variant: TextVariant.displayLg,
                    tone: TextTone.inverse,
                  ),
                  const AppText(
                    SWeb.webBrandBody,
                    variant: TextVariant.bodyLg,
                    tone: TextTone.inverse,
                  ),
                  for (final String point in const <String>[
                    SWeb.webBrandPoint1,
                    SWeb.webBrandPoint2,
                    SWeb.webBrandPoint3,
                  ])
                    _point(t, point),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _point(AppTokens t, String text) {
    return AppStack(
      direction: Axis.horizontal,
      gap: t.space.s3,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.check_circle_outline_rounded,
          size: t.size.iconMd,
          color: t.colors.accentMuted,
        ),
        Flexible(child: AppText(text, tone: TextTone.inverse)),
      ],
    );
  }
}
