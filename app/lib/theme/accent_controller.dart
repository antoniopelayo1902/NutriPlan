import 'package:flutter/foundation.dart';

import 'dart:ui';

import 'primitives.dart';

/// Holds the runtime accent. Setting [value] re-themes the whole app.
class AccentController extends ValueNotifier<Color> {
  AccentController([super.value = Hue.accent500]);
}
