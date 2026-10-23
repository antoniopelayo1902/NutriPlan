import 'package:flutter/widgets.dart';

import '../primitives/app_text.dart';

/// One-line context under the day picker: which day and how far along.
class DaySummary extends StatelessWidget {
  const DaySummary(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: AppText(
      label,
      variant: TextVariant.bodyMd,
      tone: TextTone.secondary,
    ),
  );
}
