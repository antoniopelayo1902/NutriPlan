import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../data_display/app_badge.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days, required this.badges});

  final int days;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      tone: CardTone.highlightSoft,
      elevation: CardElevation.none,
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          const Eyebrow(S.streakEyebrow, tone: TextTone.highlight),
          AppStack(
            direction: Axis.horizontal,
            gap: t.space.s3,
            children: <Widget>[
              _disc(t),
              Flexible(
                child: AppStack(
                  gap: t.space.s1,
                  align: CrossAxisAlignment.start,
                  children: <Widget>[
                    AppText(S.streakUnit(days), tone: TextTone.secondary),
                    const AppText(
                      S.streakCaption,
                      variant: TextVariant.caption,
                      tone: TextTone.secondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badges.isNotEmpty)
            AppStack(
              direction: Axis.horizontal,
              wrap: true,
              gap: t.space.s2,
              children: <Widget>[
                for (final String b in badges)
                  AppBadge(b, tone: BadgeTone.highlight),
              ],
            ),
        ],
      ),
    );
  }

  Widget _disc(AppTokens t) => SizedBox(
    width: t.size.streakDisc,
    height: t.size.streakDisc,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.highlight,
        shape: BoxShape.circle,
      ),
      child: Center(child: AppText('$days', variant: TextVariant.metricMd)),
    ),
  );
}
