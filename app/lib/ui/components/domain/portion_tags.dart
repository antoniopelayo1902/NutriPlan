import 'package:flutter/widgets.dart';

import '../../../core/format/es_mx_format.dart';
import '../../../domain/models/portions.dart';
import '../primitives/app_text.dart';

/// "1 Cereal · 1 Fruta" line for a set of portions.
class PortionTags extends StatelessWidget {
  const PortionTags(this.portions, {super.key, this.tone = TextTone.muted});

  final Portions portions;
  final TextTone tone;

  @override
  Widget build(BuildContext context) {
    return AppText(
      formatPortionTags(portions),
      variant: TextVariant.bodySm,
      tone: tone,
    );
  }
}
