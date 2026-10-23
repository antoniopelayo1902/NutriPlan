import 'package:flutter/widgets.dart';

import 'app_theme.dart';
import 'tokens.dart';

extension TokensContext on BuildContext {
  /// The active design tokens (set by [buildTheme]).
  AppTokens get tokens => tokensOf(this);
}
