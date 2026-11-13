import 'package:flutter/material.dart';

import '../../../application/toast_controller.dart';
import '../../../theme/tokens.dart';
import '../../../theme/tokens_context.dart';
import 'app_toast.dart';

/// Muestra el toast actual del [ToastController].
class ToastHost extends StatelessWidget {
  const ToastHost({super.key, required this.controller});

  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    final AppTokens t = context.tokens;
    final bool reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? _) {
        final ToastMessage? m = controller.current;
        return AnimatedSwitcher(
          duration: reduce ? Duration.zero : t.motion.base,
          child: m == null
              ? const SizedBox.shrink(key: ValueKey<int>(0))
              : Center(
                  key: ValueKey<int>(m.id),
                  child: GestureDetector(
                    onTap: controller.dismiss,
                    child: AppToast(message: m.text),
                  ),
                ),
        );
      },
    );
  }
}
