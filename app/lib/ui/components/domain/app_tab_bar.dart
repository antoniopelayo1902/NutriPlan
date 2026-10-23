import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../primitives/app_icon.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';
import '../primitives/focus_ring.dart';
import '../primitives/pressable.dart';

class AppTabItem {
  const AppTabItem(this.icon, this.label);
  final AppIconName icon;
  final String label;
}

/// Floating pill tab bar with a blurred backdrop.
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    super.key,
    required this.items,
    required this.active,
    required this.onSelect,
  });

  final List<AppTabItem> items;
  final int active;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final BorderRadius radius = BorderRadius.circular(t.radius.pill);
    // The bar has a fixed height, so its labels stop scaling at 1.3x.
    final MediaQueryData mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(maxScaleFactor: t.size.tabMaxTextScale),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: t.shadow.float,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: t.size.tabBlur,
              sigmaY: t.size.tabBlur,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.glass,
                borderRadius: radius,
                border: Border.all(
                  color: t.shadow.floatHighlight,
                  width: t.size.borderWidth,
                ),
              ),
              child: SizedBox(
                height: t.size.tabBarHeight,
                child: Padding(
                  padding: EdgeInsets.all(t.space.s1),
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < items.length; i++)
                        Expanded(child: _tab(t, i)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(AppTokens t, int i) {
    final bool on = i == active;
    return Pressable(
      onPressed: () => onSelect(i),
      selected: on,
      stretch: true,
      minHeight: t.size.tabBarHeight - t.space.s2,
      builder: (BuildContext context, PressState s) {
        final TextTone tone = on ? TextTone.accent : TextTone.muted;
        return FocusRing(
          visible: s.focused,
          radius: t.radius.pill,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: on ? t.colors.accentSoft : t.colors.transparent,
              borderRadius: BorderRadius.circular(t.radius.pill),
            ),
            child: Center(
              child: AppStack(
                gap: t.space.s0,
                align: CrossAxisAlignment.center,
                justify: MainAxisAlignment.center,
                children: <Widget>[
                  AppIcon(items[i].icon, tone: tone),
                  AppText(
                    items[i].label,
                    variant: TextVariant.micro,
                    tone: tone,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
