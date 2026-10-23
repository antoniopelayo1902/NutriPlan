import 'package:flutter/widgets.dart';

import '../../../core/i18n/strings_es_mx.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import '../actions/app_chip.dart';
import '../data_display/eyebrow.dart';
import '../primitives/app_card.dart';
import '../primitives/app_stack.dart';
import '../primitives/app_text.dart';

class QuickLogOption {
  const QuickLogOption(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
}

class QuickLogGrid extends StatelessWidget {
  const QuickLogGrid({super.key, required this.options});

  final List<QuickLogOption> options;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    return AppCard(
      padding: t.space.s5,
      child: AppStack(
        gap: t.space.s3,
        children: <Widget>[
          const Eyebrow(S.quickLogEyebrow),
          AppStack(
            direction: Axis.horizontal,
            wrap: true,
            gap: t.space.s2,
            children: <Widget>[
              for (final QuickLogOption o in options)
                AppChip(label: o.label, onPressed: o.onPressed),
            ],
          ),
          const AppText(
            S.quickLogCaption,
            variant: TextVariant.caption,
            tone: TextTone.muted,
          ),
        ],
      ),
    );
  }
}
