import 'package:flutter/widgets.dart';

import '../primitives/app_text.dart';

/// Serif italic label above titles and cards.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.tone = TextTone.muted});

  final String text;
  final TextTone tone;

  @override
  Widget build(BuildContext context) {
    return AppText(text, variant: TextVariant.eyebrow, tone: tone);
  }
}
